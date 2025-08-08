BENCHMARK_HOME = @__DIR__
NOMAD_HOME = ARGS[1]

splitDir = split(BENCHMARK_HOME, "/") 
newSplitDir = Vector{SubString}(undef, length(splitDir) - 1)
for i in 1:(length(splitDir) - 1)
    newSplitDir[i] = splitDir[i]
end
MINI_PRIAD_HOME = join(newSplitDir, "/")

if contains(NOMAD_HOME, "/bin")
    if contains(NOMAD_HOME, "/bin/")
    else
        NOMAD_HOME = "$NOMAD_HOME/"
    end
else
    if NOMAD_HOME[end] == '/'
        NOMAD_HOME = "$(NOMAD_HOME)bin/"
    else
        NOMAD_HOME = "$NOMAD_HOME/bin/"
    end
end

for instance in 1:3
    for input_length in [13, 15, 28]
        ACTUAL_FILE_PATH = "$BENCHMARK_HOME/NOMAD_results/instance=$instance/input_length=$input_length"
        mkpath(ACTUAL_FILE_PATH)

        io = open("$MINI_PRIAD_HOME/Tests/instance=$instance/length_input=$input_length/feasible/1.txt", "r")
        lines = readlines(io)
        close(io)
        
        io = open("$ACTUAL_FILE_PATH/nomad_param.txt", "w")
            write(io, "DIMENSION            $input_length\n")
            write(io, "BB_EXE               \"\$julia \$MINI_PRIAD_HOME/src/run.jl $ACTUAL_FILE_PATH/ARGS.txt\"\n\n")
            write(io, "BB_OUTPUT_TYPE       CNT_EVAL OBJ PB PB PB PB PB PB PB PB PB\n")
        if input_length == 13
            write(io, "BB_INPUT_TYPE        ( I  R   I  R   I  R   I  R   I  R   I  R    R   )\n")
            write(io, "LOWER_BOUND          ( 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 0.10 )\n")
            write(io, "X0                   ( $(lines[1]) )\n")
            write(io, "UPPER_BOUND          ( 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 10.0 )\n")
        elseif input_length == 15
            write(io, "BB_INPUT_TYPE        ( R     R    R    R    R   R     R    R    R    R   R     R    R    R    R   )\n")
            write(io, "LOWER_BOUND          ( 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 )\n")
            write(io, "X0                   ( $(lines[1]) )\n")
            write(io, "UPPER_BOUND          ( 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 )\n")
        elseif input_length == 28
            write(io, "BB_INPUT_TYPE        ( I  R   I  R    R   I  R   I  R   I  R   I  R   I  R   I  R   I  R   I  R   I  R   I  R   I  R    R   )\n")
            write(io, "LOWER_BOUND          ( 1 0.10 1 0.10 0.10 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 1 0.10 0.10 )\n")
            write(io, "X0                   ( $(lines[1]) )\n")
            write(io, "UPPER_BOUND          ( 9 10.0 9 10.0 10.0 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 9 10.0 10.0 )\n")
        end
            write(io, "seed                 0\n\n")
            write(io, "display_stats        bbe { success_type } [bbo] gen_step\n")
            write(io, "display_all_eval     yes\n")
            write(io, "history_file         history.txt\n\n")
            write(io, "STATS_FILE	        bbe { success_type } [bbo]\n")
            write(io, "MAX_TIME	            115200")
        close(io)
        io = open("$ACTUAL_FILE_PATH/ARGS.txt", "w")
        write(io, "fidelity	1.0\n")
        write(io, "seed	0\n")
        write(io, "instance	$instance\n")
        write(io, "loggingTime $ACTUAL_FILE_PATH/loggingTime.txt")
        close(io)
        run(pipeline(`$(NOMAD_HOME)nomad $ACTUAL_FILE_PATH/nomad_param.txt`, stdout = open("$ACTUAL_FILE_PATH/nomad_output.txt", "w")))
        #run(`$(NOMAD_HOME)nomad $ACTUAL_FILE_PATH/nomad_param.txt`)
    end
end

