#######################################################################################################################
#=====================================================================================================================#
#= ################################################################################################################# =#
#= #  This is the only file that the users should modify to choose the instance                                    # =#
#= #                                                                                                               # =#
#= #  Only variable in comment square like this one should be modify by users                                      # =#
#= #                                                                                                               # =#
#= #  The users can either choose to use a predefined instance by initializing the "instance" variable to an       # =#
#= #  instance index ∈ [1] or to create is own problem by changing the values in comment box like this one         # =#
#= #                                                                                                               # =#
#= ################################################################################################################# =#
#=====================================================================================================================#
#######################################################################################################################

#=
function initInstance()
#######################################################################################################################
#=====================================================================================================================#
#==#################################################################################################################==#
#==# instance = 1 # parameter that control the instance, if initialize to an non defenite istance index will use   #==#
#==#               # the values specified by the user. defined instance index : [1]                                #==#
#==#################################################################################################################==#
#=====================================================================================================================#
#######################################################################################################################
    return instance
end
=#
#=
the "nbParam" function is hardcoded and allow the user to define their own problems by changing the electic network size, the redondancy and the influence off each station in the network
    the "message" input is taken care off by the program, it simply ask to return or not the warning message
=#
function nbParam(instance::Int64)
#######################################################################################################################
#=====================================================================================================================#
#==#################################################################################################################==#
#==#                                                                                                               #==#
#================================== To fill by the user if instance ∉ [1, 2, 3]=======================================#
#==#                                                                                                               #==#
#==################################## number of each type of client ################################################==#
#==# nbResidence = 10       # static number of residential client                                                 #==#
#==# nbBigEnterprise = -1    # static number of big entreprises, if negative will be attributed by calculation     #==#
#==# nbSmallEntreprises = -1 # static number of small entreprises, if negative will be attributed by calculation   #==#
#==# nbHospitals = -1        # static number of hospitals, if negative will be attributed by calculation           #==#
#==#                                                                                                               #==#
#==################################### number of each type of station ##############################################==#
#==#  nbProd_HT = 1 # static number of electicity production to high voltage transformation stations               #==#
#==#  nbHT = 1      # static number of high voltage transportation lines -> must be equal : nbHT = nbHT_MT         #==#
#==#  nbHT_MT = 1   # static number of high voltage to medium voltage transformation stations                      #==#
#==#  nbMT = 2      # static number of medium voltage transportation lines -> must be equal : nbMT = nbMT_BT       #==#
#==#  nbMT_BT = 2   # static number of medium voltage to low voltage transformation stations                       #==#
#==#  nbBT = 4      # static number of low voltage transportation cables                                           #==#
#==#                                                                                                               #==#
#==######### number of each type of equipment in every transformation station : control the redondancy #############==#
#==#  nbTransfoProd_HT = 2 # static number of production to high voltage transformer in an electricity             #==#
#==#                       # production to high voltage station                                                    #==#
#==#  nbDisjonHT = 2       # static number of high voltage breaker by high to medium voltage station               #==#
#==#  nbSectioHT = 2       # static number of high voltage disconnector by high to medium voltage station          #==#
#==#  nbTransfoHT_MT = 2   # static number of high to medium voltage transformer by high to medium voltage station #==#
#==#                                                                                                               #==#
#==#  nbDisjonMT = 2       # static number of medium voltage breaker by medium to low voltage station              #==#
#==#  nbSectioMT = 2       # static number of medium voltage disconnector by medium to low voltage station         #==#
#==#  nbTransfoMT_BT = 2   # static number of medium to low voltage transformer by medium to low voltage station   #==#
#==#                                                                                                               #==#
#==######################### random seed controling the initialization of the network ##############################==#
#==#  seedInit = 8172                                                                                              #==#
#==#                                                                                                               #==#
#==#################################################################################################################==#
#=====================================================================================================================#
#######################################################################################################################

