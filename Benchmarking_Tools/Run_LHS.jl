using Surrogates
BENCHMARK_HOME = @__DIR__
dir = @__DIR__
splitDir = split(dir, "/") 
newSplitDir = Vector{SubString}(undef, length(splitDir) - 1)
for i in 1:(length(splitDir) - 1)
    newSplitDir[i] = splitDir[i]
end
newDir = join(newSplitDir, "/")
include("$newDir/src/MiniPRIAD.jl")

function COkay(FFC)
    for i in 3:11
        if FFC[i] > 0
            return false
        end
    end
    return true
end

function hCalculator(FFC)
    h = 0.0
    for i in 3:11
        if FFC[i] > 0
            h += FFC[i]
        end
    end
    return h
end

function precedes(FFC1, FFC2)
    if COkay(FFC1) && COkay(FFC2)
        return FFC1[2] < FFC2[2]
    elseif COkay(FFC1) || COkay(FFC2)
        return COkay(FFC1)
    else
        return hCalculator(FFC1) < hCalculator(FFC2)
    end
end

best_FFC = [Inf64 for i in 1:11]

for instance in [3]# [1, 2, 3]
    for input_length in [13]#[13, 15, 28]
        ACTUAL_FILE_PATH = "$BENCHMARK_HOME/LHS_results(1)/instance=$instance/input_length=$input_length"
        mkpath(ACTUAL_FILE_PATH)
        ϕ = 0.1
        seedMC = 0
        loggingTimeFile = "$ACTUAL_FILE_PATH/loggingTime.txt"
        io = open("$ACTUAL_FILE_PATH/ARGS.txt", "w")
        write(io, "fidelity	$ϕ\n")
        write(io, "seed	$seedMC\n")
        write(io, "instance	$instance\n")
        write(io, "loggingTime $loggingTimeFile\n")
        close(io)

        if input_length == 13
            lb = [1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 0.1]
            ub = [10.0 for i in 1:13]
        elseif input_length == 15
            lb = [0.1 for i in 1:15]
            ub = [10.0 for i in 1:15]
        elseif input_length == 28
            lb = [1.0, 0.1, 1.0, 0.1, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 1.0, 0.1, 0.1]
            ub = [10.0 for i in 1:28]
        end
        
        LHS_Samples = sample(10000000, lb, ub, LatinHypercubeSample())
#=
        io_x = open("$ACTUAL_FILE_PATH/lhs_x.txt", "w")
        for i in 1:10000000
            if input_length == 13
                x = collect(LHS_Samples[i])
                x_str = ""
                for j in 1:13
                    if j ∈ [1,3,5,7,9,11]
                        x[j] = floor(x[j])
                    end
                    x_str *= string(x[j]) * " "
                end
            elseif input_length == 28
                x = collect(LHS_Samples[i])
                for j in 1:28
                    if j ∈ [1,3,6,8,10,12,14,16,18,20,22,24,26]
                        x[j] = floor(x[j])
                    end
                    x_str *= string(x[j]) * " "
                end
            else input_length == 15
                x = collect(LHS_Samples[i])
                x_str *= string(x[j]) * " "
            end
            write(io_x, "$x_str\n")
        end

        close(io_x)
=#
        io_x = open("$ACTUAL_FILE_PATH/lhs_x.txt", "r")
        x_lines = readlines(io_x)
        close(io_x)

        io_output = open("$ACTUAL_FILE_PATH/lhs_output.txt", "w")
        for i in 1:10000000
            split_x_line = split(x_lines[i])
            x = [parse(Float64, String(split_x_line[j])) for j in 1:input_length]
            FFC_str = split(MiniPRIAD(x, 0.001, 0, loggingTime = loggingTimeFile))
            FFC = Vector{Float64}(undef, 11)
            for k in 1:11
                FFC[k] = parse(Float64, String(FFC_str[k]))
            end

            if precedes(FFC, best_FFC)
                success_type = "{ Full success (dominating) } "
                global best_FFC = FFC
            else
                success_type = "{ Failure } "
            end
            write(io_output, "$success_type  $FFC  \n")
        end
        close(io_output)
    end
end
