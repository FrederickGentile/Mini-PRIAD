include("Struct.jl")
include("Param.jl")
include("Initialisation.jl")
include("UnavailabilitySimulator.jl")
include("ElectricitySimulator.jl")
include("RiskModule.jl")

#=
the "basicContinueEval" function take a fidelity level vector, the objective function value and the constraint values and always return true, it is call to avoid dynamic interuption of the BB
    Note: This function can be replaced by the user's function, you can do whetever that you want with the information given to the function to decide wether or not you continue the iteration
    or not. Each element of the vector ϕ corespond to the fidelity level at which the value of the associated constraint or objective function of the vector FC was evaluated.
=#
function basicContinueEval(ϕ, FC)
    return true
end

function checkInput(input)
    if length(input) == 28
        for i in [1, 3, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26]
            if abs(round(input[i]) - input[i]) >= 0.001
                @error "The $(i)th input is supposed to be an Int but is not an Int"
            end
            if input[i] <= 0 
                @error "The $(i)th input is is suppose to be positive but is non positive"
            end
        end
        for i in [2, 4, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 28]
            if input[i] <= 0 
                @error "The $(i)th input is is suppose to be positive but is non positive"
            end
        end
    elseif length(input) == 15
        for i in 1:15
            if input[i] <= 0 
                @error "The $(i)th input is is suppose to be positive but is non positive"
            end
        end
    elseif length(input) == 13
        for i in [1, 3, 5, 7, 9, 11]
            if abs(round(input[i]) - input[i]) >= 0.001
                @error "The $(i)th input is supposed to be an Int but is not an Int"
            end
            if input[i] <= 0 
                @error "The $(i)th input is is suppose to be positive but is non positive"
            end
        end
        for i in [2, 4, 6, 8, 10, 12, 13]
            if input[i] <= 0 
                @error "The $(i)th input is is suppose to be positive but is non positive"
            end
        end
    end
end

#=
the "logTime" function is use to print the time required for a call of the black box, the time writen in the file is "time2Log" and it is writen only if ask (loggingTime == true)
=#
function logTime(time2Log, loggingTime)
    if loggingTime == "true"
        dir = @__DIR__
        splitDir = split(dir, "/") 
        newSplitDir = Vector{SubString}(undef, length(splitDir) - 1)
        for i in 1:(length(splitDir) - 1)
            newSplitDir[i] = splitDir[i]
        end
        newDir = join(newSplitDir, "/")
        io = open("$newDir/timeLog.txt", "a")
        write(io, "$time2Log\n")
        close(io)
    elseif loggingTime == "false"
    else
        if loggingTime[end] == "/"
            io = open("$(loggingTime)timeLog.txt", "a")
        elseif loggingTime[end - 3:end] == ".txt"
            io = open("$loggingTime", "a")
        else
            io = open("$(loggingTime)/timeLog.txt", "a")
        end
        write(io, "$time2Log\n")
        close(io)
    end
end

#=
The "MiniPRIAD" function is the heart of the black box, it links the initialization, the unavailability simulator, the electric simulator and the risk module to take a maintenance  periodicity vector "x" and return the objective function value and the constraints values "FFC".

######################################################## Input ###########################################################
The "ϕ" is the blackbox fidelity and is contained from 0 to 1.
The "seedMC" is the black box random seed used for the Monte-Carlo samples
The "continueEval" is the function that control the intermidiate return of the function ant the constraints, it is initialize to "basicContinueEval" if not specified
The "param" argument inicate which instance is used to initialize the network, it can be set eighter to an instance [1, 2, 3] or be set to anything else to lunch the BB with the custumized parameters
The "loggingTime" argument indicate if the user want the program to print a "timeLog.txt" file with the running time of each itterations.
The "x" is the maintenances periodicity, the coordinate the the solver can itteract with, it is deffined as follow :

