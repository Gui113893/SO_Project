#!/bin/bash
source ./validationFunctions.sh

function main(){
    #Default Options

    #command="du "
    args=() #array para armazenar os argumentos que não estão relacionados com as flags

    #Gestão das flags {-n [arg] | -d [arg] | -s [arg] | -r | -a | -l [arg] }
    while getopts 'n:d:s:ral:' OPTION; do
        case "$OPTION" in 
            n)
                #-n filtra o tipo de ficheiros a serem contabilizados
                #Caso não seja usada a flag, todos os ficheiros são contabilizados
                ;;
            d)
                #-d filtra a data máxima de modificação dos ficheiros
                echo $OPTARG
                ;;
            s)
                #-s filtra o tamanho mínimo dos ficheiros
                ;;
            r)
                #-r para ordenar de forma inversa (Menor -> Maior)
                #Se a flag não for usada, a ordenação mantém-se a "normal" (Maior -> Menor)
                command+="| sort -n -r"
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

    echo ${args[@]}

    #eval $command


}

main "$@"
