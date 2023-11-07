#!/bin/bash
source ./validationFunctions.sh

function AnalyzeFile() {
    local file_A=$1
    local file_B=$2
    local infoA=() #array para armazenar as informações do ficheiro A
    local infoB=() #array para armazenar as informações do ficheiro B
    local found=false
    local directory_A=""
    local directory_B=""
    local size_A=0
    local size_B=0
    local diff=0
    local count=0


    if [[ ! -f $file_A || ! -r $file_A || ! -f $file_B || ! -r $file_B ]]; then
        echo "Arguments must be readable files"
        return 1;
    fi

    #Ler o ficheiro 1 e guardar as informações no array infoA
    
    while IFS= read -r line; do
        #Passa a primeira linha do ficheiro
        if [[ $count -eq 0 ]]; then
            count=$((count+1))
        else
            infoA+=("$line")
        fi
    done <"$file_A"

    #Ler o ficheiro 2 e guardar as informações no array infoB
    count=0
    while IFS= read -r line; do
        #Passa a primeira linha do ficheiro
        if [[ $count -eq 0 ]]; then
            count=$((count+1))
        else
            infoB+=("$line")
        fi
    done <"$file_B"

    #Loop para comparar os arrays
    #Por cada elemento do array A, procura o elemento correspondente no array B passando por todos os elementos 
    #do array B até encontrar match
    for i in "${!infoA[@]}"; do
        directory_A=$(echo "${infoA[$i]}" | awk '{print $2}')
        size_A=$(echo "${infoA[$i]}" | awk '{print $1}')
        
        for j in "${!infoB[@]}"; do
            directory_B=$(echo "${infoB[$j]}" | awk '{print $2}')
            size_B=$(echo "${infoB[$j]}" | awk '{print $1}')

            #Se encontrar match, calcula a diferença e remove os elementos dos arrays
            if [[ $directory_A == $directory_B ]]; then
                
                #Atenção quando o tamanho é NA
                if [[ $size_A == "NA" && $size_B == "NA" ]]; then
                    diff="NA"
                else
                    diff=$((size_A - size_B))
                fi
                echo "$diff $directory_A"
                unset 'infoA[i]'
                unset 'infoB[j]'
                break
            fi
        done
    done

    #No final do loops, os arrays só têm elementos que não têm match
    #Os elementos do array A são considerados como novos e os elementos do array B são considerados como removidos
    #Partindo do princípio que os files são passados por ordem cronológica, os elementos do array A são mais recentes que os do array B
    for i in "${!infoA[@]}"; do
        directory_A=$(echo "${infoA[$i]}" | awk '{print $2}')
        size_A=$(echo "${infoA[$i]}" | awk '{print $1}')
        if [[ $size_A == "NA" ]]; then
            diff="NA"  
        else
            diff=$((size_A - 0))
        fi
        echo "$diff $directory_A NEW"
    done

    for i in "${!infoB[@]}"; do
        directory_B=$(echo "${infoB[$i]}" | awk '{print $2}')
        size_B=$(echo "${infoB[$i]}" | awk '{print $1}')
        if [[ $size_B == "NA" ]]; then
            diff="NA"  
        else
            diff=$((0 - size_B))
        fi
        echo "$diff $directory_B REMOVED"
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
    local limit="" #variável de limite de output default; "" significa que não há limite de output

    while getopts 'ral:' OPTION; do
        case "$OPTION" in 
            r)
                sort="sort -n" 
                ;;
            a)
                sort="sort -t' ' -k2"           
                ;;
            l)
                validateL "$OPTARG"
                limit="| head -$OPTARG"
                ;;
            *)
                echo "$OPTARG Not An Option"
                exit 1
                ;;
        esac
    done

    shift $((OPTIND-1))

    if [[ $# -ne 2 ]]; then
        echo "Wrong number of arguments"
        return 1;
    fi

    #Cabeçalho:
    echo SIZE NAME "$@"
    AnalyzeFile "$@" | eval $sort $limit

}

main "$@"