for 28 inputs : for 15 inputs : for 13 inputs :
     X[1]     :               :               : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for prod/HV transformators : of the prod/HV transformation stations : for the failure mecanism of the radiator obstruction
     X[2]     :     X[1]      :               : Float64 : maintenance periodicity                                                                         : for prod/HV transformators : of the prod/HV transformation stations : for the failure mecanism of the groud wire theft
     X[3]     :               :               : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for HV insulators          : of the prod/HV transformation stations : for the failure mecanism of the de la corrosion
     X[4]     :     X[2]      :               : Float64 : maintenance periodicity                                                                         : for HV insulators          : of the prod/HV transformation stations : for the failure mecanism of the copper theft
     X[5]     :     X[3]      :               : Float64 : maintenance periodicity                                                                         : for HV cables              : of the HV transporting lines           : for the failure mecanism of the lines obstruction by the growth of tree          
     X[6]     :               :               : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for HV insulators          : of the HV transporting lines           : for the failure mecanism of the de la corrosion 
     X[7]     :     X[4]      :               : Float64 : maintenance periodicity                                                                         : for HV insulators          : of the HV transporting lines           : for the failure mecanism of the copper theft 
     X[8]     :               :               : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for HV/MV transformators   : of the HV/MV transformation stations   : for the failure mecanism of the radiator obstruction             
     X[9]     :     X[5]      :               : Float64 : maintenance periodicity                                                                         : for HV/MV transformators   : of the HV/MV transformation stations   : for the failure mecanism of the groud wire theft              
     X[10]    :               :               : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for HV disconnectors       : of the HV/MV transformation stations   : for the failure mecanism of the de la corrosion 
     X[11]    :     X[6]      :               : Float64 : maintenance periodicity                                                                         : for HV disconnectors       : of the HV/MV transformation stations   : for the failure mecanism of the copper theft
     X[12]    :               :               : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for HV breakers            : of the HV/MV transformation stations   : for the failure mecanism of the de la corrosion
     X[13]    :     X[7]      :               : Float64 : maintenance periodicity                                                                         : for HV breakers            : of the HV/MV transformation stations   : for the failure mecanism of the copper theft
     X[14]    :               :               : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for HV insulators          : of the HV/MV transformation stations   : for the failure mecanism of the de la corrosion
     X[15]    :     X[8]      :               : Float64 : maintenance periodicity                                                                         : for HV insulators          : of the HV/MV transformation stations   : for the failure mecanism of the copper theft
     X[16]    :               :     X[1]      : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for MV cables              : of the MV transporting lines           : for the failure mecanism of the lines obstruction            
     X[17]    :     X[9]      :     X[2]      : Float64 : maintenance periodicity                                                                         : for MV cables              : of the MV transporting lines           : for the failure mecanism of the copper theft            
     X[18]    :               :     X[3]      : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for MV insulators          : of the MV transporting lines           : for the failure mecanism of the de la corrosion               
     X[19]    :     X[10]     :     X[4]      : Float64 : maintenance periodicity                                                                         : for MV insulators          : of the MV transporting lines           : for the failure mecanism of the copper theft                
     X[20]    :               :     X[5]      : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for MV/LV transformators   : of the MV/LV transformation stations   : for the failure mecanism of the radiator obstruction          
     X[21]    :     X[11]     :     X[6]      : Float64 : maintenance periodicity                                                                         : for MV/LV transformators   : of the MV/LV transformation stations   : for the failure mecanism of the groud wire theft          
     X[22]    :               :     X[7]      : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for MV disconnectors       : of the MV/LV transformation stations   : for the failure mecanism of the de la corrosion                 
     X[23]    :     X[12]     :     X[8]      : Float64 : maintenance periodicity                                                                         : for MV disconnectors       : of the MV/LV transformation stations   : for the failure mecanism of the copper theft                  
     X[24]    :               :     X[9]      : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for MV breakers            : of the MV/LV transformation stations   : for the failure mecanism of the de la corrosion                 
     X[25]    :     X[13]     :     X[10]     : Float64 : maintenance periodicity                                                                         : for MV breakers            : of the MV/LV transformation stations   : for the failure mecanism of the copper theft                  
     X[26]    :               :     X[11]     : Int64   : maintenance periodicity depending on the next periodicity in the maintenance periodicity vector : for MV insulators          : of the MV/LV transformation stations   : for the failure mecanism of the de la corrosion                
     X[27]    :     X[14]     :     X[12]     : Float64 : maintenance periodicity                                                                         : for MV insulators          : of the MV/LV transformation stations   : for the failure mecanism of the copper theft                
     X[28]    :     X[15]     :     X[13]     : Float64 : maintenance periodicity                                                                         : for LV cables              : of the LV transporting lines           : for the failure mecanism of the copper theft        
