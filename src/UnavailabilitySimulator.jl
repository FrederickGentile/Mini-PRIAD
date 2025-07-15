include("Struct.jl")
include("Param.jl")

using Random

#=
The "minMaintenancesPeriodicity" function take an equipment "equip" as input and return the most frequent maintenance for this equipment and return the periodicity of that maintenance "min"
=#
function minMaintenancesPeriodicity(equip::Equipment)
    min::Float64 = Inf64
    for m in equip.Maintenances
        if m.Periodicity < min
            min =  m.Periodicity
        end
    end
    return min
end

#=
The "relativMaintenancePeriodicity" function take as input an equipment "equip" and return the relativ periodicity of the other maintance if ther is one
=#
function relativMaintenancePeriodicity(equip::Equipment)
    minPeriodicity = minMaintenancesPeriodicity(equip)

    for m in equip.Maintenances
        relativVal = m.Periodicity/minPeriodicity
        if (relativVal - 1) >= 0.001
            return Int.(round(relativVal, digits = 1))
        end
    end
    return 1
end

#=
The "requiredTime4EachMaintenance" function take an equipment as input and return a vector of the time required for the maintenaces linked to this equipment
=#
function requiredTime4EachMaintenance(equip::Equipment)
    nbMaintenances = length(equip.Maintenances)
    requiredTime = Vector{Float64}(undef, nbMaintenances)
    for m in equip.Maintenances
        if abs(m.Periodicity - minMaintenancesPeriodicity(equip)) <= 0.01 
            requiredTime[1] = m.RequiredTime
        end
    end
    for m in 1:nbMaintenances
        if equip.Maintenances[m].RequiredTime ∉ requiredTime
            requiredTime[m + 1] = equip.Maintenances[m].RequiredTime
        end
    end
    return requiredTime
end

#=
The "GetFailureRequiredTime" function take a failure as input and an instance number and return the number of houres required for the maintenence linked to this failure
=#
function GetFailureRequiredTime(failure::Failure, param)
    splitName = split(failure.Name)
    index = parse(Int,String(splitName[1]))
    requiredTimeToRepairFailures = FailuresParam(param)
    return requiredTimeToRepairFailures[index]
end

#=
The "realUnavailabilityVector" function takes the intervals of unavailability cause by planned maintenance ("uifm") and intervals of unavailability cause by failures maintenance ("uiff") 
    and return a vector of the interval where the equipment is unavailable considering the failure's maintences and the planned maintenaces
=#
function realUnavailabilityVector(uifm, uiff)
    ui = [[] for i in 1:length(uifm)]
    bidon = Interval(0, 0)
    for e in 1:length(uifm)
        ui[e] = vcat(uifm[e], uiff[e])
        for i in 1:length(uifm[e])
            for k in 1:length(uiff[e])
                if uiff[e][k].lb <= uifm[e][i].lb && uiff[e][k].ub >= uifm[e][i].ub
                    ui[e][i] = bidon
                elseif uifm[e][i].lb <= uiff[e][k].lb && uifm[e][i].ub >= uiff[e][k].ub
                    ui[e][k + length(uifm[e])] = bidon
                elseif ((uifm[e][i].ub - uiff[e][k].ub) <= (uifm[e][i].ub - uifm[e][i].lb)) && ((uifm[e][i].ub - uiff[e][k].ub) >= 0)
                    ui[e][i] = bidon
                elseif ((uiff[e][k].ub - uifm[e][i].ub) <= (uiff[e][k].ub - uiff[e][k].lb)) && ((uiff[e][k].ub - uifm[e][i].ub) >= 0)
                    ui[e][k + length(uifm[e])] = bidon
                end
            end
        end
        nbDelete = 0
        for index in findall(x -> x == bidon, ui[e])
            deleteat!(ui[e], index - nbDelete)
            nbDelete += 1
        end
        sort!(ui[e])
    end
    return ui
end

#=
The "intermidiateReturn" function takes the FFC (flag, function, constraint) object, the divider that corespond to how many MC trials have been done and the timer value and return the formated output for the MiniPRIAD function 
=#
function intermidiateReturn(FFC, divider, timer)
    FFCT = Vector{Float64}(undef, 12)
    FFCT[1:11] = deepcopy(FFC)
    FFCT[2] = FFCT[2]/divider
    FFCT[8] = FFCT[8]/divider - 500
    FFCT[9] = FFCT[9]/divider - 500
    FFCT[10] = FFCT[10]/divider - 500
    FFCT[11] = FFCT[11]/divider
    FFCT[11] -= 500
    FFCT[12] = timer
    return FFCT
end

