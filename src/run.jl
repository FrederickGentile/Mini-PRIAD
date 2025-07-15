include("MiniPRIAD.jl")


#########################################################################################################################
#===================== arguments to modify if you chose to call the blackbox with only a x.txt file ====================#
#==###################################################################################################################==#
#==# ϕ = 1.0                                                                                                         #==#
#==# seedMC = 0                                                                                                      #==#
#==# continueEval = basicContinueEval # don't forget to include your .jl if you use your continueEval julia function #==#
#==# instance = 1                                                                                                    #==#
#==# loggingTime = "false"                                                                                           #==#
#==###################################################################################################################==#
#=======================================================================================================================#
#########################################################################################################################

if length(ARGS) == 1
    io = open(ARGS[1], "r")
    lines = readlines(io)
    close(io)

    splitLine = split(lines[1])
    input = Vector{Float64}(undef, length(splitLine))

    for i in 1:length(splitLine)
        input[i] = parse(Float64, splitLine[i])
    end

    println(MiniPRIAD(input, ϕ, seedMC, continueEval=continueEval, param=instance, loggingTime=loggingTime))
elseif length(ARGS) == 2
    dir = @__DIR__
    pathToContinueEvaljlFile = "$dir/MiniPRIAD.jl"
    continueEval_name = "basicContinueEval"

    io = open(ARGS[1], "r")
    lines = readlines(io)
    close(io)

    for elem in lines
        if elem != ""
            local splitLine = split(elem)
            if contains(splitLine[1], "#") == false
                if splitLine[1] == "fidelity"
                    global ϕ = parse(Float64, splitLine[2])
                    if ϕ > 1 || ϕ <= 0 
                        global ϕ = 1.0
                        @warn "The value of the fidelity was not a float included in ]0, 1], it was set to maximum fidelity 1.0"
                    end
                elseif splitLine[1] == "seed"
                    if parse(Float64, splitLine[2]) % 1 > 10^(-20)
                        @warn "The value of the seed was not integer in the ARGS_FILE, it was rounded"
                    end
                    global seedMC = Int(round(parse(Float64, splitLine[2])))
                elseif splitLine[1] == "continueEval"
                    global pathToContinueEvaljlFile = splitLine[2]
                    global continueEval_name = splitLine[3]
                elseif splitLine[1] == "instance"
                    if parse(Float64, splitLine[2]) % 1 > 10^(-20)
                        @warn "The value of the instance was not integer in the ARGS_FILE, it was rounded"
                    end
                    global instance = parse(Int64, splitLine[2])
                elseif splitLine[1] == "loggingTime"
                    if splitLine[2] == "1" || splitLine[2] == "0" || splitLine[2] == "true" || splitLine[2] == "false" 
                        global loggingTime = "$(parse(Bool, splitLine[2]))"
                    elseif contains(splitLine[2], ".txt")
                        global loggingTime = splitLine[2]
                    else
                        global loggingTime = false
                        @warn "The value entered for the loggingTime argument was not of a type asked, it was considered as \"false\""
                    end
                else 
                    @warn "did not recognize the argument \"$splitLine[1]\" in the ARGS_FILE, it was ignored"
                end
            end
        end
    end

    io = open(ARGS[2], "r")
    lines = readlines(io)
    close(io)

    splitLine = split(lines[1])
    input = Vector{Float64}(undef, length(splitLine))
    for i in 1:length(splitLine)
        input[i] = parse(Float64, splitLine[i])
    end

    include(pathToContinueEvaljlFile)

    continueEval_symbol = Symbol(continueEval_name)
    continueEval = getfield(Main, continueEval_symbol)

    println(MiniPRIAD(input, ϕ, seedMC, continueEval=continueEval, param=instance, loggingTime=String(loggingTime)))
else
    print(" \n \nTo run a simulation, there are three options. you can eighter : \n
\t- type `\$MiniPRIAD_HOME/src/run.jl ARGS.txt x.txt` where the `ARGS.txt` contains the necessary information to call the blackbox or \n
\t- type `\$MiniPRIAD_HOME/src/run.jl x.txt` where the necessary information to call the blackbox is in comment box in green in the `run.jl` file or \n
\t- call the MiniPRIAD Julia function direcly in a Julia sript if your solver is defined in Julia (don't forget to include \"MiniPRIAD.jl\"). \n
\n
The `ARGS.txt` file contains the same informations that you would need to define in Julia if you chose to second or third execution option. It contains the folowing arguments and formated like in the `ex_ARGS.txt` files located in each folder in `\$MiniPRIAD_HOME/Tests` : \n
\t- fidelity: It is a reel number bounded by 0 and 1, 0 excluded that represent the output fidelity to the reality. \n
\t- seed: It is a integer number that represent the random seed used for Monte-Carlos trials. \n
\t- instance: It is an integer that can take the values [1, 2, 3] to represent an instance number or any other integer to represent the home made instance that you can modify in the file `\$MiniPRIAD_HOME/src/Param.jl`. This argument control the type of electrical network used in the balckbox but does not chhange the number of constaint and does not affet the input length. \n
\t- loggingTime: It is an argument that if specified to \"false\" does not do anything but if specified to a path, will creat a timeLog file where each line of the .txt file represent the execution time of an iteration. \n
\t- continueEval: It is a function that you can redefine in Julia that would replace the basic function implemented in Mini-PRIAD that always return true, this function is a function that takes is called often in the blackbox at different fidelity. It give to continueEval function intermediate value of the objective function and the constraint with the associated fidelity, this function then chose to interupte the blackbox iteration or let it continue. In the ARGS.txt file the path to the .jl file contaning the Julia function and the name of the Julia function need to be specified. \n
Only the seed and the fidelity needs to be inisialized the other variable are optional. \n
\n
The `x.txt` file contains the input vector that can takes diferent sizes: \n
input: It is the blackbox input of 28, 15 or 13 dimentions, including integer (I) and reel (R) inputs, the diferent input are defined like so: \n
\t- 28 dimention input: [I, R, I, R, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, R] \n
\t- 15 dimention input: [R, R, R, R, R, R, R, R, R, R, R, R, R, R, R] \n
\t- 13 dimention input: [I, R, I, R, I, R, I, R, I, R, I, R, R] \n
The `x.txt` file must contains only the numerical value of each variable seperated with spaces without \"[\", \",\" or \"[\" \n
For all integer input the recommanded bounds are 1 and 9 and for all reel input the recommanded bounds are 0.1 and 10.0 \n \n")
end