###########################################################################################################################
######################################################## Output ###########################################################
The "FFC" is  string that repressent a vector, it is deffined as that : [count_eval, f, C1, C2,...,C9], the string formating does not include the brackets nor the coma, it's the needed formating for NOMAD, each element of the cetor is deffined as follow : 
    FFC[1]  : count_eval : is a flag that indicat if the solver need to count this evaluation, in the case where an a priori constraints is violated, the eval is not couted ant this flag take the value 0 and the black box evaluation is stoped.
    FFC[2]  : f          : is the objective function value that represent the monatary cost caused by the choice of "x"
    FFC[3]  : C1         : is an analitical a priori constraint that control the number of maintenance over the 40 years
    FFC[4]  : C2         : is an analitical a priori constraint that control the number of hours of planned maintenance over the 40 years
    FFC[5]  : C3         : is a constraint that control the sum of the failure probability of each type of failure
    FFC[6]  : C4         : is a constraint that control the failure probability of each type of failure on which the probability is weighted to make sure noting goes over 10% and that most of them are below 5%
    FFC[7]  : C5         : is a constraint that control the failure probability of each type of equipment on which the probability is weighted to make sure noting goes over 10% and that most of them are below 5%
    FFC[8]  : C6         : is a constraint that control the total time of service interuption
    FFC[9]  : C7         : is a constraint that control the number of houres of unplanned maintenance over 40 years
    FFC[10] : C8         : is a constraint that control the total number of undelivered energy over 40 years
    FFC[11] : C9         : is a constraint that control the number of undelivered energy to hospital over 40 years
###########################################################################################################################
=#
function MiniPRIAD(input::Union{Vector{Float64}, Vector{Int64}, String}, ϕ::Float64, seedMC::Int64,; continueEval::Function = basicContinueEval, param::Int64 = 1, loggingTime::String = "false")
    timer = 0.0
    clk = time()

    if typeof(input) == String
        input = split(input)
        input = parse.(Float64, input)
    end

    FFC = [Inf for i in 1:11]
    x = Vector{Float64}(undef, 28)

    if length(input) == 28
        checkInput(input)
        x = input 
        C1_2_3_4_6_7_8_9multiplier = 1.0
    elseif length(input) == 15
        checkInput(input)
        x = [2, input[1], 2, input[2], input[3], 2, input[4], 2, input[5], 2, input[6], 2, input[7], 2, input[8], 2, input[9], 2, input[10], 2, input[11], 2, input[12], 2, input[13], 2, input[14], input[15]]
        C1_2_3_4_6_7_8_9multiplier = 1.0
    elseif length(input) == 13
        checkInput(input)
        x = [Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, Inf64, input[1], input[2], input[3], input[4], input[5], input[6], input[7], input[8], input[9], input[10], input[11], input[12], input[13]]
        C1_2_3_4_6_7_8_9multiplier = 28/13
    else
        @error "The input vector must be of length 28, 15 or 13"
        return nothing
    end

    nbVec = nbParam(param)
    T = periodicityCalculator(x)
    requiredTimeForMaintenances = MaintenancesParam(param)

####### C1 and C2 ########
    FFC[3:4] = [-500, -500]
    for i in 1:28
        FFC[3] += C1_2_3_4_6_7_8_9multiplier * 40/(T[i]) * 1.4
        FFC[4] += C1_2_3_4_6_7_8_9multiplier * requiredTimeForMaintenances[i] * 40/T[i] * 0.715
    end
    
    if (FFC[3] > 0 || FFC[4] > 0) || ϕ == 0.0
        FFC[1] = 0.0
        
        #uncomment the one you need
        #return FFC             # return a vector [count_eval, f, [C]]
        str = join(FFC, " ")
        return str             # return the same vector but as a string without "[", "]" or "," (used for NOMAD solver)
    end
#########################

    FFC[1] = 1.0

    failureList = FailureList(T)