#=
The "splitUnavailSimulator" function is the function that run the MC trials, the inputs are:
    nbEval represent the number of MC trials, 
    nbEquipments is the total number of equipment,
    nbStation is the total number of station,
    stations is the vector of stations that reprensent the eletrical network,
    FFC is the (flag, function, constraint) object,
    ϕ is the fidelity level after the "nbEval" MC trials,
    costDivider is the number of MC trials done before the "nbEval" MC trials,
    continueEval is a function that can be anything, the user can chose what it does, but it decides wether you continue or not this iteration the BB at this point,
    timer represent he time used for running the simulation since the beggening of the iteration,
    clk is the result of time() function at the last call of continueEval,
    C1_2_3_4_8_9multiplier is a multiplier that control the constraint for the different input length,
    param represent the instance number,
    nbVec is the result of the function nbParam.
it return a value of FFCT (flag, function, constraint, timer) object after the MC trials if it was not interupted befor calculating the cost and the constraints linked to the cost.    
=#
function splitUnavailSimulator(nbEval::Int64, nbEquipments::Int64, nbStation::Int64, stations, FFC::Vector{Float64}, ϕ::Float64, costDivider::Int64, continueEval::Function, timer, clk, C1_2_3_4_8_9multiplier::Float64, param::Int64, nbVec)
    ϕBefore = round(costDivider/10000, sigdigits = 4)
    nbHoursInAYear = 365.25 * 24
    allui = []
    totMaintenanceTime = 0.0
    totFailure = 0
    employeeSalary = 40
    nbEmployeeNeeded = 3 + 4    # the 3 represent the actual number of employee needed and the 4 represent the other expense (cost as much as two employee salary)
    costByFailure = 50000 

    for eval in 1:nbEval
        unavailIntervalsForMaintenances = [[] for i in 1:nbEquipments]
        unavailIntervalsForFailures = [[] for i in 1:nbEquipments]
        e = 0
        for s in 1:nbStation
            for equip in stations[s].Equipments
                e += 1
                minTime = minMaintenancesPeriodicity(equip)
                relativPeriodicity = relativMaintenancePeriodicity(equip::Equipment)
                whenCombinedMaintenaces = rand(1:(relativPeriodicity))
                requiredTime = requiredTime4EachMaintenance(equip)
                first = rand() * minTime
                if whenCombinedMaintenaces != 1
                    I = Interval(first, first + requiredTime[1]/nbHoursInAYear)
                    push!(unavailIntervalsForMaintenances[e], I)
                    whenCombinedMaintenaces -= 1
                    totMaintenanceTime += requiredTime[1]
                else
                    I = Interval(first, first + sum(requiredTime)/nbHoursInAYear)
                    push!(unavailIntervalsForMaintenances[e], I)
                    whenCombinedMaintenaces = relativPeriodicity
                    totMaintenanceTime += sum(requiredTime)
                end
                nbRemaningMaintenancesIn40Years = floor(Int, (40 - first)/minTime)
                for i in 1:nbRemaningMaintenancesIn40Years
                    first += minTime
                    if whenCombinedMaintenaces != 1
                        I = Interval(first, first + requiredTime[1]/nbHoursInAYear)
                        push!(unavailIntervalsForMaintenances[e], I)
                        whenCombinedMaintenaces -= 1
                        totMaintenanceTime += requiredTime[1]
                    else
                        I = Interval(first, first + sum(requiredTime)/nbHoursInAYear)
                        push!(unavailIntervalsForMaintenances[e], I)
                        whenCombinedMaintenaces = relativPeriodicity
                        totMaintenanceTime += sum(requiredTime)
                    end
                end 
            end
        end
        e = 0
        for s in 1:nbStation
            for equip in stations[s].Equipments
                e += 1 
                for y in 1:40
                    for f in equip.Failure
                        if rand() <= f.DegradationProbability
                            first = y + rand()
                            ###### C7 #######
                            FFC[9] += GetFailureRequiredTime(f, param)/nbEquipments * 10
                            #################
                            I = Interval(first, first + GetFailureRequiredTime(f, param)/nbHoursInAYear)
                            push!(unavailIntervalsForFailures[e], I)
                            totFailure += 1
                        end
                    end
                end
            end
        end
        ui = realUnavailabilityVector(unavailIntervalsForMaintenances, unavailIntervalsForFailures)
        push!(allui, ui)
    end
    ######## C6 ########
    C6 = 0.0
    for ui in allui
        for i in ui
            for elem in i
                C6 += (elem.ub - elem.lb)
            end
        end
    end
    FFC[8] += nbHoursInAYear * C6/nbEquipments * 6
    ####################

    ########## intermediate return ############
    FFCcopied = deepcopy(FFC)
    if FFCcopied[2] == 0.0
        FFCcopied[2] = Inf
        FFCcopied[10:11] = [Inf, Inf]
    else
        FFCcopied[2] = FFCcopied[2]/costDivider
    end
    FFCcopied[8] = FFCcopied[8]/(ϕ * 10000) - 500
    FFCcopied[9] = FFCcopied[9]/(ϕ * 10000) - 500
    FFCcopied[10] = FFCcopied[10]/(ϕ * 10000 - nbEval) - 500
    FFCcopied[11] = FFCcopied[11]/(ϕ * 10000 - nbEval)
    FFCcopied[11] -= 500

    timer += time() - clk
    ϕVec = [ϕBefore, ϕ, ϕ, ϕ, ϕ, ϕ, ϕ, ϕ, ϕBefore, ϕBefore]
    if continueEval(ϕVec, FFCcopied) == false
        FFCT = Vector{Float64}(undef, 13)
        FFCT[1:11] = FFCcopied
        FFCT[12] = timer 
        FFCT[13] = Inf64
        return FFCT
    end
    clk = time()
    ############################################

    maintenanceCost = totMaintenanceTime * employeeSalary * nbEmployeeNeeded
    failureCost = totFailure * costByFailure
    FFC[2] = FFC[2] + maintenanceCost + failureCost

    for ui in allui
         CCC = electricSimulator(stations, ui, nbStation, param, nbVec)
         FFC[2] += CCC[1]
         FFC[10] += CCC[2] * C1_2_3_4_8_9multiplier^0.75
         FFC[11] += CCC[3] * C1_2_3_4_8_9multiplier
    end
    FFCT = Vector{Float64}(undef, 13)
    FFCT[1:11] = FFC
    FFCT[12] = timer 
    FFCT[13] = clk
    return FFCT
