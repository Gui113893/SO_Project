#!/bin/bash

function calcSpace2() {
    local dir=$1
    local regexCommand=$2
    local sizeCommand=$3
    local dateCommand=$4
 
    if [[ ! -d $dir || ! -x $dir ]]; then
        echo "NA $dir"
        return
    fi

        while IFS= read -r -d $'\0' d; do
        if [[ ! -d $d || ! -x $d ]]; then
            echo NA "$d"
        else
            #Simplificação dos ifs, como só mudava a parte -regex $regex, agora a variavel $regex recebe o comando em vez do regex sozinho
            #Com a variável a receber -regex "regex", em vez dos ifs é só por a variável no comando. Se estiver vazia, faz como se não tivesse sido usada a flag -n
            #"-maxdepth 1" limita o "scope" de procura do comando find, para apenas contabilizar os ficheiros filhos diretos diretorio em questão.            
            local total=$(find "$d" -type -maxdepth 1 f $sizeCommand $regexCommand $dateCommand -print0 -exec du -cb {} + 2>/dev/null| awk '{total = $1} END {print total+0}')
            
            echo "$total" "$d"
        fi
    done < <(find "$file" -type d -print0 2>/dev/null) #2>/dev/null é adicionado para que os erros do du como "Permission denied" não sejam mostrados

    return 0;
}

function AnalyzeFile() {
    local dirs=()
    local file=$1
    local dateFile=""

    local regexCommand="" 
    local sort="sort -rn"
    local limit="" 
    local sizeCommand=""
    local dateCommand="-newermt "1970-01-01T00:00:00" ! -newermt "$(date +"%Y-%m-%dT%H:%M:%S")""
 
    if [[ ! -f $file || ! -r $file ]]; then
        echo "Argument must be a readable file"
        return
    fi

    first_line=$(head -n 1 "$file")
    # Guarda "SIZE NAME (file creation date)" + todos os argumentos do spacecheck num array 
    read -ra args <<< "$first_line"
    dateFile=$(echo "$first_line" | awk '{print $3}')
    # Variável index vai estar sempre 1 posição à frente de "arg", útil para guardar os argumento das flags
    local index=1
    
    for arg in "${args[@]}"; do
        case $arg in
            -n)
                regexCommand="-regex ${args[$index]}"                
                ;;
            -s)
                sizeCommand="-size +${args[$index]}"
                sizeCommand+="c" 
                ;;
            -d)
                # No cabeçalho do ficheiro, a data está no formato: mês ano dia (ou em ordens diferentes)
                dateCommand="-newermt "1970-01-01T00:00:00" ! -newermt $(date -d "${args[$index]} ${args[$index+1]} ${args[$index+2]}" +"%Y-%m-%dT%H:%M:%S")"
                ;;
            -l)
                limit="| head -${args[$index]}"
                ;;
            *)
                if [[ -d $arg ]]; then
                    dirs+=("$arg")
                fi
                ;;
        esac
        # Forçada a adição em vez da concatenação
        index=$((index+1))
    done

    for dir in "${dirs[@]}"; do
        calcSpace2 "$dir" "$regexCommand" "$sizeCommand" "$dateCommand"
    done

    return 0;
}

function main(){

    #Caso não seja passado nenhum argumento, o script é terminado
    if [[ $# -eq 0 ]]; then
        echo "No arguments were given"
        exit 1
    fi

    local sort="sort -rn" #variável de sort default

    while getopts 'ra' OPTION; do
        case "$OPTION" in 
            r)
                sort="sort -n" 
                ;;
            a)
                sort="sort -t' ' -k2"           
                ;;
            *)
                echo "$OPTARG Not An Option"
                exit 1
                ;;
        esac
    done


    #Cabeçalho:
    echo SIZE NAME "$@"

    shift $((OPTIND-1))

    if [[ ! $# -eq 2 ]]; then
        echo "Exactly 2 directories must be given"
        exit 1
    fi

    AnalyzeFile "$@" | eval $sort $limit

}

main "$@"
