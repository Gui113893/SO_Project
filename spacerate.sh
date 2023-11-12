#!/bin/bash
source ./validationFunctions.sh

function UsageSpaceRate () {
	echo "Usage: spacerate.sh [-a|-r options] file1 file2"
    echo "file1 must be the most recent file"
	echo "Options:"
	echo -e "\t-a 		- alphabetic sort (muttualy exclusive with -r)"
	echo -e "\t-h              - Script usage"
	echo -e "\t-l number 	- maximum output lines"
}

function AnalyzeFile() {
    local file_A=$1         # file A
    local file_B=$2         # file B
    local infoA=()          # array to store the information from file A
    local infoB=()          # array to store the information from file B
    local directory_A=""    # variable to store the directory name from file A
    local directory_B=""    # variable to store the directory name from file B
    local size_A=0          # variable to store the size from file A
    local size_B=0          # variable to store the size from file B
    local diff=0            # variable to store the difference between the sizes of the same directory in file A and file B
    local count=0           # variable to count the number of lines read from the file


    if [[ ! -f $file_A || ! -r $file_A || ! -f $file_B || ! -r $file_B ]]; then 
        echo "Arguments must be readable files"     # If the arguments are not files or not readable, the script is terminated
        UsageSpaceRate
        return 1;
    fi

    # Read file A and store the information in the array infoA
    
    while IFS= read -r line; do
        # Skips the first line of the file (header)
        if [[ $count -eq 0 ]]; then 
            count=$((count+1)) 
        else
            infoA+=("$line") # Adds the line to the array
        fi
    done <"$file_A" 


    count=0 # resets the count variable

    # Read file B and store the information in the array infoB
    while IFS= read -r line; do
        # Skips the first line of the file (header)
        if [[ $count -eq 0 ]]; then
            count=$((count+1))
        else
            infoB+=("$line") # Adds the line to the array
        fi
    done <"$file_B"

    #Loop to compare both arrays, assuming file A is the most recent one (IMPORTANT!!!)
    #For each element of array A, loop through array B until a match is found
    for i in "${!infoA[@]}"; do
        directory_A=$(echo "${infoA[$i]}" | awk '{print $2}') #sets "directory_A" to the directory name via awk
        size_A=$(echo "${infoA[$i]}" | awk '{print $1}')      #sets "size_A" to the directory size via awk
        
        for j in "${!infoB[@]}"; do
            directory_B=$(echo "${infoB[$j]}" | awk '{print $2}')   #sets "directory_B" to the directory name via awk
            size_B=$(echo "${infoB[$j]}" | awk '{print $1}')        #sets "size_B" to the directory size via awk

            #If a match is found, calculates de difference between the sizes of the same directory in file A and file B and removes the elements from the arrays
            if [[ $directory_A == $directory_B ]]; then
                
                if [[ $size_A == "NA" && $size_B == "NA" ]]; then
                    diff="NA"                   # If the size of the directory in file A or file B is "NA", the difference is also "NA"
                else
                    diff=$((size_A - size_B))   # else, the difference is calculated
                fi
                echo "$diff $directory_A"       # prints the difference and the directory name
                unset 'infoA[i]'                # removes the element from array A
                unset 'infoB[j]'                # removes the element from array B
                break
            fi
        done
    done

    # After the previous loop, the arrays only contain elements that are not present in the other array (either they are NEW or REMOVED)
    # Since file A is assumed to be the most recent one, the elements of array A are NEW and the elements of array B are REMOVED
    # All left to do is to print the elements of each array with the respective tag (NEW or REMOVED)

    # Loop to print the elements of array A (NEW)
    for i in "${!infoA[@]}"; do
        directory_A=$(echo "${infoA[$i]}" | awk '{print $2}')   #sets "directory_A" to the directory name via awk
        size_A=$(echo "${infoA[$i]}" | awk '{print $1}')        #sets "size_A" to the directory size via awk
        if [[ $size_A == "NA" ]]; then
            diff="NA"  
        else
            diff=$((size_A - 0))        # Since the directory is NEW, the difference is the size of the directory
        fi
        echo "$diff $directory_A NEW"   # Prints the size of "directory_A" and the directory name with the tag NEW
    done

    for i in "${!infoB[@]}"; do
        directory_B=$(echo "${infoB[$i]}" | awk '{print $2}')   #sets "directory_B" to the directory name via awk
        size_B=$(echo "${infoB[$i]}" | awk '{print $1}')        #sets "size_B" to the directory size via awk
        if [[ $size_B == "NA" ]]; then
            diff="NA"  
        else
            diff=$((0 - size_B))            # Since the directory is REMOVED, the difference is the negative size of the directory
        fi
        echo "$diff $directory_B REMOVED"   # Prints the negative size of "directory_B" and the directory name with the tag REMOVED
    done

    return 0;
}

function main(){


    if [[ $# -eq 0 ]]; then                 # $# denotes the $@ array size (number of parameters given)           
        echo "No arguments were given." 
        UsageSpaceRate                      # No parameters passed? Call Usage function...
        exit 1                              # Script exits!
    fi

    local sort="sort -rn"       # Default sort is numeric reverse
    local limit=""              # Default limit is no limit

    # Handling of flags and respective arguments {-r | -a | -l [arg] | -h }
    while getopts 'ral:h' OPTION; do
        case "$OPTION" in 
            r)
                # -r sorts by asceding size
                # If not used, the default sorting option is by descending size
                sort="sort -n" 
                ;;
            a)
                # -a sorts by alphabetic order
                # If not used, the default sorting option is by descending size                 
                sort="sort -t' ' -k2"   # -t' ' => sort by the second column (NAME) alphabetically       
                ;;
            l)
                # -l used to limit the number of output lines
                validateL "$OPTARG"
                limit="| head -$OPTARG" # head -n => outputs the first n lines of the input
                ;;
            h) 
                # -h displays the script usage
                UsageSpaceRate
                exit 1
                ;;
            *)
                # If an invalid flag is used, the script usage is displayed and the script exits
                echo "$OPTARG Not An Option"
                UsageSpaceRate
                exit 1
                ;;
        esac
    done

    # The shift command is used to move command line arguments one position to the left.
    # The OPTIND variable is set to the index of the next argument to be processed by getopts.
    # Which means OPTIND -1 is the index of the last argument processed by getopts.
    shift $((OPTIND-1)) # Therefore, this removes the processed options and flags from the list of arguments

    # If the number of arguments is not 2, the script is terminated (the script only establishes comparisons between 2 files)
    if [[ $# -ne 2 ]]; then 
        echo "Wrong number of arguments"   
        return 1;
    fi

    # Header:
    echo SIZE NAME "$@"
    AnalyzeFile "$@" | eval $sort $limit 
    # AnalyzeFile function is called and the output is piped to the sort command and the limit command (if used)

}

main "$@"
