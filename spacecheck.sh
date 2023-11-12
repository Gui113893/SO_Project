#!/bin/bash
source ./validationFunctions.sh

# User-oriented help function
function Usage () {
	echo "Usage: spacecheck.sh [-a|-r options] dir1 ... dirN"
	echo "Options:"
	echo -e "\t-a 		- alphabetic sort (muttualy exclusive with -r)"
	echo -e "\t-d yyyy-mm-dd 	- maximum file modification date"
	echo -e "\t-h              - Script usage"
	echo -e "\t-l number 	- maximum output lines"
	echo -e "\t-n regex 	- pattern to select files"
	echo -e "\t-r 		- sort by descending disk space (muttualy exclusive with -a)"
	echo -e "\t-s number 	- minimum file size to be considered"
}

function calcSpace() {
    local dir=$1                # Directory to be considered
    local regexCommand=$2       # -regex [pattern] => specifies files that match the given pattern
    local sizeCommand=$3        # -size +[size]c => specifies files with size greater than [size] bytes
    local dateCommand=$4        # -newermt [date1] ! -newermt [date2] => files modified between date1 and date2
 
    if [[ ! -d $dir || ! -x $dir ]]; then   # If it is not a directory or if it is not executable, NA is printed
        echo "NA $dir"                      
        return
    fi

    while IFS= read -r -d $'\0' d; do       # -r to avoid backlash interpertation
                                            # -d $'\0' to ensure that the while loop reads the directories correctly, even if they have spaces in their names
        if [[ ! -x $d ]]; then   # -x to check if the directory is executable
            echo NA "$d"                    # If the directory is not executable, NA is printed
        else 
            local total=$(find "$d" -type f $sizeCommand $regexCommand $dateCommand -print0 -exec du -cb {} + 2>/dev/null | awk '{total = $1} END {print total+0}')
            # The assignment of the total variable is a bit complex, so to understand it, it is easier to break it down:
            # "total" corresponds to the total sum of the sizes of all files in the directory (including files inside subdirectories)
            # find "$d" -type f $sizeCommand $regexCommand $dateCommand -print0 => finds all files in the directory that match the given criteria
            # $sizeCommand $regexCommand $dateCommand => regex, size and date commands passed as arguments to the calcSpace function. If not used, the default value is ""
            # -print0 => ensures that the output of find is null terminated (to avoid problems with spaces in file names)
            # -exec du -cb {} + => executes du command ("-exec du") and outputs the total size ("-c") in bytes ("-b") for each file found by find ("{} +")
            # 2>/dev/null => ensures du errors such as "Permission denied" are not shown
            # awk '{total = $1} END {print total+0}' => prints the total size of all files in the directory ("total+0" to show 0 and have the directory printed instead of blank if the directory is empty)
            
            echo "$total" "$d"
        fi
    done < <(find "$dir" -type d -print0 2>/dev/null) # 2>/dev/null to ensure du errors such as "Permission denied" are not shown

}

function main() {
    if [[ "$#" -eq 0 ]]; then		    # $# denotes the $@ array size (number of parameters given)
        echo "No arguments were given."
	    Usage						    # No parameters passed? Call Usage function...
	    exit						    # Script exits!
    fi

    local dirs=()               #Array for storing the directories passed as arguments

    #Default Options
    local filePattern=""        #Default file pattern => All files
    local sort="sort -rn"       #Default sorting option => Descending size
    local limit=""              #Default maximum number of output lines => No limit
    local size=""               #Default minimum file size => 0
    local date="-newermt "1970-01-01T00:00:00" ! -newermt "$(date +"%Y-%m-%dT%H:%M:%S")"" # Default maximum file modification date => Current date (all files are considered)

    # Handling of flags and respective arguments {-n [arg] | -d [arg] | -s [arg] | -r | -a | -l [arg] }
    while getopts 'n:d:s:ral:h' OPTION; do
        case "$OPTION" in 
            n)
                #-n sets the file pattern to be considered
                # if not used, the default file pattern is all files
                
                validateN "$OPTARG"
                filePattern="-regex $OPTARG"
                ;;
            d)
                # -d sets the maximum file modification date
                # if not used, the default max modification date is the current date (basically, all files are considered)
                validateD "$OPTARG"
                # -newermt [date1] ! -newermt [date2] => files modified between date1 and date2
                date="-newermt "1970-01-01T00:00:00" ! -newermt "$(date -d "$OPTARG" +"%Y-%m-%dT%H:%M:%S")"" 
                ;;
            s)
                # -s sets the minimum file size to be considered 
                validateS "$OPTARG"
                size="-size +$OPTARG" # +$OPTARG => consider files with size greater than $OPTARG
                size+="c"       
                ;;
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
                Usage
                exit 1
                ;;
            *)
                # If an invalid flag is used, the script usage is displayed and the script exits
                echo "$OPTARG Not An Option"
                exit 1
                ;;
        esac
    done

    # Header:
    echo SIZE NAME $(date +%Y%m%d) "$@"
    
    # The shift command is used to move command line arguments one position to the left.
    # The OPTIND variable is set to the index of the next argument to be processed by getopts.
    # Which means OPTIND -1 is the index of the last argument processed by getopts.
    shift $((OPTIND-1)) # Therefore, this removes the processed options and flags from the list of arguments 

    dirs+=("$@")    # The remaining arguments are the directories to be considered


    # For each directory passed as argument, the calcSpace function is called to calculate the total size of all files in the directory
    for dir in "${dirs[@]}"; do
        calcSpace "$dir" "$filePattern" "$size" "$date"
    done | eval $sort $limit
    # The output of calcSpace is piped to the sort command, which sorts the output in alphabetical order or by size in descending or ascdeing order, based on the flags used
    # After sorting, the output is piped to the limit command, which limits the number of output lines to the number specified by the -l flag (if used, else outputs all lines)
}

main "$@"
