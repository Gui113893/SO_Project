#!/bin/bash
source ./validationFunctions.sh

function spacerate() {
    return 0
}

function main(){
    #Caso não seja passadp nenhum argumento, o script é terminado
    if [[ $# -lt 2 ]]; then
        echo "Not enough arguments were given"
        exit 1
    fi

    while getopts 'ral:' OPTION; do
        case "$OPTION" in 
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
    echo SIZE NAME

    
   
    



}

main "$@"