#!/bin/bash
source ./validationFunctions.sh

function main(){
    #Default Options
    #echo "${@: -1}" #ultimo argumento (pode dar jeito)

    command="du "

    #Gestão das flags {-n [arg] | -d [arg] | -s [arg] | -r | -a | -l [arg] }
    while getopts 'n:d:s:ral:' OPTION; do
        case "$OPTION" in 
            n)
                #-n filtra o tipo de ficheiros a serem contabilizados
                #Caso não seja usada a flag, todos os ficheiros são contabilizados
                nOption=true
                echo "-n TRUE"
                ;;
            d)
                #-d filtra a data máxima de modificação dos ficheiros
                echo "-d TRUE"
                echo $OPTARG
                ;;
            s)
                #-s filtra o tamanho mínimo dos ficheiros
                echo "-s TRUE"
                ;;
            r)
                #-r para ordenar de forma inversa (Menor -> Maior)
                #Se a flag não for usada, a ordenação mantém-se a "normal" (Maior -> Menor)
                echo "-r TRUE"
                command+="| sort -n"
                ;;
            a)
                #-a para ordernar por nome
                #Se a flag não for usada, a ordenação mantém-se a default como no caso do -r (Maior -> Menor)
                echo "-a TRUE"
                ;;
            l)
                #-l é usado para limitar o número de linhas que aparece no output da tabela
                echo "-l TRUE"
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

    #command="cat $1"
    #command+=" $2"
    #$command
    eval $command

}

main "$@"
