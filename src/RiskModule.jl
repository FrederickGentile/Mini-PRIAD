include("Struct.jl")
include("Param.jl")

#=
The "costOfUndeliveredEnergyCalculator" function calculate the cost of undelivered energy for a client list ("clientList") on a time lapse of "time" years
=#
function costOfUndeliveredEnergyCalculator(time::Float64, clientsList::Vector{Client}, param::Int64, nbVec)
    cost = 0.0
    C8 = 0.0
    C9 = 0.0
    nbHoursInAYear = 365.25 * 24
    if time > 16
        costVec = [12.7, 258.0, 1.3]
    elseif time > 8
        costVec = [12.9, 267.3, 1.4]
    elseif time > 4
        costVec = [12.1, 214.3, 1.6]
    elseif time > 1
        costVec = [21.8, 295.0, 3.3]
    elseif time > 0.5
        costVec = [37.4, 474.1, 5.9]
    else
        costVec = [190.7, 2255.0, 30.9]
    end
    for client in clientsList
        if client.Residential == true
            cost += time * costVec[3] * 1000 * client.AnnualConsumption/nbHoursInAYear
            C8 += client.AnnualConsumption
        elseif client.MustBeInService == false && client.AnnualConsumption <= 50
            cost += time * costVec[2] * 1000 * client.AnnualConsumption/nbHoursInAYear
            C8 += client.AnnualConsumption
        elseif client.MustBeInService == false && client.AnnualConsumption > 50
            cost += time * costVec[1]  * 1000 * client.AnnualConsumption/nbHoursInAYear
            C8 += client.AnnualConsumption
        elseif client.MustBeInService == true
            cost += time * costVec[1] * 1000 * client.AnnualConsumption/nbHoursInAYear
            C8 += client.AnnualConsumption
            C9 += client.AnnualConsumption
        end
    end
    C8 *= (time * 1000/(sum(nbVec[1:4]) * nbHoursInAYear ) * 0.125)
    C9 *= (time * 1000/((nbVec[1] + 10 * (nbVec[1])^0.5) * nbHoursInAYear) * 5)
    return [cost, C8, C9]
end

GC.gc()
