#=
the "Client" struct descibe a client:
    the "Residential" and "MustBeInService" arguments allow the algorithm to identify 
        - residential client => Residential == true
        - enterprise client  => Residential == false && MustBeInService == false
        - hospital client    => Residential == false && MustBeInService == true
    the algorithm make the difference between the small/medium entreprises and the large entreprises by their "AnnualConsumption" argument below or over 50MWh
    the "AnnualConsumption" also describe the quantity of energy not delivered to a client if it has been out of service for X hours
=#
mutable struct Client
    AnnualConsumption::Float64 
    MustBeInService::Bool  
    Residential::Bool
end

#=
the "Failure" struct describe each type of failure on each type of equipment:
    the "Name" argument allows the programmer, users and the algo to recognize the failure type, the first element of that string is the index of the falure type
    the "DegradationProbability" argument is distributed to the failure by the risk module function that transform maintenances into probability of failure every year 
        the "Detectable" argument is not defined yet and is present for future work to be as close as possible to the real PRIAD BB
        the "Interuption" argument is not defined yet and is present for future work to be as close as possible to the real PRIAD BB
=#
mutable struct Failure
    DegradationProbability::Float64 
        Detectable::Bool                    
        Interuption::Bool                   
    Name::String
end

#=
the "Maintenance" struct describe a maintenance type and it efficiency towards each failure type for a given equipment type:
    the "Periodicity" argument is direcly given by the BB inputs and indicate how often the maintenace is done (every X years the maintenace is done)
    the "RequiredTime" argument define the the time required to opperate that maintenance, given by the param functions
    the "Failure" argument is a vector of the failure that the maintenance affect
    the "Efficiency" argument is a vector of the same length as the "Failure" vector and indicate the efficency of the maintenance on that failure type, it can take the values [1, 2, 3, 4] := [N, L, M, H] coresponding to the PRIAD publication from 2025, but it is still unuse in this version of the BB
=#
mutable struct Maintenance
    Periodicity::Float64                              
        Efficiency::Vector{Int64}
    Failure::Vector{Failure}
    RequiredTime::Float64  
end

#=
the "Equipment" struct describe an equipment and link all the other struct together:
    the "Name" argument allows the programmer, users and the algorithm to identifi the equipment type
    the "ClientsList" argument enumeraate all the client that depends on this equipment
    the "Failure" argument is a vector of all the failure that would affect this equipment
    the "Maintenances" argument is all the maintenancae type done on a certain equipment
    the "EquipmentRedondancy" argument idicate the number of this type of equipment in the same station
        the "InService" argument is not defined yet and is present for potential future work 
=#
mutable struct Equipment
    ClientsList::Vector{Client}
    EquipmentRedondancy::Int64
    Failure::Vector{Failure}
        InService::Bool                     #
    Maintenances::Vector{Maintenance} 
        Name::String 
end

#=
the "Station" struct is simply a way to regroup Equipment in the same transformation station or the same distribution line 
    the "Equipments" argument is te vector of all the equipment in that station, note that in a same station all the equipment have the same client list
=#
mutable struct Station 
    Equipments::Vector{Equipment}
end


#=
the "Interval" struct defines an interval simply with his uper bound "ub" and his lower bound "lb"
=#
mutable struct Interval 
    lb::Float64
    ub::Float64
end

#=
for the struct "Interval" the basic function isless is defined so that we can use all the function using Base.isless like sort, it simply compare the lower bound of the two intervals
=#
function Base.isless(I1::Interval, I2::Interval)
    if I1.lb < I2.lb
        return true
    end
    false
end

#GC.gc()
