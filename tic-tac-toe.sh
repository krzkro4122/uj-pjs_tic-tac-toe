#!/bin/bash

# GLOBAL VARIABLES
FIELDS=(1 2 3 4 5 6 7 8 9)
HISTORY=()
TURN='O'
# Win tracking containers
# O
O_ROWS=(0 0 0)
O_COLUMNS=(0 0 0)
O_DIAGONAL=(0 0 0)
O_OPPOSITE_DIAGONAL=(0 0 0)
# X
X_ROWS=(0 0 0)
X_COLUMNS=(0 0 0)
X_DIAGONAL=(0 0 0)
X_OPPOSITE_DIAGONAL=(0 0 0)

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

    # Append the move to the global history
    HISTORY+=("${field}")

    # Populate the corresponding win tracking containers
    which_row=$(( (field - 1) / 3 ))
    which_column=$(( field % 3 ))  # doesn't actually matter if this is the exact collumn just has to be consistent
    diagonal_index=$(( field / 4 ))
    opposite_diagonal_index=$(( (field / 2) - 1 ))
    if [[ ${TURN} == 'O' ]]; then
        # The move is always on SOME column and SOME row
        O_ROWS[${which_row}]=$(( O_ROWS[which_row] + 1 ))
        O_COLUMNS[${which_column}]=$(( O_COLUMNS[which_column] + 1 ))
        # Diagonal
        if (( field % 4 == 1 )); then
            O_DIAGONAL[${diagonal_index}]=1
        fi
        # Opposite diagonal
        if (( field == 3 || field == 5 || field == 7 )); then
            O_OPPOSITE_DIAGONAL[${opposite_diagonal_index}]=1
        fi
        echo "O_ROWS: [${O_ROWS[@]}]"
        echo "O_COLUMNS: [${O_COLUMNS[@]}]"
        echo "O_DIAGONAL: [${O_DIAGONAL[@]}]"
        echo "O_OPPOSITE_DIAGONAL: [${O_OPPOSITE_DIAGONAL[@]}]"
    else
        X_ROWS[${which_row}]=$(( X_ROWS[which_row] + 1 ))
        X_COLUMNS[${which_column}]=$(( X_COLUMNS[which_column] + 1 ))
        # Diagonal
        if (( field % 4 == 1 )); then
            X_DIAGONAL[${diagonal_index}]=1
        fi
        # Opposite diagonal
        if (( field == 3 || field == 5 || field == 7 )); then
            X_OPPOSITE_DIAGONAL[${opposite_diagonal_index}]=1
        fi
        echo "X_ROWS: [${X_ROWS[@]}]"
        echo "X_COLUMNS: [${X_COLUMNS[@]}]"
        echo "X_DIAGONAL: [${X_DIAGONAL[@]}]"
        echo "X_OPPOSITE_DIAGONAL: [${X_OPPOSITE_DIAGONAL[@]}]"
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
                if (( i % 2 == 0 )); then
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

# if anybody wins this returns 1, else it returns 0
function check_win() {
    # Determine who's win trackers to check
    if [[ ${TURN} == 'O' ]]; then
        # Check rows
        for value in ${O_ROWS[@]};
        do
            if (( value == 3 )); then
                return 1
            fi
        done
        # Check columns
        for value in ${O_COLUMNS[@]};
        do
            if (( value == 3 )); then
                return 1
            fi
        done
        # Check the diagonal
        aggregate=0
        for value in ${O_DIAGONAL[@]};
        do
            aggregate=$(( aggregate + value ))
        done
        if (( aggregate == 3 )); then
            return 1
        fi
        # Check the opposite diagonal
        aggregate=0
        for value in ${O_OPPOSITE_DIAGONAL[@]};
        do
            aggregate=$(( aggregate + value ))
        done
        if (( aggregate == 3 )); then
            return 1
        fi
    else
        # Check rows
        for value in ${X_ROWS[@]};
        do
            if (( value == 3 )); then
                return 1
            fi
        done
        # Check columns
        for value in ${X_COLUMNS[@]};
        do
            if (( value == 3 )); then
                return 1
            fi
        done
        # Check the diagonal
        aggregate=0
        for value in ${X_DIAGONAL[@]};
        do
            aggregate=$(( aggregate + value ))
        done
        echo "aggregate: ${aggregate}"
        if (( aggregate == 3 )); then
            return 1
        fi
        # Check the opposite diagonal
        aggregate=0
        for value in ${X_OPPOSITE_DIAGONAL[@]};
        do
            aggregate=$(( aggregate + value ))
        done
        echo "aggregate: ${aggregate}"
        if (( aggregate == 3 )); then
            return 1
        fi
    fi
    # if nothing found then return 0
    return 0
}

function main () {
    # Game's primitive event loop
    for i in {1..9};
    do
        move
        draw
        check_win
        winner=${?}
        if (( winner == 1 )); then
            echo "Player ${TURN} WON!"
            # Delete the save file here?
            exit 0
        fi
        end_turn
    done
    echo "NOBODY won this round!"
}

main