####### C3 and C4 ########
    FFC[5:6] = [-500, -500]
    for i in 1:28
        if failureList[i].DegradationProbability != Inf64
            FFC[5] += C1_2_3_4_6_7_8_9multiplier^0.728 * failureList[i].DegradationProbability * 225
        end
    end

    for i in 1:28
        if failureList[i].DegradationProbability == Inf64
        elseif failureList[i].DegradationProbability > 0.1
            FFC[6] += C1_2_3_4_6_7_8_9multiplier^0.5 * (failureList[i].DegradationProbability)^0.25 * 72.8
        elseif failureList[i].DegradationProbability > 0.05
            FFC[6] += C1_2_3_4_6_7_8_9multiplier^0.5 * (failureList[i].DegradationProbability)^0.5 * 67.6
        else
            FFC[6] += C1_2_3_4_6_7_8_9multiplier^0.5 * failureList[i].DegradationProbability * 62.4
        end
    end
#########################

    if ϕ < 10^(-6)
        #uncomment the one you need
        #return FFC             # return a vector [count_eval, f, [C]]
        str = join(FFC, " ")
        return str             # return the same vector but as a string without "[", "]" or "," (used for NOMAD solver)


    end

    timer = time() - clk
    ϕVec = [10^(-6) for i in 1:10]
    if continueEval(ϕVec, FFC[2:11]) == false
        logTime(timer, loggingTime)

        #uncomment the one you need
        #return FFC             # return a vector [count_eval, f, [C]]
        str = join(FFC, " ")
        return str             # return the same vector but as a string without "[", "]" or "," (used for NOMAD solver)
    end
    clk = time()

    stations = EquipmentInitialisation(T, nbVec, requiredTimeForMaintenances)
######## C5 ########
    FFC[7] = -500
    for s in stations
        for e in s.Equipments
            for f in e.Failure
                λ = 0 
                λ += f.DegradationProbability
                if λ > 0.1
                    FFC[7] += λ^0.25 * 1100/(e.EquipmentRedondancy^0.75 * nbVec[18])
                elseif λ > 0.05
                    FFC[7] += λ^0.5 * 1000/(e.EquipmentRedondancy^0.75 * nbVec[18])
                else
                    FFC[7] += λ * 900/(e.EquipmentRedondancy^0.75 * nbVec[18])
                end
            end
        end
    end
####################                

    FFCT = UnavailSimulator(FFC, stations, ϕ, x, seedMC, continueEval, timer, clk, C1_2_3_4_6_7_8_9multiplier, param, nbVec)

    FFC = FFCT[1:11]
    timer = FFCT[12]           
    logTime(timer, loggingTime)

    #uncomment the one you need
    #return FFC             # return a vector [count_eval, f, [C]]
    str = join(FFC, " ")
    return str              # return the same vector but as a string without "[", "]" or "," (used for NOMAD solver)
end




#=



x_nomad =   [2, 3.4599330238832699536, 1, 9.9993679337233398741, 6.170079980093530203, 5, 1.6501819821240399921, 1, 8.5260816911309600385, 2, 1.199716170445690011,  5, 1.579786280184640068,  2, 3.5407777232053598837, 1, 4.3302690160008801001, 3, 1.4601645234989399924, 3, 3.5496390492183698129, 4, 1.5305431191758300802, 2, 3.6400045306912600651, 2, 2.5002938106947798502, 1.1015503120004999094]



# x = [I, F, I, F, F, I, F, I, F, I, F, I, F, I, F, I, F, I, F, I, F, I, F, I, F, I, F, F]
  x = [2, 1, 3, 7, 6, 6, 2, 2, 9, 2, 4, 2, 2, 2, 3, 4, 5, 3, 2, 3, 4, 2, 2, 3, 4, 3, 3, 2]

  x = [2 + i % 2 for i in 1:28]

ϕ = 1.0
#for ϕ in 0.1:0.1:0.4
seedMC = 576987593463#98847
#seedInit = 576987593463 #8172
#for i in 1:10
    #x = [i for k in 1:28]
    FFC = MiniPRIAD(x, ϕ, seedMC, param=1, loggingTime="true")
    #println("FFC : $(FFC) pour une fidélité de ϕ = $ϕ et i = $i")
#end
#end
=#

GC.gc()
