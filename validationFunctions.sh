#!/bin/bash

function validateN(){
    regex_pattern="^.*\..*$"
    if [[ ! $1 =~ $regex_pattern ]]; then
            echo "-n Argument $1 is invalid."
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