#instance = initInstance()

    #================================================ Instance 1 ============================================================#
    if instance == 1
        nbResidence = 1000
        nbBigEnterprise = -1
        nbSmallEntreprises = -1
        nbHospitals = -1

        nbProd_HT = 1
        nbHT = 1                     
        nbHT_MT = 1
        nbMT = 2
        nbMT_BT = 2
        nbBT = 4

        nbTransfoProd_HT = 2
        nbDisjonHT = 2
        nbSectioHT = 2
        nbTransfoHT_MT = 2
        nbDisjonMT = 2
        nbSectioMT = 2
        nbTransfoMT_BT = 2

        seedInit = 8172
    #================================================ Instance 2 ============================================================#
    elseif instance == 2
        nbResidence = 1000
        nbBigEnterprise = 0
        nbSmallEntreprises = 90
        nbHospitals = -1

        nbProd_HT = 1
        nbHT = 1                     
        nbHT_MT = 1
        nbMT = 1
        nbMT_BT = 10
        nbBT = 16

        nbTransfoProd_HT = 1
        nbDisjonHT = 1
        nbSectioHT = 1
        nbTransfoHT_MT = 1
        nbDisjonMT = 1
        nbSectioMT = 1
        nbTransfoMT_BT = 1

        seedInit = 0
    #================================================ Instance 3 ============================================================#
    elseif instance == 3
        nbResidence = 5000
        nbBigEnterprise = -1
        nbSmallEntreprises = -1
        nbHospitals = -1

        nbProd_HT = 1
        nbHT = 1                     
        nbHT_MT = 1
        nbMT = 2
        nbMT_BT = 2
        nbBT = 4

        nbTransfoProd_HT = 2
        nbDisjonHT = 2
        nbSectioHT = 2
        nbTransfoHT_MT = 2
        nbDisjonMT = 1
        nbSectioMT = 1
        nbTransfoMT_BT = 1

        seedInit = 93655
    end
    #========================================================================================================================#



    if nbBigEnterprise < 0
        nbBigEnterprise = floor(Int, (nbResidence * 2.3 * 0.003))     # = nbResidence * nbPersoneParResidence * 0.3%
    end
    if nbSmallEntreprises < 0
        nbSmallEntreprises = floor(Int, (nbResidence * 2.3 / 40))      # = nbResidence * nbPersoneParResidence/nbPersonneParPetiteEntreprise
    end
    if nbHospitals < 0
        nbHospitals = ceil(Int, (nbResidence * 2.3 / 62000))           # = nbResidence * nbPersoneParResidence/nbPersonneParHopital
    end

    nbVec = Vector{Int64}(undef, 19)

    nbVec[1] = nbResidence
    nbVec[2] = nbBigEnterprise
    nbVec[3] = nbSmallEntreprises
    nbVec[4] = nbHospitals

    nbVec[5] = nbProd_HT
    nbVec[6] = nbHT
    nbVec[7] = nbHT_MT
    nbVec[8] = nbMT
    nbVec[9] = nbMT_BT
    nbVec[10] = nbBT

    for i in 6:10
        if nbVec[i] < nbVec[i - 1]
            nbVec[i] = nbVec[i - 1]
            @warn "Problem in the number of stations entered: nbVec[$i] < nbVec[$(i - 1)] => nbVec[$i] := nbVec[$(i - 1)]"
        end
    end

    nbVec[11] = nbTransfoProd_HT
    nbVec[12] = nbDisjonHT
    nbVec[13] = nbSectioHT
    nbVec[14] = nbTransfoHT_MT
    nbVec[15] = nbDisjonMT
    nbVec[16] = nbSectioMT
    nbVec[17] = nbTransfoMT_BT

    nbEquip = nbProd_HT *  (nbTransfoProd_HT + 1) + nbVec[6] * (2) + nbVec[7] * (nbDisjonHT + nbSectioHT + nbTransfoHT_MT + 1) + nbVec[8] * (2) + nbVec[9] * (nbDisjonMT + nbSectioMT + nbTransfoMT_BT + 1) + nbVec[10] * (1)

    nbVec[18] = nbEquip

    nbVec[19] = seedInit

    for i in 1:19
        if typeof(nbVec[i]) != Int64
            nbVec[i] = Int(round(nbVec[i]))
            @warn "The nbVec[$i] was not an Int, it was rounded to nbVec[$i] = $(nbVec[i])"
        end
        if nbVec[i] < 0
            nbVec[i] = abs(nbVec[i])
            @warn "The nbVec[$i] was negative: nbVec[$i] := abs(nbVec[$i])"
        end
    end

    return nbVec
end

function MaintenancesParam(instance::Int64)
######################################################################################################################################################################################################
#====================================================================================================================================================================================================#
#==################################################################################################################################################################################################==#
#==#                                                                                                                                                                                              #==#
#========================================================================== To fill by the user if instance ∉ [1, 2, 3] =============================================================================#
#==# requiredTimeForMaintenances = [4.5, 0.5, 3.5, 0.5,    6.5, 3.5, 0.5,    4.5, 0.5, 3.5, 0.5, 3.5, 0.5, 3.5, 0.5,    8.5, 0.5, 3.5, 0.5,    3.5, 0.5, 3.5, 0.5, 3.5, 0.5, 3.5, 0.5,    0.5]    #==#
#==# # number of time required to perform each of the 28 planed maintenances                                                                                                                      #==#
#==#                                                                                                                                                                                              #==#
#==################################################################################################################################################################################################==#
#====================================================================================================================================================================================================#
######################################################################################################################################################################################################

