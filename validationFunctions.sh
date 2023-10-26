#!/bin/bash

function validateN() {
    #Expressão Regular com o Tipo de Ficheiros
    if [[ ! $1 =~ ^.*\.(jpg|JPG|gif|GIF|doc|DOC|pdf|PDF|sh|"*sh"|a|au|bin|bz2|c|) ]]; then
        echo "[Invalid Argument] - Must be a regular expression for a type of file"
        exit 0
    fi
}

function validateD(){
    return 0
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