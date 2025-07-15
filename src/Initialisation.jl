include("Struct.jl")
include("Param.jl")
using Random

#=
the "periodicityCalculator" function return a vector of the maintenance periodicity "T" and to build it it takes the input "x" which is a vector with mainenance periodicity and relativ maintenance periodicity
=#
function periodicityCalculator(x)
    return [x[1]*x[2], x[2], x[3]*x[4], x[4], x[5], x[6]*x[7], x[7], x[8]*x[9], x[9], x[10]*x[11], x[11] , x[12]*x[13], x[13], x[14]*x[15], x[15], x[16]*x[17], x[17], x[18]*x[19], x[19], x[20]*x[21], x[21], x[22]*x[23], x[23], x[24]*x[25], x[25], x[26]*x[27], x[27], x[28]]
end

#=
The "itVecGenerator" function take a seed ("seed") and a vector size ("n") and return a vector created by random permutation of the element of the vector [1, 2, 3,...,n]
=#
function itVecGenerator(n, seed)
    Random.seed!(seed)
    it = [-1 for i in 1:n]
    i = 1
    while i <= (n)
        k = Int(rand(1:n))
        if (k ∉ it)
            it[i] = k
            i += 1;
        end
    end
    return it
end

#=
The "stationDistribution" take the number of station ("n") and the number of upstream station of another type ("N") and return a vector of attribution
the "vec" returned is a vector that contains the number of station connected to each upstream station (example with n = 8 and  N = 3 => vec = [3, 3, 2]
=#
function stationDistribution(n, N)
    ratio = floor(Int64, n/N)

    vec = [ratio for i in 1:N]
    while sum(vec) != n 
        i = findfirst(isequal(ratio), vec)
        vec[i] += 1
    end
    return vec
end

#=
The "ClientsInitialisation" function take the "nbVec" that is simply the output of the function "nbParam" and the initialization seed ("seedInit") and generate the list of clients coresponding to the parameters.
The output "Clients" is a vector of client ordered like so : [[BigEntrepriseVector], [SmallEntrepriseVector], [HospitalVector], [ResidentialClientVector]]
=#
function ClientsInitialisation(nbVec::Vector{Int64}, seedInit)
    Random.seed!(seedInit)

    nbResidence = nbVec[1]
    nbBigEnterprise = nbVec[2]
    nbSmallEntreprises = nbVec[3]
    nbHospitals = nbVec[4]
    nbClient = sum(nbVec[1:4])

    Clients = Vector{Client}(undef, nbClient)
    for i in 1:nbClient
        if nbBigEnterprise != 0
            annualConsumption = 50 + 100 * rand() + 1000 * (rand())^2 + 10000 * (rand())^4 + 100000 * (rand())^14
            Clients[i] = Client(annualConsumption, false, false)
            nbBigEnterprise -= 1
        elseif nbSmallEntreprises != 0
            annualConsumption = 5 + 45 * (rand())^(2/3)
            Clients[i] = Client(annualConsumption, false, false)
            nbSmallEntreprises -= 1
        elseif nbHospitals != 0
            annualConsumption = (50 + 2.3 * nbResidence * (10/31) +  2.3 * nbResidence * (20/31) * rand())/nbHospitals
            Clients[i] = Client(annualConsumption, true, false)
            nbHospitals -= 1
        else
            annualConsumption = 5 + 30 * (1 - rand()) + 110 * (rand())^7
            Clients[i] = Client(annualConsumption, false, true)
        end
    end

    return Clients
end

#=
The "FailureList" function take the periodicity vector "T" and return a vector of failures "failures" with thier "Name", their probability of failure by year and other unuse arguments. 
Their probability of failure is calculated in function of the maintenance periodicities, it is calculated in the degradation model.
=#
function FailureList(T)
    failures = Vector{Failure}(undef, 28)
    
    failures[1] =  Failure(0, true, true, "1 Obstruction des radiateurs")
    failures[2] =  Failure(0, true, true, "2 Vol de câbles de mise à la terre")
    failures[3] =  Failure(0, true, true, "3 Corrosion")
    failures[4] =  Failure(0, true, true, "4 Vol de cuivre")
    
    failures[5] =  Failure(0, true, true, "5 Obstruction des lignes par la pousse des arbres")
    failures[6] =  Failure(0, true, true, "6 Corrosion")
    failures[7] =  Failure(0, true, true, "7 Vol de cuivre")

    failures[8] =  Failure(0, true, true, "8 Obstruction des radiateurs")
    failures[9] =  Failure(0, true, true, "9 Vol de câbles de mise à la terre")
    failures[10] = Failure(0, true, true, "10 Corrosion")
    failures[11] = Failure(0, true, true, "11 Vol de cuivre")
    failures[12] = Failure(0, true, true, "12 Corrosion")
    failures[13] = Failure(0, true, true, "13 Vol de cuivre")
    failures[14] = Failure(0, true, true, "14 Corrosion")
    failures[15] = Failure(0, true, true, "15 Vol de cuivre")

    failures[16] = Failure(0, true, true, "16 Obstruction des lignes")
    failures[17] = Failure(0, true, true, "17 Vol de cuivre")
    failures[18] = Failure(0, true, true, "18 Corrosion")
    failures[19] = Failure(0, true, true, "19 Vol de cuivre")

    failures[20] = Failure(0, true, true, "20 Obstruction des radiateurs")
    failures[21] = Failure(0, true, true, "21 Vol de câbles de mise à la terre")
    failures[22] = Failure(0, true, true, "22 Corrosion")
    failures[23] = Failure(0, true, true, "23 Vol de cuivre")
    failures[24] = Failure(0, true, true, "24 Corrosion")
    failures[25] = Failure(0, true, true, "25 Vol de cuivre")
    failures[26] = Failure(0, true, true, "26 Corrosion")
    failures[27] = Failure(0, true, true, "27 Vol de cuivre")

    failures[28] = Failure(0, true, true, "28 Vol de cuivre")

#=================================== Degradation Model ===================================#
generalOffset = 0.005
    for INDEX in 1:28 
        if T[INDEX] == Inf64
            failures[INDEX].DegradationProbability = Inf64   
        elseif contains(failures[INDEX].Name, "Obstruction des radiateurs")
            var = T[INDEX]/4
            scale = 200 + 50 * INDEX + 200/INDEX

            failures[INDEX].DegradationProbability = (var^0.5 * abs(15 - INDEX) + var^0.5 * 3 * INDEX + var^1.2 * INDEX)/scale
        elseif contains(failures[INDEX].Name, "Corrosion")
            var = T[INDEX]/12
            scale = 100 + 4 * INDEX
            multipl = INDEX - INDEX^2/scale

            failures[INDEX].DegradationProbability = (var * multipl + var^1.7 * multipl)/scale
        elseif contains(failures[INDEX].Name, "Vol")
            reINDEX = INDEX + 3 
            if INDEX ∈ [4, 7, 15]
                reINDEX = 3 + INDEX/5
            end
            var = T[INDEX]
            scale = 100 + reINDEX
            offset = reINDEX/4 - reINDEX^2/(20 * scale)


            failures[INDEX].DegradationProbability = (tanh(var - 1.5) * offset + T[INDEX]^0.6 + offset/(scale * T[INDEX] + INDEX) + 1.2 * offset)/scale
        elseif contains(failures[INDEX].Name, "Obstruction des lignes")
            var = T[INDEX]/4
            scale = 200 

            failures[INDEX].DegradationProbability = var^2 * INDEX/scale
        end
        failures[INDEX].DegradationProbability += generalOffset
    end
#=========================================================================================#

    return failures
end

#=
The "MaintenanceList" function take the periodicity vector "T" and return a vector of maintenances "maintenances" with their periodicity, their list of Failures linked to an efficiency factor and the required time for each maintenace
the "requiredTimeForMaintenances" argument represent the number of houres required for each maintenance type
=#
function MaintenanceList(T, requiredTimeForMaintenances)
    failures = FailureList(T)
    maintenances = Vector{Maintenance}(undef, 28)

    maintenances[1] =  Maintenance(T[1] , [4], [failures[1]], requiredTimeForMaintenances[1])
    maintenances[2] =  Maintenance(T[2] , [4], [failures[2]], requiredTimeForMaintenances[2])
    maintenances[3] =  Maintenance(T[3] , [4], [failures[3]], requiredTimeForMaintenances[3])
    maintenances[4] =  Maintenance(T[4] , [4], [failures[4]], requiredTimeForMaintenances[4])
    maintenances[5] =  Maintenance(T[5] , [4], [failures[5]], requiredTimeForMaintenances[5])
    maintenances[6] =  Maintenance(T[6] , [4], [failures[6]], requiredTimeForMaintenances[6])
    maintenances[7] =  Maintenance(T[7] , [4], [failures[7]], requiredTimeForMaintenances[7])
    maintenances[8] =  Maintenance(T[8] , [4], [failures[8]], requiredTimeForMaintenances[8])
    maintenances[9] =  Maintenance(T[9] , [4], [failures[9]], requiredTimeForMaintenances[9])
    maintenances[10] = Maintenance(T[10], [4], [failures[10]], requiredTimeForMaintenances[10])
    maintenances[11] = Maintenance(T[11], [4], [failures[11]], requiredTimeForMaintenances[11])
    maintenances[12] = Maintenance(T[12], [4], [failures[12]], requiredTimeForMaintenances[12])
    maintenances[13] = Maintenance(T[13], [4], [failures[13]], requiredTimeForMaintenances[13])
    maintenances[14] = Maintenance(T[14], [4], [failures[14]], requiredTimeForMaintenances[14])
    maintenances[15] = Maintenance(T[15], [4], [failures[15]], requiredTimeForMaintenances[15])
    maintenances[16] = Maintenance(T[16], [4], [failures[16]], requiredTimeForMaintenances[16])
    maintenances[17] = Maintenance(T[17], [4], [failures[17]], requiredTimeForMaintenances[17])
    maintenances[18] = Maintenance(T[18], [4], [failures[18]], requiredTimeForMaintenances[18])
    maintenances[19] = Maintenance(T[19], [4], [failures[19]], requiredTimeForMaintenances[19])
    maintenances[20] = Maintenance(T[20], [4], [failures[20]], requiredTimeForMaintenances[20])
    maintenances[21] = Maintenance(T[21], [4], [failures[21]], requiredTimeForMaintenances[21])
    maintenances[22] = Maintenance(T[22], [4], [failures[22]], requiredTimeForMaintenances[22])
    maintenances[23] = Maintenance(T[23], [4], [failures[23]], requiredTimeForMaintenances[23])
    maintenances[24] = Maintenance(T[24], [4], [failures[24]], requiredTimeForMaintenances[24])
    maintenances[25] = Maintenance(T[25], [4], [failures[25]], requiredTimeForMaintenances[25])
    maintenances[26] = Maintenance(T[26], [4], [failures[26]], requiredTimeForMaintenances[26])
    maintenances[27] = Maintenance(T[27], [4], [failures[27]], requiredTimeForMaintenances[27])
    maintenances[28] = Maintenance(T[28], [4], [failures[28]], requiredTimeForMaintenances[28])

    return maintenances
end

#=
The "EquipmentList" function take the periodicity vector "T" and return a vector of equipment "equipments" with the list of failures and maintnances done on this equipment, their name and other unuse arguments. The client list linked to this equipment is not initialized yet.
the "pararequiredTimeForMaintenancesm" argument allow the function to call the function "MaintenanceList"
The "nbVec" argument is used to initialize the redondancy parameter of the equipments
=#
function EquipmentList(T, nbVec, requiredTimeForMaintenances)
    failures = FailureList(T)
    equipments = Vector{Equipment}(undef, 15)
    maintenances = MaintenanceList(T, requiredTimeForMaintenances)

    equipments[1] =  Equipment([], nbVec[11], failures[1:2], true, [maintenances[1], maintenances[2]], "Transformateur élévateur de tension")
    equipments[2] =  Equipment([], 1        , failures[3:4], true, [maintenances[3], maintenances[4]], "Isolateur haute tension")

    equipments[3] =  Equipment([], 1        , [failures[5]], true, [maintenances[5]], "Câble haute tension")
    equipments[4] =  Equipment([], 1        , failures[6:7], true, [maintenances[6], maintenances[7]], "Isolateur haute tension")

    equipments[5] =  Equipment([], nbVec[14], failures[8:9], true, [maintenances[8], maintenances[9]], "Transformateur haute à moyenne tension")
    equipments[6] =  Equipment([], nbVec[13], failures[10:11], true, [maintenances[10], maintenances[11]], "Sectionneur haute tension")
    equipments[7] =  Equipment([], nbVec[12], failures[12:13], true, [maintenances[12], maintenances[13]], "Disjoncteur haute tesnsion")
    equipments[8] =  Equipment([], 1        , failures[14:15], true, [maintenances[14], maintenances[15]], "Isolateur haute tension")

    equipments[9] =  Equipment([], 1        , failures[16:17], true, [maintenances[16], maintenances[17]], "Câble moyenne tension")
    equipments[10] = Equipment([], 1        , failures[18:19], true, [maintenances[18], maintenances[19]], "Isolateur moyenne tension")

    equipments[11] = Equipment([], nbVec[17], failures[20:21], true, [maintenances[20], maintenances[21]], "Transformateur moyenne à basse tension")
    equipments[12] = Equipment([], nbVec[16], failures[22:23], true, [maintenances[22], maintenances[23]], "Sectionneur moyenne tension")
    equipments[13] = Equipment([], nbVec[15], failures[24:25], true, [maintenances[24], maintenances[25]], "Disjoncteur moyenne tension")
    equipments[14] = Equipment([], 1        , failures[26:27], true, [maintenances[26], maintenances[27]], "Isolateur moyenne tension")

    equipments[15] = Equipment([], 1        , [failures[28]], true, [maintenances[28]], "Câble basse tension")

    return equipments
end


#=
The "EquipmentInitialisation" function take the periodicity vector "T" and a seed for the initialization "seedInit" and return a vector of station "stations" containing every equipment in the electrical network with the list of client of each equipment initialized.
the "nbVec" argument allow the function to allocated the network as the user asked
The "requiredTimeForMaintenances" argumnt allow the function to call the function "EquipmentList"
=#
function EquipmentInitialisation(T, nbVec, requiredTimeForMaintenances)
############# Initialisation des paramètres #############
    seedInit = nbVec[19]
    Clients = ClientsInitialisation(nbVec, seedInit)
    Random.seed!(seedInit)

    nbResidence = nbVec[1]
    nbBigEnterprise = nbVec[2]
    nbSmallEntreprises = nbVec[3]
    nbHospitals = nbVec[4]
    nbClient = sum(nbVec[1:4])

    nbProd_HT = nbVec[5]
    nbHT = nbVec[6] 
    nbHT_MT = nbVec[7] 
    nbMT = nbVec[8] 
    nbMT_BT = nbVec[9] 
    nbBT = nbVec[10]
    if T[1] == Inf64
        nbStation = sum(nbVec[8:10])
    else
        nbStation = sum(nbVec[5:10])
    end

    nbTransfoProd_HT = nbVec[11]

    nbDisjonHT = nbVec[12]
    nbSectioHT = nbVec[13]
    nbTransfoHT_MT = nbVec[14]

    nbDisjonMT = nbVec[15]

    nbSectioMT = nbVec[16]
    nbTransfoMT_BT = nbVec[17]


    equipments = EquipmentList(T, nbVec, requiredTimeForMaintenances)

    it = itVecGenerator(nbClient, seedInit)

    residentialConsumption = 0
    for client in Clients[(nbClient - nbResidence + 1):nbClient]
        residentialConsumption += client.AnnualConsumption
    end

    SmallEntreprisesConsumption = 0 
    for client in Clients[(nbBigEnterprise + 1):(nbBigEnterprise + nbSmallEntreprises)]
        SmallEntreprisesConsumption += client.AnnualConsumption
    end

    BigConsumerConsumption = 0 
    for client in Clients
        if (client.Residential == false) && (client.AnnualConsumption >= 1.2 * SmallEntreprisesConsumption/nbSmallEntreprises)
            BigConsumerConsumption += client.AnnualConsumption
        end
    end
    
    stations = [Station([]) for i in 1:nbStation]
############# Initialization of the low voltage transporting lines #############
    i = 1
    LinkedEquipmentConsumption = 0
    for BT in 1:nbBT
        s = stations[BT]
        e = deepcopy(equipments[15])

        while LinkedEquipmentConsumption <= residentialConsumption * BT/nbBT && i <= nbClient
            if Clients[it[i]].Residential == true || Clients[it[i]].AnnualConsumption < 1.2 * SmallEntreprisesConsumption/nbSmallEntreprises
                push!(e.ClientsList, Clients[it[i]])
                LinkedEquipmentConsumption += Clients[it[i]].AnnualConsumption
            end
            i += 1
        end
        push!(s.Equipments, e)
    end

############# Initialization of the medium to low voltage transformation stations #############
    DECAL = nbBT
    distribVec = stationDistribution(nbBT, nbMT_BT)
    decal = 1
    for MT_BT in 1:nbMT_BT
        s = stations[MT_BT + DECAL]
        for transfo in 1:nbTransfoMT_BT
            e = deepcopy(equipments[11])
            push!(s.Equipments, e)
        end
        for sectioneur in 1:nbSectioMT
            e = deepcopy(equipments[12])
            push!(s.Equipments, e)
        end
        for sectioneur in 1:nbDisjonMT
            e = deepcopy(equipments[13])
            push!(s.Equipments, e)
        end
        e = deepcopy(equipments[14])
        push!(s.Equipments, e)

        for equip in s.Equipments
            for i in decal:(distribVec[MT_BT] + decal - 1)
                equip.ClientsList = vcat(equip.ClientsList, stations[i].Equipments[1].ClientsList)
            end
        end
        decal += distribVec[MT_BT]
    end

############# Initialization of the medium voltage transportation lines #############
    decal = DECAL
    DECAL += nbMT_BT
    i = 1
    for MT in 1:nbMT
        s = stations[MT + DECAL]
        e = deepcopy(equipments[9])
        push!(s.Equipments, e)
        e = deepcopy(equipments[10])
        push!(s.Equipments, e)

        LinkedBigConsumerConsumption = 0
        for equip in s.Equipments
            equip.ClientsList = deepcopy(stations[MT + decal].Equipments[1].ClientsList)
        end
        while (LinkedBigConsumerConsumption <= BigConsumerConsumption/nbMT && i <= nbClient) || i <= nbClient 
            if (Clients[it[i]].Residential == false) && (Clients[it[i]].AnnualConsumption >= 1.2 * SmallEntreprisesConsumption/nbSmallEntreprises) || Clients[it[i]].MustBeInService == true 
                for equip in s.Equipments
                    push!(equip.ClientsList, Clients[it[i]])
                    LinkedBigConsumerConsumption += Clients[it[i]].AnnualConsumption
                end
            end
            i += 1
        end
    end
 
    if T[1] != Inf64
############# Initialization of the high to medium voltage transformation stations #############
        distribVec = stationDistribution(nbMT, nbHT_MT)
        decal = DECAL
        DECAL += nbMT
        for HT_MT in 1:nbHT_MT
            s = stations[HT_MT + DECAL]
            for transfo in 1:nbTransfoHT_MT
                e = deepcopy(equipments[5])
                push!(s.Equipments, e)
            end
            for sectioneur in 1:nbSectioHT
                e = deepcopy(equipments[6])
                push!(s.Equipments, e)
            end
            for Disjoncteur in 1:nbDisjonHT
                e = deepcopy(equipments[7])
                push!(s.Equipments, e)
            end
            e = deepcopy(equipments[8])
            push!(s.Equipments, e)

            for equip in s.Equipments
                for i in (decal + 1):(distribVec[HT_MT] + decal)
                    equip.ClientsList = vcat(equip.ClientsList, stations[i].Equipments[1].ClientsList)
                end
            end
            decal += distribVec[HT_MT]

        end

############# Initialization of the high voltage transporting lines #############
        decal = DECAL
        DECAL += nbHT_MT
        for HT in 1:nbHT 
            s = stations[HT + DECAL]
            e = deepcopy(equipments[3])
            push!(s.Equipments, e)
            e = deepcopy(equipments[4])
            push!(s.Equipments, e)
            for equip in s.Equipments
                equip.ClientsList = deepcopy(stations[HT + decal].Equipments[1].ClientsList)
            end 
        end

############# Initialization of the electric production to high voltage transformation stantions #############
        distribVec = stationDistribution(nbHT, nbProd_HT)
        decal = DECAL
        DECAL += nbHT
        for prod_HT in 1:nbProd_HT
            s = stations[prod_HT + DECAL]
            for transfo in 1:nbTransfoProd_HT
                e = deepcopy(equipments[1])
                push!(s.Equipments, e)
            end

            e = deepcopy(equipments[2])
            push!(s.Equipments, e)
            for equip in s.Equipments
                for i in (decal + 1):(distribVec[prod_HT] + decal)
                    equip.ClientsList = vcat(equip.ClientsList, stations[i].Equipments[1].ClientsList)
                end
            end
            decal += distribVec[prod_HT]
        end
    end

    return stations
end

GC.gc()