#instance = initInstance()

    #================================================================================= Instance 1 =============================================================================================#
    if instance == 1
        requiredTimeForMaintenances = [4.0,  0.5, 3.5,  0.5,    6.0, 3.5,  0.5,    4.0,  0.5, 3.5,  0.5, 3.5,  0.5, 3.5,  0.5,      8.0,  0.5, 3.5,  0.5,    3.5, 0.5, 3.5, 0.5, 3.5, 0.5, 3.5, 0.5,        0.5]
    #================================================================================= Instance 2 =============================================================================================#
    elseif instance == 2
        requiredTimeForMaintenances = [5.5,  1.0, 4.5,  1.0,    6.5, 4.5,  1.0,    5.5,  1.0, 4.5,  1.0, 4.5,  1.0, 4.5,  1.0,      8.5, 0.5, 3.5, 0.5,      3.5, 0.5, 3.5, 0.5, 3.5, 0.5, 3.5, 0.5,        0.5]
    #================================================================================= Instance 3 =============================================================================================#
    elseif instance == 3
        requiredTimeForMaintenances = [5.0, 0.75, 5.0, 0.75,    5.5, 5.0, 0.75,    5.0, 0.75, 5.0, 0.75, 5.0, 0.75, 5.0, 0.75,      6.0, 0.333, 2.5,0.333,    2.5, 0.333, 2.5, 0.333, 2.5, 0.333, 2.5, 0.333, 0.333]
    end
    #==========================================================================================================================================================================================#

    for i in 1:28
        if requiredTimeForMaintenances[i] == 0
            requiredTimeForMaintenances[i] = 1.0
            @warn "requiredTimeForMaintenances[$i] need to be positive but was equal to 0: requiredTimeForMaintenances[$i] := 1"
        elseif requiredTimeForMaintenances[i] < 0
            requiredTimeForMaintenances[i] = abs(requiredTimeForMaintenances[i])
            @warn "requiredTimeForMaintenances[$i] need to be positive but was negative: requiredTimeForMaintenances[$i] := abs(requiredTimeForMaintenances[$i])"
        end
    end

    return requiredTimeForMaintenances
end

function FailuresParam(instance::Int64)
######################################################################################################################################################################################################
#====================================================================================================================================================================================================#
#==################################################################################################################################################################################################==#
#==#                                                                                                                                                                                              #==#
#==================================================================================== To fill by the user if instance ∉ [1, 2, 3] ===================================================================#
#==# requiredTimeToRepairFailures = [18, 4.5, 6.5, 5.5,    12.5, 6.5, 5.5,    18, 4.5, 6.5, 5.5, 6.5, 5.5, 6.5, 5.5,    16, 5.5, 6.5, 5.5,    6.5, 5.5, 6.5, 5.5, 6.5, 5.5, 6.5, 5.5,    5.5]     #==#
#==# # number of time required to perform each of the 28 repairs after a failure                                                                                                                  #==#
#==#                                                                                                                                                                                              #==#
#==################################################################################################################################################################################################==#
#====================================================================================================================================================================================================#
######################################################################################################################################################################################################

#instance = initInstance()

    #================================================================================= Instance 1 =============================================================================================#
    if instance == 1
        requiredTimeToRepairFailures = [18, 4.5, 6.5, 5.5,    12.0, 6.5, 5.5,    18, 4.5, 6.5, 5.5, 6.5, 5.5, 6.5, 5.5,    16,  5.5, 6.5,  5.5,     6.5,  5.5,  6.5,  5.5,  6.5,  5.5,  6.5,  5.5,    5.0]
    #================================================================================= Instance 2 =============================================================================================#
    elseif instance == 2
        requiredTimeToRepairFailures = [20.25, 5.5, 7.5, 6.5,    13.5, 7.5, 6.5,    20.25, 5.5, 7.5, 6.5, 7.5, 6.5, 7.5, 6.5,    16.25,  6.0, 7.0,  6.0,     7.0,  6.0,  7.0,  6.0,  7.0,  6.0,  7.0,  6.0,    6.25]
    #================================================================================= Instance 3 =============================================================================================#
    elseif instance == 3
        requiredTimeToRepairFailures = [19, 5.5, 7.0, 5.0,    12.5, 7.0, 5.0,    19, 5.5, 7.0, 5.0, 7.0, 5.0, 7.0, 5.0,    14, 4.75, 6.25, 4.75,    6.25, 4.75, 6.25, 4.75, 6.25, 4.75, 6.25, 4.75,    4.75]
    end
    #==========================================================================================================================================================================================#

    for i in 1:28
        if requiredTimeToRepairFailures[i] == 0
            requiredTimeToRepairFailures[i] = 1.0
            @warn "requiredTimeToRepairFailures[$i] need to be positive but was equal to 0: requiredTimeToRepairFailures[$i] := 1" maxlog=1
        elseif requiredTimeToRepairFailures[i] < 0
            requiredTimeToRepairFailures[i] = abs(requiredTimeToRepairFailures[i])
            @warn "requiredTimeToRepairFailures[$i] need to be positive but was negative: requiredTimeToRepairFailures[$i] := abs(requiredTimeToRepairFailures[$i])" maxlog=1
        end
    end

    return requiredTimeToRepairFailures
end

#GC.gc()
