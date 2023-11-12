#!/bin/bash
function validateN(){
    regex_pattern="^.*\..*$" # Regex pattern for validating file extensions
    if [[ ! $1 =~ $regex_pattern ]]; then
            echo "-n Argument $1 is invalid."
            Usage
            exit 1
    fi
}

function validateD(){
    if [[ ! $(date -d "$1") ]]; then
            echo "-d Argument $1 is invalid."
            Usage
            exit 1
    fi
}

function validateS(){
    if [[ ! $1 -ge 0 ]]; then
            echo "-s Argument $1 is invalid."
            exit 1
    fi
}

function validateL(){
    if [[ ! $1 -ge 0 ]]; then
            echo "-l Argument $1 is invalid."
            exit 1
    fi
}
