#!/bin/bash
source ./validationFunctions.sh

function calcSpace() {
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
            local total=$(find "$d" -maxdepth 1 -type f $sizeCommand $regexCommand $dateCommand -print0 -exec du -cb {} + 2>/dev/null| awk '{total = $1} END {print total+0}')
            
            echo "$total" "$d"
        fi
    done < <(find "$dir" -type d -print0 2>/dev/null) #2>/dev/null é adicionado para que os erros do du como "Permission denied" não sejam mostrados

}

function main(){
    #Caso não seja passadp nenhum argumento, o script é terminado
    if [[ $# -eq 0 ]]; then
        echo "No arguments were given"
        exit 1
    fi

    #Default Options
    local dirs=() #array para armazenar os diretórios que não estão relacionados com as flags
    local nRegex="" #variável para armazenar o argumento da flag -n
    local sort="sort -rn" #variável de sort default
    local limit="" #variável de limite de output default; "" significa que não há limite de output
    local size="" #variável de size default; "" significa que não há limite de size
    local date="-newermt "1970-01-01T00:00:00" ! -newermt "$(date +"%Y-%m-%dT%H:%M:%S")"" #variável de data default

    #Gestão das flags {-n [arg] | -d [arg] | -s [arg] | -r | -a | -l [arg] }
    while getopts 'n:d:s:ral:' OPTION; do
        case "$OPTION" in 
            n)
                #-n filtra o tipo de ficheiros a serem contabilizados
                #Caso não seja usada a flag, todos os ficheiros são contabilizados
                validateN "$OPTARG"
                nRegex="-regex $OPTARG"
                ;;
            d)
                #-d filtra a data máxima de modificação dos ficheiros
                validateD "$OPTARG"
                date="-newermt "1970-01-01T00:00:00" ! -newermt "$(date -d "$OPTARG" +"%Y-%m-%dT%H:%M:%S")""
                ;;
            s)
                #-s filtra o tamanho mínimo dos ficheiros
                validateS "$OPTARG"
                size="-size +$OPTARG"
                size+="c"       #comando final= -size +$OPTARGc
                ;;
            r)
                #-r para ordenar de forma inversa (Menor -> Maior)
                #Se a flag não for usada, a ordenação mantém-se a "normal" (Maior -> Menor)
                sort="sort -n" 
                ;;
            a)
                #-a para ordernar por nome
                #Se a flag não for usada, a ordenação mantém-se a default como no caso do -r (Maior -> Menor)  
                sort="sort -t' ' -k2"           
                ;;
            l)
                #-l é usado para limitar o número de linhas que aparece no output da tabela
                validateL "$OPTARG"
                limit="| head -$OPTARG"
                ;;
            *)
                echo "$OPTARG Not An Option"
                exit 1
                ;;
        esac
    done

    #Cabeçalho:
    echo SIZE NAME $(date +%Y%m%d) "$@"
    
    #O shift desloca os argumentos do terminal de posição
    #A variável OPTIND é o índice do próximo argumento a ser processado pela função 'getopts'
    #Ou seja, OPTIND -1 é o índice do último argumento processado associado a uma flag
    #shift $((OPTIND-1)) remove os argumentos processados ficando só os do /spacecheck.sh
    shift $((OPTIND-1)) 

    #Feito o shift, agora a variável $@ terá todos os argumentos do script menos os das flags
    dirs+=("$@")

    for dir in "${dirs[@]}"; do
        calcSpace "$dir" "$nRegex" "$size" "$date"
    done | eval $sort $limit

}

main "$@"
