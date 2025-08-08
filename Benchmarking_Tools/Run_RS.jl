BENCHMARK_HOME = @__DIR__
dir = @__DIR__
splitDir = split(dir, "/") 
newSplitDir = Vector{SubString}(undef, length(splitDir) - 1)
for i in 1:(length(splitDir) - 1)
    newSplitDir[i] = splitDir[i]
end
newDir = join(newSplitDir, "/")
include("$newDir/src/MiniPRIAD.jl")

function cOkay(FFC)
    for i in 3:11
        if FFC[i] > 0
            return false
        end
    end
    return true
end

for instance in [3]#[1, 2, 3]
    for input_length in [13]#[13, 15, 28]
        ACTUAL_FILE_PATH = "$BENCHMARK_HOME/RS_results/instance=$instance/input_length=$input_length"
        mkpath(ACTUAL_FILE_PATH)
        ϕ = 0.1
        seedMC = 0
        loggingTime = "$ACTUAL_FILE_PATH/loggingTime.txt"
        io = open("$ACTUAL_FILE_PATH/ARGS.txt", "w")
        write(io, "fidelity	$ϕ\n")
        write(io, "seed	$seedMC\n")
        write(io, "instance	$instance\n")
        write(io, "loggingTime $loggingTime\n")
        close(io)
        io_output = open("$ACTUAL_FILE_PATH/rs_output.txt", "w")
        io_x = open("$ACTUAL_FILE_PATH/rs_x.txt", "w")
        for i in 1:100000
            if input_length == 13
                x = Vector{Float64}(undef, 13)
                for j in 1:13
                    if j ∈ [1,3,5,7,9,11]
                        x[j] = rand(1:9)
                    else
                        x[j] = rand() * 9.9 + 0.1
                    end
                end
            elseif input_length == 15
                x = Vector{Float64}(undef, 15)
                for j in 1:15
                    x[j] = rand() * 9.9 + 0.1
                end
            else
                x = Vector{Float64}(undef, 28)
                for j in 1:28
                    if j ∈ [1,3,6,8,10,12,14,16,18,20,22,24,26]
                        x[j] = rand(1:9)
                    else
                        x[j] = rand() * 9.9 + 0.1
                    end
                end
            end
            FFC_str = split(MiniPRIAD(x, 0.001, 0, loggingTime = loggingTime))

            FFC = Vector{Float64}(undef, 11)
            for k in 1:11
                FFC[k] = parse(Float64, String(FFC_str[k]))
            end

            if cOkay(FFC)
                feas = "{ feasible } "
            else
                feas = ""
            end
            write(io_x, join(x, " ") * "\n")
            write(io_output, "$feas $FFC \n")
        end
        close(io_x)
        close(io_output)
    end
end
