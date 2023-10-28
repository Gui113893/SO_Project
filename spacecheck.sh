#!/bin/bash
source ./validationFunctions.sh

function spacecheck() {
    local dir=$1
    local regex=$2
    
    local totals=()

    for d in $(find "$dir" -type d); do
        if [[ -n $regex ]]; then
            local total=$(find "$d" -type f -regex "$regex" -exec du -cb {} + | awk '{total += $1} END {print total}')
        else
            local total=$(find "$d" -type f -exec du -cb {} + | awk '{total += $1} END {print total}')
        fi
        if [[ $total -gt 0 ]]; then
            totals+=("$total $d")
        fi
    done

    for total in "${totals[@]}"; do
        echo "$total"
    done 

}

function main(){
    #Default Options

    local args=() #array para armazenar os argumentos que não estão relacionados com as flags
    local nRegex="" #variável para armazenar o argumento da flag -n

    
    #Gestão das flags {-n [arg] | -d [arg] | -s [arg] | -r | -a | -l [arg] }
    while getopts 'n:d:s:ral:' OPTION; do
        case "$OPTION" in 
            n)
                #-n filtra o tipo de ficheiros a serem contabilizados
                #Caso não seja usada a flag, todos os ficheiros são contabilizados
                validateN "$OPTARG"
                nRegex="$OPTARG"
                ;;
            d)
                #-d filtra a data máxima de modificação dos ficheiros
                ;;
            s)
                #-s filtra o tamanho mínimo dos ficheiros
                ;;
            r)
                #-r para ordenar de forma inversa (Menor -> Maior)
                #Se a flag não for usada, a ordenação mantém-se a "normal" (Maior -> Menor)
                ;;
            a)
                #-a para ordernar por nome
                #Se a flag não for usada, a ordenação mantém-se a default como no caso do -r (Maior -> Menor)             
                ;;
            l)
                #-l é usado para limitar o número de linhas que aparece no output da tabela
                ;;
            *)
                echo "$OPTARG Not An Option"
                exit 1
                ;;
        esac
    done

    #Detalhe do script:
    #1 - O script mesmo que não receba flags necessita de argumento(s) que pode ser uma ou mais diretorias
    #2 - Se, por alguma razão, não for possível aceder a uma diretoria, o espaço ocupado pelos ficheiros 
    #da mesma deve ser assinalado com NA


    #find . -regex ".*sh"
    #find /path/ -name ".*sh"
    #du -cb -d (depth) (Directory)


    #Cabeçalho:
    echo SIZE NAME $(date +%Y%m%d) "$@"
    
    #O shift desloca os argumentos do terminal de posição
    #A variável OPTIND é o índice do próximo argumento a ser processado pela função 'getopts'
    #Ou seja, OPTIND -1 é o índice do último argumento processado associado a uma flag
    #shift $((OPTIND-1)) remove os argumentos processados ficando só os do /spacecheck.sh
    shift $((OPTIND-1)) 

    #Feito o shift, agora a variável $@ terá todos os argumentos do script menos os das flags
    args+=("$@")

    #if [[ -n $nRegex ]]; then
     #   du -cb $(find "${args[@]}" -type f -regex "$nRegex") | sort -nr
    #else
     #   du -cb "${args[@]}" | sort -nr
    #fi

    for arg in "${args[@]}"; do
        spacecheck "$arg" "$nRegex"
    done | sort -rn


    #eval $command


}

main "$@"
