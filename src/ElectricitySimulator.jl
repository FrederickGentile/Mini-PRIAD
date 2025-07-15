include("Struct.jl")
include("Param.jl")
include("RiskModule.jl")

#=
The "serviceUnprovidedForCost" function takes a station and iterate on all the equipment with the name "name" and conpare their unavailability interval ("ui"), it generate a  
    vector of unavailability corresponding to a vector of when all the equipment with the name "name" were unavailable. it then call the costOfUndeliveredEnergyCalculator to calculate the cost linked to those unavailabilities
=#
function serviceUnprovidedForCost(station::Station, name::String, ui, decal::Int64, param::Int64, nbVec)
    C8 = 0.0
    C9 = 0.0
    uiToCompare = []
    index = 0
    nbHoursInAYear = 365.25 * 24
    for e in station.Equipments
        index += 1
        if e.Name == name
            push!(uiToCompare, ui[decal + index])
        end
    end
    cost = 0
    nexti = []
    if length(uiToCompare) == 1
        nexti = uiToCompare[1]
    elseif length(uiToCompare) != 0
        i = uiToCompare[1]
        nbToCompare = length(uiToCompare)
        index = 2
        while (nbToCompare != 1)
            nexti = []
            oi = uiToCompare[index]
            for elem in i 
                for oelem in oi
                    if elem.lb <= oelem.lb && elem.ub >= oelem.ub
                        push!(nexti, Interval(oelem.lb, oelem.ub))
                    elseif oelem.lb <= elem.lb && oelem.ub >= elem.ub
                        push!(nexti, Interval(elem.lb, elem.ub))
                    elseif ((elem.ub - oelem.ub <= elem.ub - elem.lb) &&  (elem.ub - oelem.ub > 0))   
                        push!(nexti, Interval(elem.lb, oelem.ub))
                    elseif ((oelem.ub - elem.ub <= oelem.ub - oelem.lb) &&  (oelem.ub - elem.ub > 0))
                        push!(nexti, Interval(oelem.lb, elem.ub))
                    end
                end
            end
            index += 1
            nbToCompare -= 1
            i = nexti
        end
    end
    for elem in nexti
        houresNotInService = (elem.ub - elem.lb) * nbHoursInAYear
        CCC = costOfUndeliveredEnergyCalculator(houresNotInService, station.Equipments[1].ClientsList, param, nbVec)
        cost += CCC[1]
        C8 += CCC[2]
        C9 += CCC[3]
    end
    return [cost, C8, C9]
end

#=
The "electricSimulator" function iterate on all the stations and then on all the equipment's name in the station to call the serviceUnprovidedForCost function
=#
function electricSimulator(stations::Vector{Station}, ui, nbStation, param::Int64, nbVec)

    names = ["Transformateur élévateur de tension", "Isolateur haute tension",  "Câble haute tension", "Transformateur haute à moyenne tension", "Sectionneur haute tension", "Disjoncteur haute tesnsion", "Câble moyenne tension", "Isolateur moyenne tension", "Transformateur moyenne à basse tension", "Sectionneur moyenne tension", "Disjoncteur moyenne tension", "Câble basse tension"]

    cost = 0
    C8 = 0.0
    C9 = 0.0
    decal = 0
    for s in 1:nbStation
        for n in names
            CCC = serviceUnprovidedForCost(stations[s], n, ui, decal, param, nbVec)
            cost += CCC[1]
            C8 += CCC[2]
            C9 += CCC[3]
        end
        decal += length(stations[s].Equipments)
    end
    return [cost, C8, C9]
end

GC.gc()
