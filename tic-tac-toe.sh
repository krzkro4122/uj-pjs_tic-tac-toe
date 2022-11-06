#!/bin/bash

FIELDS=(1 2 3 4 5 6 7 8 9)
WINS=("1 2 3" "4 5 6" "7 8 9" "1 4 7" "2 5 8" "3 6 9" "1 5 9" "3 5 7")
TURN='O'
WINNER=0
HISTORY=()

function is_field_empty () {
    # Check if the field is empty
    desired_field=${1}
    status_code=0
    
    for entry in ${HISTORY[@]};
    do
        if [[ ${desired_field} == ${entry} ]]; then
            printf "Field %s is already in use!\n" ${desired_field}
            status_code=1
            break
        fi
    done

    return ${status_code}
}

function move () {
    # Try to take a turn, repeat if the field is already taken
    result=1
    while [ ${result} -eq 1 ];
    do
        printf "[%d] %s's turn [1-9]: " ${#HISTORY[@]} ${TURN}
        read field
        is_field_empty ${field}
        result=$?
    done

    # Append the move to current player's and global history 
    if [[ ${TURN} == 'O' ]]; then
        HISTORY+=("${field}")
    else
        HISTORY+=("${field}")
    fi
}

function end_turn () {
    # Swap the current player
    case ${TURN} in
        'O') TURN='X' ;;
        'X') TURN='O' ;;
    esac 
}

function draw () {
    # Draw 'X', 'O' and '_' in a 3x3 grid
    for f in ${FIELDS[@]};
    do
        is_empty=1
        # Check fields against move history 
        for i in ${!HISTORY[@]};
        do
            if [ ${HISTORY[$i]} -eq "${f}" ]; then
                if [ $((i % 2)) -eq 0 ]; then
                    printf "O "
                    is_empty=0
                    break 
                else
                    printf "X "
                    is_empty=0
                    break
                fi            
            fi
        done
        if [ ${is_empty} -eq 1 ]; then
            printf "_ "
        fi
        # Newlines to make up 3 columns
        if [ ${f} -eq 3 ] || [ ${f} -eq 6 ] || [ ${f} -eq 9 ]; then
            printf "\n"
        fi
    done
}

function check_win () {
    player=${1}

    # HAVE TO PARSE HISTORY HERE SOMEWHERE TO DETERMINE IF ITS GOT THE WINNING POSITIONS

    for i in ${!HISTORY[@]};
    do
        if [ $((i % 2)) -eq 0 ]; then
            echo "Sth"
        fi
    done
}

function main () {
    # Game's primitive event loop
    for _ in {1..9};
    do
        move 
        draw
        end_turn
        check_win
    done
}

main