end

#=
The "UnavailSimulator" function is the function that call the splitUnavailSimulator function, controls the number of MC trials for each call of that function so it gets to fidelity asked,
    it calls that function by block of 1000 MC trials to comunicate with continueEval at different moment of the iteration, all the argument are the same as those descibed in the description of 
    the splitUnavailSimulator function.
This function is the one that return the value of FFCT to the Main function MiniPRIAD
=#
function UnavailSimulator(FFC::Vector{Float64}, stations::Vector{Station}, ϕ::Float64, x, seedMC::Int64, continueEval::Function, timer, clk, C1_2_3_4_8_9multiplier::Float64, param::Int64, nbVec)
    nbEquipments = nbVec[18]
    if x[1] == Inf64
        nbStation = sum(nbVec[8:10])
    else
        nbStation = sum(nbVec[5:10])
    end

    Random.seed!(seedMC)
    nbEval = ceil(Int, 10000 * ϕ)
    nbReturn = ceil(10 * ϕ)

    FFC[2] = 0.0
    FFC[8:11] = [0.0, 0.0, 0.0, 0.0]
    FFCT = splitUnavailSimulator(1, nbEquipments, nbStation, stations, FFC, 1/10000, 1, continueEval, timer, clk, C1_2_3_4_8_9multiplier, param, nbVec)
    if FFCT[13] == Inf64
        return FFCT[1:12]
    end
    ########## intermediate return ############ 
    timer += time() - clk
    FFCT = intermidiateReturn(FFC, 1, timer)
    ϕVec = [1/10000 for i in 1:10]
    if continueEval(ϕVec, FFCT[2:11]) == false
        return FFCT[1:12]
    end
    clk = time()
    ############################################

    if nbReturn != 1
        for r in 1:(nbReturn - 1)

            if r == 1
                FFCT = splitUnavailSimulator(999, nbEquipments, nbStation, stations, FFC, r/10, 1, continueEval, timer, clk, C1_2_3_4_8_9multiplier, param, nbVec)
                if FFCT[13] == Inf64
                    return FFCT[1:12]
                end
            else
                FFCT = splitUnavailSimulator(1000, nbEquipments, nbStation, stations, FFC, r/10, Int(1000 * (r - 1)), continueEval, timer, clk, C1_2_3_4_8_9multiplier, param, nbVec)
                if FFCT[13] == Inf64
                    return FFCT[1:12]
                end
            end

    ######### intermediate return ############
            timer += time() - clk
            FFCT = intermidiateReturn(FFC, 1000 * r, timer)
            ϕVec = [r * 0.1 for i in 1:10]
            if continueEval(r * 0.1, FFCT[2:11]) == false
                return FFCT[1:12]
            end
            clk = time()
    ############################################
        end
    end
    if Int(nbEval - 1000 * (nbReturn - 1)) - 1 != 0
        FFCT = splitUnavailSimulator(Int(nbEval - 1000 * (nbReturn - 1)) - 1, nbEquipments, nbStation, stations, FFC, ϕ, Int(1000 * (nbReturn - 1)),  continueEval, timer, clk, C1_2_3_4_8_9multiplier, param, nbVec)
        if FFCT[13] == Inf64
            return FFCT[1:12]
        end
    end

    ############# return ################
    timer += time() - clk
    FFCT = intermidiateReturn(FFC, 10000 * ϕ, timer)
    return FFCT[1:12]
    #####################################
end

GC.gc()
