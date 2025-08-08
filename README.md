# Mini-PRIAD v1.0 (August 2025)

> Note: **Mini_PRIAD** has been developed on Linux, there is no guanrantee that the blackbox behavior is the same on other OS like Windows or Mac

## Download
To download the **Mini-PRIAD** blackbox you must have Julia instaled on your computer. skip the section **downloading Julia** if you already have Julia installed on your computer.
### Downloading Julia
You can dowload Julia simply by running the following command in the terminal:
```
curl -fsSL https://install.julialang.org | sh
```
You should now have julia installed on your computer you can verify by typing 
```
julia
```
in the terminal.
> Note: You might need to load the julia module for the future use.
### Downloading Mini-PRIAD
 Now you only need to download the folder `Mini-PRIAD`. To use the commands descibded later, you need to initialize the environment variable  `$MINI_PRIAD_HOME`. To create a environment variable you need to open `~/.bashrc` by running the following command in the terminal:
```
nano ~/.bashrc
```
Then, in the opened file, you initialize the environment variable `MINI_PRIAD_HOME`, after the first line in the opened file, by writing:
```
MINI_PRIAD_HOME="pathToMini-PRIAD/Mini-PRIAD"
```
where pathToMini-PRIAD is the directory where the folder `Mini-PRIAD` was downloaded. Save the modification and escape the document. Now to enable the new varible you need to run the following line in the terminal:
```
source ~/.bashrc
```
To make sure you did everything right, you can try to run the following in the terminal, it should work without error:
```
julia $MINI_PRIAD_HOME/src/run.jl $MINI_PRIAD_HOME/Tests/instance=1/ex_ARGS.txt $MINI_PRIAD_HOME/Tests/instance=1/length_input=28/x0_feasible/1.txt
```
The expected output of the line above, at least on Linux, is:
```
1.0 8.366029399673888e7 -86.2108427279171 -133.34979556884016 -101.86803500570402 -2.7152453166949755 -18.998570154550002 -21.970726472939646 -46.44126470557973 -14.048589173281641 -45.02120170604803
```
> Note: The commands above work on Linux, but migth not work on other OS
## Execution
### Different way to run Mini-PRIAD
To run a simulation, there are three options.

#### Option 1:

Type the following command in the terminal
```
julia $MINI_PRIAD_HOME/src/run.jl pathToARGS/ARGS.txt pathToX/x.txt
```
where the `ARGS.txt` contains the necessary information to call the blackbox and `x.txt` contains the point to evaluate (see below for formating of those files).

#### Option 2:

Type the following command in the terminal
```
julia $MINI_PRIAD_HOME/src/run.jl pathToX/x.txt
```
where the necessary information to call the blackbox is in a green commented box in the `run.jl` file (you can modify the .jl file to modify the arguments that would have been in `ARGS.txt` in option 1) and the `x.txt` contains the point to evaluate.

#### Option 3:

Simply call the MiniPRIAD Julia function direcly in a Julia sript if your solver is defined in Julia (don't forget to include "MiniPRIAD.jl" in your script).

### Files formating
The `ARGS.txt` file contains the same informations that you would need to define in Julia if you chose the execution option 2 or 3. It contains the folowing arguments and formated like in the `ex_ARGS.txt` files located in each folder in `$MINI_PRIAD_HOME/Tests` : 
```
- fidelity: It is a reel number bounded by 0 and 1, 0 excluded that represent the output fidelity to the reality.
- seed: It is a integer number that represent the random seed used for Monte-Carlos trials.
- instance: It is an integer that can take the values [1, 2, 3] to represent an instance number or any other integer to represent the home made instance that you can modify in the file `$MINI_PRIAD_HOME/src/Param.jl`. This argument control the type of electrical network used in the balckbox but does not chhange the number of constaint and does not affet the input length.
- loggingTime: It is an argument that if specified to "false" does not do anything but if specified to a path, will create a timeLog file where each line of the .txt file represent the execution time of an iteration.
- continueEval: It is a function that you can redefine in Julia that would replace the basic function implemented in Mini-PRIAD that always return true, this function is a function that takes is called often in the blackbox at different fidelity. It give to continueEval function intermediate value of the objective function and the constraint with the associated fidelity, this function then chose to interupte the blackbox iteration or let it continue. In the ARGS.txt file the path to the .jl file contaning the Julia function and the name of the Julia function need to be specified.
```
All the argument have a default value, so you can choose to initialize only the arguments that you want the other argument(s) will take their default value.

The `x.txt` file contains the input vector that can takes diferent sizes:
```
input: It is the blackbox input of 28, 15 or 13 dimentions, including integer (I) and reel (R) inputs, the diferent input are defined like so:
	- 28 dimention input: [I, R, I, R, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, I, R, R]
	- 15 dimention input: [R, R, R, R, R, R, R, R, R, R, R, R, R, R, R]
	- 13 dimention input: [I, R, I, R, I, R, I, R, I, R, I, R, R]
```
The `x.txt` file must contains only the numerical value of each variable seperated with spaces without "[", "," or "]", the `x0_feasible` and `x0_infeasible` folder contains good example of how to formate your `x.txt` file, you will find those files if you go as deep as you can in the `$MINI_PRIAD_HOME/Tests` directory.
For all integer input the recommanded bounds are 1 and 9 and for all reel input the recommanded bounds are 0.1 and 10.0.

### Best objective function value found
Here is the list of best know values for the three instances with a default seed of zero:
```
	instance 1 with 13 dimentions input		36802252.400147244334
	instance 1 with 15 dimentions input		77017271.171398505569
	instance 1 with 28 dimentions input		70274902.081940218806

	instance 2 with 13 dimentions input		54491157.030907824636
	instance 2 with 15 dimentions input		91242551.759370580316
	instance 2 with 28 dimentions input		91242551.759370580316 *

	instance 3 with 13 dimentions input	    (INFEAS) -> 1.825267114397739e8 with h = 0.7068619447772448
	instance 3 with 15 dimentions input		2.981594980391101e8
	instance 3 with 28 dimentions input		2.981594980391101e8 *
```
The point associated to the best value found is alway in the `best_known_x.txt` file, you will find this file in the `$MINI_PRIAD_HOME/Tests` directory.
### Other tools
In the `$MINI_PRIAD_HOME/Benchmarking_Tools` directory you will find different file that you can execute to run NOMAD, an LHS or a random search on each instance for each input length. To run those file you can respectivly type the following lines for each type of search.
#### For NOMAD:
To use the folowing command, you need to have NOMAD on your computer and have the environment variable `NOMAD_HOME` that reprensent the directory where NOMAD is installed containing bin, src, etc. You can initialize it the same way you initialized the environment variable `MINI_PRIAD_HOME`.
```
julia $MINI_PRIAD_HOME/Benchmarking_Tools/Run_NOMAD.jl $NOMAD_HOME
```
> Note: You could also give manualy the full path instead of giving the environment variable `NOMAD_HOME` itself.
#### For latin hypercube sampling:
To use the folowing command, you need to install the julia package "Surogates" (see the section `Installing julia package "Surogates"`).
```
julia $MINI_PRIAD_HOME/Benchmarking_Tools/Run_LHS.jl
```
##### Installing julia package "Surogates"
To install the package or can run the following lines in your terminal:
```
julia
```
```
import Pkg
```
```
Pkg.add("Surrogates")
```
#### For rabdom search:
```
julia $MINI_PRIAD_HOME/Benchmarking_Tools/Run_RS.jl
```

