#!/bin/bash

function validateN() {
    #Expressão Regular com o Tipo de Ficheiros
    if [[ ! $1 =~ ^.*\.(jpg|JPG|gif|GIF|doc|DOC|pdf|PDF|sh|"*sh"|a|au|bin|bz2|c|) ]]; then
        echo "[Invalid Argument] - Must be a regular expression for a type of file"
        exit 1
    fi
}

function validateD(){
    date_pattern="^[A-Z][a-z]{2} [0-9]{1,2} [0-9]{2}:[0-9]{2}"
    if [[ ! $1 =~ $date_pattern ]]; then
            echo "-d Argument $1 is invalid."
            exit 1
    fi
}

function validateS(){
    return 0
}

function validateL(){
    return 0
}

function validateLastArg(){
    return 0
}