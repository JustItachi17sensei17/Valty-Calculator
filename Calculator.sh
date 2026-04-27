#!/bin/bash

# --- Settings ---
FORMAT="normal" # normal, sci_e, sci_pow
PRECISION=4
ANGLE_MODE="deg" # deg, rad
UNIT_SYSTEM="metric" # metric, imperial
LAST_RESULT=0
COUNT=0
HISTORY_FILE=".valty_history"
set -o pipefail # Better error handling in pipes
touch "$HISTORY_FILE" && chmod 600 "$HISTORY_FILE"
rm -f "$HISTORY_FILE" # Clear session history on startup
touch "$HISTORY_FILE" && chmod 600 "$HISTORY_FILE"

# --- Color Definitions ---
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color
 
# --- Helper Functions ---
is_num() {
    [[ "$1" =~ ^-?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$ ]]
}


# --- Startup Sequence ---
startup() {
    clear
    echo -ne "${MAGENTA}Initializing Valty OS...${NC}\n"
    echo -ne "${BLUE}[▰▱▱▱▱▱▱▱▱▱] 10%${NC}\r"
    sleep 0.2
    echo -ne "${BLUE}[▰▰▰▱▱▱▱▱▱▱] 30%${NC}\r"
    sleep 0.2
    echo -ne "${BLUE}[▰▰▰▰▰▰▱▱▱▱] 60%${NC}\r"
    sleep 0.2
    echo -ne "${BLUE}[▰▰▰▰▰▰▰▰▰▰] 100%${NC}\r"
    sleep 0.3
    echo -e "\n${GREEN}System Ready.${NC}"
    sleep 0.5
}

# --- Shutdown Sequence ---
shutdown() {
    clear
    echo -e "${MAGENTA}Shutting down Valty OS...${NC}"
    echo -e "${WHITE}Session Summary: ${YELLOW}${COUNT}${WHITE} calculations performed.${NC}"
    sleep 0.5
    echo -ne "${RED}[▰▰▰▰▰▰▰▰▰▰] 100%${NC}\r"
    sleep 0.2
    echo -ne "${RED}[▰▰▰▰▰▰▱▱▱▱] 60%${NC}\r"
    sleep 0.2
    echo -ne "${RED}[▰▰▰▱▱▱▱▱▱▱] 30%${NC}\r"
    sleep 0.2
    echo -ne "${RED}[▱▱▱▱▱▱▱▱▱▱] 10%${NC}\r"
    sleep 0.3
    echo -e "\n\n${CYAN}  █▀▀ █▀█ █▀█ █▀▄ █▀▄ █ █ █▀▀${NC}"
    echo -e "${CYAN}  █ █ █ █ █ █ █ █ █▀▄ ▀█▀ █▀▀${NC}"
    echo -e "${CYAN}  ▀▀▀ ▀▀▀ ▀▀▀ ▀▀  ▀▀  ▀   ▀▀▀${NC}"
    echo -e "\n${GRAY}Connection Terminated.${NC}"
    sleep 0.8
    clear
}

# --- ASCII Art Header ---
show_header() {
    clear
    echo -e "  ${MAGENTA}╔══════════════════════════════════════════════╗${NC}"
    echo -e "  ${MAGENTA}║${WHITE}     █ █ █▀█ █   ▀█▀ █ █   █▀▀ █▀█ █   █▀▀    ${MAGENTA}║${NC}${GRAY}█${NC}"
    echo -e "  ${MAGENTA}║${WHITE}     █▄█ █▀█ █▄▄  █   █    █▄▄ █▀█ █▄▄ █▄▄    ${MAGENTA}║${NC}${GRAY}█${NC}"
    echo -e "  ${MAGENTA}╠══════════════════════════════════════════════╣${NC}${GRAY}█${NC}"
    echo -e "  ${MAGENTA}║${WHITE}  [m] Manual    [s] Settings  [k] Credits     ${MAGENTA}║${NC}${GRAY}█${NC}"
    echo -e "  ${MAGENTA}║${WHITE}  [y] History   [u] Units     [e] Equations   ${MAGENTA}║${NC}${GRAY}█${NC}"
    echo -e "  ${MAGENTA}║${WHITE}  [l] Clear     [q] Quit                      ${MAGENTA}║${NC}${GRAY}█${NC}"
    echo -e "  ${MAGENTA}╚══════════════════════════════════════════════╝${NC}${GRAY}█${NC}"
    echo -e "   ${GRAY}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${NC}"
    echo -e "    ${WHITE}Mode: ${YELLOW}${FORMAT}${NC} | ${WHITE}Angle: ${YELLOW}${ANGLE_MODE^^}${NC} | ${WHITE}Prec: ${YELLOW}${PRECISION}${NC} | ${WHITE}Units: ${YELLOW}${UNIT_SYSTEM^^}${NC}"
    echo -e "    ${WHITE}Status: ${GREEN}ONLINE ●${NC}"
    echo -e "  ${MAGENTA}────────────────────────────────────────────────${NC}"
}

# --- Formatting Function ---
format_result() {
    local val=$1
    
    # Handle Math Errors (Inf, NaN)
    if [[ "${val,,}" =~ (nan|inf) ]]; then
        echo -e "${RED}ERR: MATH ERROR${NC}"
        return
    fi

    if [[ "$FORMAT" == "sci_e" ]]; then
        printf "%.${PRECISION}e" "$val"
    elif [[ "$FORMAT" == "sci_pow" ]]; then
        # Convert 1.23e+02 to 1.23 * 10^2
        local raw=$(printf "%.${PRECISION}e" "$val")
        local base=$(echo "$raw" | cut -d'e' -f1)
        local exp_raw=$(echo "$raw" | cut -d'e' -f2)
        # Use awk to safely convert exponent to integer
        local exp=$(awk "BEGIN { print $exp_raw + 0 }")
        [[ "$exp" == "0" ]] && echo "$base" || echo "$base * 10^$exp"
    else
        # Normal mode: use %f (true decimal places), not %g (significant figures).
        # Auto-switch to scientific for very large (>=1e15) or very small (<1e-4) values.
        # This handles the user's request for up to 10^100 by formatting as scientific.
        local abs_val=$(awk "BEGIN { v=$val; print (v<0)?-v:v }")
        local use_sci=$(awk "BEGIN { v=$abs_val; print (v!=0 && (v>=1e15||v<1e-4))?1:0 }")
        if [[ "$use_sci" == "1" ]]; then
            printf "%.${PRECISION}e" "$val" | sed 's/e+0*/e+/; s/e-0*/e-/'
        else
            # Ensure zero is just "0"
            if (( $(awk "BEGIN { print ($abs_val == 0) }") )); then
                echo "0"
            else
                printf "%.${PRECISION}f" "$val" | sed 's/\.\{0,1\}0*$//'
            fi
        fi
    fi
}

# --- Calculation Logic ---
calculate() {
    local expr="$1"
    local raw_result=""
    
    # 0. Expression Length Limit (Performance & Stability)
    if [[ ${#expr} -gt 1000 ]]; then
        echo -e "${RED}ERR: EXPRESSION TOO LONG (MAX 1000 CHARS)${NC}"
        return 1
    fi

    # 1. Security: Strict input sanitization to prevent command injection
    if [[ "$expr" =~ [\$\`\{\}\[\]\;\&\|\\!<>] ]]; then
        echo -e "${RED}ERR: SECURITY VIOLATION - ILLEGAL CHARACTERS DETECTED${NC}"
        echo -e "${YELLOW}Tip: Only use standard math symbols and functions.${NC}"
        return 1
    fi

    # 2. Expand shorthand and Unit Suffixes (Optimized: Combined SED calls)
    expr=$(echo "$expr" | sed -E \
        -e 's/(sin|cos|tan|exp|ln|log|sqrt)([a-zA-Z0-9.]+)/\1(\2)/g' \
        -e 's/([0-9.]+)T\b/\(\1*10^12\)/g' -e 's/([0-9.]+)G\b/\(\1*10^9\)/g' -e 's/([0-9.]+)M\b/\(\1*10^6\)/g' \
        -e 's/([0-9.]+)k\b/\(\1*1000\)/g' -e 's/([0-9.]+)c\b/\(\1\/100\)/g' -e 's/([0-9.]+)m\b/\(\1\/1000\)/g' \
        -e 's/([0-9.]+)u\b/\(\1*10^-6\)/g' -e 's/([0-9.]+)n\b/\(\1*10^-9\)/g' -e 's/([0-9.]+)p\b/\(\1*10^-12\)/g' -e 's/([0-9.]+)f\b/\(\1*10^-15\)/g' \
        -e 's/([0-9.]+)km\b/\(\1*1000\)/g' -e 's/([0-9.]+)cm\b/\(\1\/100\)/g' -e 's/([0-9.]+)mm\b/\(\1\/1000\)/g' \
        -e 's/([0-9.]+)kg\b/\(\1*1000\)/g' -e 's/([0-9.]+)ton\b/\(\1*10^6\)/g')

    # 3. Implicit Multiplication Support
    expr=$(echo "$expr" | sed -E \
        -e 's/([0-9.]+)\(/\1*(/g' -e 's/\)([0-9.]+)/)*\1/g' -e 's/\)\(/\)*( /g' \
        -e 's/([0-9.]+)(pi|ans|sin|cos|tan|ln|log|exp|sqrt)/\1*\2/g')

    # 4. Handle Constants (Curriculum Accurate)
    local PI_VAL="3.14159265358979323846"
    expr=$(echo "$expr" | sed -E \
        -e "s/\bpi\b/$PI_VAL/g" -e 's/\be\b/2.71828182845905/g' -e 's/\bc\b/(3*10^8)/g' \
        -e 's/\bG\b/(6.674*10^-11)/g' -e 's/\bh\b/(6.626*10^-34)/g' -e 's/\bqe\b/(1.602*10^-19)/g' \
        -e 's/\bNa\b/(6.022*10^23)/g' -e 's/\bkb\b/(1.381*10^-23)/g')

    # 5. Replace 'ans' with the last result
    expr=${expr//ans/"$LAST_RESULT"}

    # 6. Handle Degree Conversion
    if [[ "$ANGLE_MODE" == "deg" ]]; then
        # Domain Check: tan(90), tan(270), etc.
        if [[ "$expr" =~ tan\(([^)]+)\) ]]; then
            local angle=$(echo "${BASH_REMATCH[1]}" | bc -l 2>/dev/null || awk "BEGIN { print ${BASH_REMATCH[1]} }")
            if is_num "$angle"; then
                local check=$(awk "BEGIN { print (($angle - 90) % 180 == 0) }")
                if [[ "$check" == "1" ]]; then
                    echo -e "${RED}ERR: TAN UNDEFINED AT $((angle))°${NC}"
                    return 1
                fi
            fi
        fi
        expr=$(echo "$expr" | sed -E \
            -e "s/sin\(([^)]+)\)/SIN((\1)*${PI_VAL}\/180)/g" \
            -e "s/cos\(([^)]+)\)/COS((\1)*${PI_VAL}\/180)/g" \
            -e "s/tan\(([^)]+)\)/TAN((\1)*${PI_VAL}\/180)/g")
    else
        expr=$(echo "$expr" | sed -E -e 's/sin\(([^)]+)\)/SIN(\1)/g' -e 's/cos\(([^)]+)\)/COS(\1)/g' -e 's/tan\(([^)]+)\)/TAN(\1)/g')
    fi

    # 7. Domain Validation (Log/Ln/Sqrt)
    if [[ "$expr" =~ (ln|log|sqrt)\(([^)]+)\) ]]; then
        local func="${BASH_REMATCH[1]}"
        local val_expr="${BASH_REMATCH[2]}"
        local val=$(echo "$val_expr" | bc -l 2>/dev/null || awk "BEGIN { print $val_expr }")
        if is_num "$val"; then
            if [[ "$func" =~ ^l && $(awk "BEGIN { print ($val <= 0) }") == "1" ]]; then
                echo -e "${RED}ERR: $func UNDEFINED FOR $val${NC}"
                return 1
            elif [[ "$func" == "sqrt" && $(awk "BEGIN { print ($val < 0) }") == "1" ]]; then
                echo -e "${RED}ERR: SQRT OF NEGATIVE NUMBER${NC}"
                return 1
            fi
        fi
    fi

    # 8. Handle 'v' root, 'exp', and 'log' functions
    expr=$(echo "$expr" | sed -E \
        -e 's/([0-9.eE+-]+) v ([0-9.eE+-]+)/ROOT(\1,\2)/g' \
        -e 's/exp\(([^)]+)\)/EXP(\1)/g' -e 's/ln\(([^)]+)\)/LN(\1)/g' \
        -e 's/log\(([^,]+),([^)]+)\)/LOGB(\1,\2)/g' -e 's/log\(([^,)]+)\)/LOG10(\1)/g')

    # 8. Execute with BC or AWK
    if command -v bc >/dev/null 2>&1; then
        local bc_expr=$(echo "$expr" | sed -E \
            -e 's/([0-9.eE+-]+)\^([0-9.eE+-]+)/e(l(\1)*(\2))/g' \
            -e 's/SIN\(/s(/g' -e 's/COS\(/c(/g' -e 's/TAN\(([^)]+)\)/(s(\1)\/c(\1))/g' \
            -e 's/ROOT\(([^,]+),([^)]+)\)/e(l(\1)\/\2)/g' -e 's/EXP\(([^)]+)\)/e(\1)/g' \
            -e 's/LN\(([^)]+)\)/l(\1)/g' -e 's/LOGB\(([^,]+),([^)]+)\)/(l(\2)\/l(\1))/g' \
            -e 's/LOG10\(([^)]+)\)/(l(\1)\/l(10))/g')
        raw_result=$(echo "scale=20; $bc_expr" | bc -l 2>/dev/null)
    elif command -v awk >/dev/null 2>&1; then
        local awk_expr=$(echo "$expr" | sed -E \
            -e 's/SIN\(/sin(/g' -e 's/COS\(/cos(/g' -e 's/TAN\(([^)]+)\)/(sin(\1)\/cos(\1))/g' \
            -e 's/ROOT\(([^,]+),([^)]+)\)/(\1^(1\/\2))/g' -e 's/EXP\(/exp(/g' \
            -e 's/LN\(([^)]+)\)/log(\1)/g' -e 's/LOGB\(([^,]+),([^)]+)\)/(log(\2)\/log(\1))/g' \
            -e 's/LOG10\(([^)]+)\)/(log(\1)\/log(10))/g')
        raw_result=$(awk "BEGIN { printf \"%.15g\", $awk_expr }" 2>/dev/null)
    fi

    if [[ -z "$raw_result" ]]; then
        echo -e "${RED}ERR: INVALID EXPRESSION${NC}"
        echo -e "${YELLOW}Tips:${NC}"
        if [[ "$1" =~ /0 ]]; then
            echo -e "  ${CYAN}•${NC} Division by zero is undefined."
        elif [[ "$1" =~ \(\) ]]; then
            echo -e "  ${CYAN}•${NC} Empty parentheses are not allowed."
        else
            echo -e "  ${CYAN}•${NC} Check for missing operators (e.g., use '5 * x' or '5x')."
            echo -e "  ${CYAN}•${NC} Ensure parentheses are balanced."
            echo -e "  ${CYAN}•${NC} Scientific notation: Use '1e10' or '1e-10' (max 10^100)."
        fi
        return 1
    fi

    local final_result=$(format_result "$raw_result")
    LAST_RESULT="$raw_result"
    ((COUNT++))

    # Log to history
    echo "$1 = $final_result" >> "$HISTORY_FILE"

    echo -e "  ${MAGENTA}╔══════════════════════════════════════════════╗${NC}"
    echo -ne "  ${MAGENTA}║${GREEN} Result: ${WHITE}$final_result" 
    # Dynamic padding for the box
    local line=" Result: $final_result"
    local pad=$((46 - ${#line}))
    printf "%${pad}s${MAGENTA}║${NC}${GRAY}█${NC}\n" ""
    echo -e "  ${MAGENTA}╚══════════════════════════════════════════════╝${NC}${GRAY}█${NC}"
    echo -e "   ${GRAY}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${NC}"
}

# --- New Professional Unit Converter Engine ---
nested_conv_engine() {
    local category=$1
    local names_str=$2
    local factors_str=$3
    local offsets_str=$4

    local names=($names_str)
    local factors=($factors_str)
    local offsets=($offsets_str)

    while true; do
        clear
        echo -e "  ${MAGENTA}╔══════════════════════════════════════════════╗${NC}"
        echo -e "  ${MAGENTA}║${WHITE}          CONVERTER: $category            ${MAGENTA}║${NC}${GRAY}█${NC}"
        echo -e "  ${MAGENTA}╠══════════════════════════════════════════════╣${NC}${GRAY}█${NC}"
        
        # List units in 2 columns
        echo -e "    ${WHITE}Available Units:${NC}"
        local count=${#names[@]}
        for ((i=0; i<count; i++)); do
            printf "    [${YELLOW}%2d${NC}] %-15s" "$((i+1))" "${names[$i]}"
            [[ $(( (i+1) % 2 )) -eq 0 ]] && echo -ne "  ${MAGENTA}║${NC}${GRAY}█${NC}\n"
        done
        if [[ $(( count % 2 )) -ne 0 ]]; then
            printf "%-21s" ""
            echo -ne "  ${MAGENTA}║${NC}${GRAY}█${NC}\n"
        fi
        echo -e "  ${MAGENTA}╚══════════════════════════════════════════════╝${NC}${GRAY}█${NC}"
        echo -e "   ${GRAY}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${NC}"

        read -p "  Select SOURCE unit [1-$count]: " from_idx
        read -p "  Enter VALUE (or 'ans'): " val_in
        read -p "  Select TARGET unit [1-$count]: " to_idx

        # Handle 'ans'
        local val=$val_in
        [[ "${val,,}" == "ans" ]] && val=$LAST_RESULT

        # Validation
        if [[ ! "$from_idx" =~ ^[0-9]+$ ]] || [[ "$from_idx" -gt "$count" ]] || [[ "$from_idx" -lt 1 ]] || \
           [[ ! "$to_idx" =~ ^[0-9]+$ ]] || [[ "$to_idx" -gt "$count" ]] || [[ "$to_idx" -lt 1 ]]; then
            echo -e "  ${RED}Invalid selection.${NC}"; sleep 1; break
        fi

        if ! is_num "$val"; then
            echo -e "  ${RED}Invalid numeric value: $val${NC}"; sleep 1; break
        fi

        local f_idx=$((from_idx - 1))
        local t_idx=$((to_idx - 1))
        
        # Offsets
        local o_from=${offsets[$f_idx]:-0}
        local o_to=${offsets[$t_idx]:-0}

        # Physical Boundary Check (Absolute Zero)
        if [[ "$category" == "Temperature" ]]; then
            local k_val=$(awk "BEGIN { print ($val * ${factors[$f_idx]} + $o_from) }")
            if (( $(awk "BEGIN { print ($k_val < -0.0001) }") )); then
                echo -e "  ${RED}ERR: Physically impossible temperature (below 0K).${NC}"
                sleep 1; break
            fi
        fi

        # Calculation
        local res=$(awk "BEGIN { printf \"%.15g\", (($val * ${factors[$f_idx]} + $o_from) - $o_to) / ${factors[$t_idx]} }")
        local final=$(format_result "$res")

        echo -e "\n  ${MAGENTA}╔══════════════════════════════════════════════╗${NC}"
        echo -ne "  ${MAGENTA}║${GREEN} Result: ${WHITE}$val_in ${names[$f_idx]} = $final ${names[$t_idx]}"
        local line=" Result: $val_in ${names[$f_idx]} = $final ${names[$t_idx]}"
        local pad=$((46 - ${#line}))
        (( pad < 0 )) && pad=0
        printf "%${pad}s${MAGENTA}║${NC}${GRAY}█${NC}\n" ""
        echo -e "  ${MAGENTA}╚══════════════════════════════════════════════╝${NC}${GRAY}█${NC}"
        
        echo "Conv: $val_in ${names[$f_idx]} -> $final ${names[$t_idx]}" >> "$HISTORY_FILE"
        
        read -p "  Another conversion in this category? (y/n): " again
        [[ "${again,,}" != "y" ]] && break
    done
}

show_unit_converter() {
    echo -e "${YELLOW}┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${WHITE}           VALTY PROFESSIONAL CONVERTER           ${YELLOW}│${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────────────┤${NC}"
    echo -e "  [1] Electricity         [6] Energy & Work      "
    echo -e "  [2] Length & Distance   [7] Force & Power      "
    echo -e "  [3] Mass & Weight       [8] Temperature        "
    echo -e "  [4] Volume & Liquid     [9] Time & Area        "
    echo -e "  [5] Pressure            [10] Others (Data)     "
    echo -e "${YELLOW}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}  [b] ⬅️  Back to Main OS                           ${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────────────┘${NC}"
    read -p "Select Category: " cat
    [[ "$cat" == "b" ]] && { show_header; return; }

    case $cat in
        1) conv_electricity ;;
        2) conv_length ;;
        3) conv_mass ;;
        4) conv_volume ;;
        5) conv_pressure ;;
        6) conv_energy ;;
        7) conv_force_power ;;
        8) conv_temperature ;;
        9) conv_time_area ;;
        10) conv_others ;;
        *) echo -e "${RED}Invalid category.${NC}"; sleep 1; show_unit_converter ;;
    esac
}

# --- Conversion Sub-Menus ---

conv_electricity() {
    echo -e "${CYAN}--- ELECTRICITY ---${NC}"
    echo -e " [1] Capacitance (Farads)"
    echo -e " [2] Current (Amps)"
    echo -e " [3] Charge (Coulombs)"
    echo -e " [4] Resistance (Ohms)"
    read -p "Select: " sub
    case $sub in
        1) # Capacitance
            local names="MF kF F mF uF nF pF"
            local factors="1e6 1e3 1 1e-3 1e-6 1e-9 1e-12"
            nested_conv_engine "Capacitance" "$names" "$factors" ;;
        2) # Current
            local names="MA kA A mA uA nA pA"
            local factors="1e6 1e3 1 1e-3 1e-6 1e-9 1e-12"
            nested_conv_engine "Current" "$names" "$factors" ;;
        3) # Charge
            local names="MC kC C mC uC nC pC"
            local factors="1e6 1e3 1 1e-3 1e-6 1e-9 1e-12"
            nested_conv_engine "Charge" "$names" "$factors" ;;
        4) # Resistance
            local names="Gohm Mohm kohm ohm mohm"
            local factors="1e9 1e6 1e3 1 1e-3"
            nested_conv_engine "Resistance" "$names" "$factors" ;;
    esac
    show_unit_converter
}

conv_length() {
    echo -e "${CYAN}--- LENGTH & DISTANCE ---${NC}"
    echo -e " [1] Metric (SI)"
    echo -e " [2] Imperial/Other"
    read -p "Select System: " sys
    if [[ "$sys" == "1" ]]; then
        local names="km m dm cm mm um nm pm Angstrom"
        local factors="1000 1 0.1 0.01 1e-3 1e-6 1e-9 1e-12 1e-10"
        nested_conv_engine "Length (Metric)" "$names" "$factors"
    else
        local names="nmi mi furlong yd ft in"
        local factors="1852 1609.34 201.168 0.9144 0.3048 0.0254"
        nested_conv_engine "Length (Imperial)" "$names" "$factors"
    fi
    show_unit_converter
}

conv_mass() {
    echo -e "${CYAN}--- MASS & WEIGHT ---${NC}"
    echo -e " [1] Metric (SI)"
    echo -e " [2] Imperial/Other"
    read -p "Select System: " sys
    if [[ "$sys" == "1" ]]; then
        local names="ton kg g mg ug"
        local factors="1000 1 1e-3 1e-6 1e-9"
        nested_conv_engine "Mass (Metric)" "$names" "$factors"
    else
        local names="st lb oz slug"
        local factors="6.35029 0.453592 0.0283495 14.5939"
        nested_conv_engine "Mass (Imperial)" "$names" "$factors"
    fi
    show_unit_converter
}

conv_volume() {
    echo -e "${CYAN}--- VOLUME & LIQUID ---${NC}"
    echo -e " [1] Metric (SI)"
    echo -e " [2] Imperial/Other"
    read -p "Select System: " sys
    if [[ "$sys" == "1" ]]; then
        local names="m3 L mL uL"
        local factors="1000 1 1e-3 1e-6"
        nested_conv_engine "Volume (Metric)" "$names" "$factors"
    else
        local names="gal qt pt cup floz"
        local factors="3.78541 0.946353 0.473176 0.236588 0.0295735"
        nested_conv_engine "Volume (Imperial)" "$names" "$factors"
    fi
    show_unit_converter
}

conv_pressure() {
    echo -e "${CYAN}--- PRESSURE ---${NC}"
    echo -e " [1] Metric (SI/Pascal)"
    echo -e " [2] Other (atm/bar/Torr)"
    read -p "Select System: " sys
    if [[ "$sys" == "1" ]]; then
        local names="GPa MPa kPa hPa Pa"
        local factors="1e9 1e6 1000 100 1"
        nested_conv_engine "Pressure (Metric)" "$names" "$factors"
    else
        local names="atm bar psi mmHg Torr inHg"
        # Factors relative to Pascal (1 atm = 101325 Pa)
        local factors="101325 100000 6894.76 133.322 133.322 3386.39"
        nested_conv_engine "Pressure (Other)" "$names" "$factors"
    fi
    show_unit_converter
}

conv_energy() {
    echo -e "${CYAN}--- ENERGY & WORK ---${NC}"
    echo -e " [1] Metric (Joule/Watt-hr)"
    echo -e " [2] Other (cal/eV/BTU)"
    read -p "Select System: " sys
    if [[ "$sys" == "1" ]]; then
        local names="GJ MJ kJ J kWh Wh"
        local factors="1e9 1e6 1000 1 3600000 3600"
        nested_conv_engine "Energy (Metric)" "$names" "$factors"
    else
        local names="kcal cal eV BTU ftlb"
        # Factors relative to Joule
        local factors="4184 4.184 1.60218e-19 1055.06 1.35582"
        nested_conv_engine "Energy (Other)" "$names" "$factors"
    fi
    show_unit_converter
}

conv_force_power() {
    echo -e "${CYAN}--- FORCE & POWER ---${NC}"
    echo -e " [1] Force (N/lbf)"
    echo -e " [2] Power (W/hp)"
    read -p "Select: " sub
    if [[ "$sub" == "1" ]]; then
        local names="MN kN N kgf lbf"
        local factors="1e6 1000 1 9.80665 4.44822"
        nested_conv_engine "Force" "$names" "$factors"
    else
        local names="MW kW W hp BTU/h"
        local factors="1e6 1000 1 745.7 0.293071"
        nested_conv_engine "Power" "$names" "$factors"
    fi
    show_unit_converter
}

conv_others() {
    echo -e "${CYAN}--- OTHERS ---${NC}"
    echo -e " [1] Velocity"
    echo -e " [2] Data Storage"
    echo -e " [3] Frequency"
    echo -e " [4] Density"
    read -p "Select: " sub
    case $sub in
        1) local names="m/s km/h mph knot ft/s"
           local factors="1 0.277778 0.44704 0.514444 0.3048"
           nested_conv_engine "Velocity" "$names" "$factors" ;;
        2) local names="PB TB GB MB KB B"
           local factors="1125899906842624 1099511627776 1073741824 1048576 1024 1"
           nested_conv_engine "Data Storage" "$names" "$factors" ;;
        3) local names="THz GHz MHz kHz Hz"
           local factors="1e12 1e9 1e6 1000 1"
           nested_conv_engine "Frequency" "$names" "$factors" ;;
        4) local names="g/cm3 kg/m3 lb/ft3 lb/in3"
           local factors="1000 1 16.0185 27679.9"
           nested_conv_engine "Density" "$names" "$factors" ;;
    esac
    show_unit_converter
}

conv_temperature() {
    echo -e "${CYAN}--- TEMPERATURE ---${NC}"
    # Base unit: Kelvin (K)
    local names="Celsius(C) Fahrenheit(F) Kelvin(K) Rankine(R)"
    local factors="1 0.555555555555556 1 0.555555555555556"
    local offsets="273.15 255.372222222222 0 0"
    nested_conv_engine "Temperature" "$names" "$factors" "$offsets"
    show_unit_converter
}

conv_time_area() {
    echo -e "${CYAN}--- TIME & AREA ---${NC}"
    echo -e " [1] Time"
    echo -e " [2] Area"
    read -p "Select: " sub
    if [[ "$sub" == "1" ]]; then
        local names="year month week day hr min s ms us ns"
        local factors="31557600 2629743 604800 86400 3600 60 1 1e-3 1e-6 1e-9"
        nested_conv_engine "Time" "$names" "$factors"
    else
        local names="km2 hectare acre m2 yd2 ft2 in2 cm2 mm2"
        local factors="1e6 10000 4046.86 1 0.836127 0.092903 0.00064516 1e-4 1e-6"
        nested_conv_engine "Area" "$names" "$factors"
    fi
    show_unit_converter
}



# --- Thanaweya Amma Physics Solver (Full Curriculum) ---
display_physics_res() {
    local label=$1; local value=$2; local unit=$3
    local final=$(format_result "$value")
    echo -e "\n  ${MAGENTA}╔══════════════════════════════════════════════╗${NC}"
    echo -ne "  ${MAGENTA}║${GREEN} ${label}: ${WHITE}$final $unit"
    local line=" ${label}: $final $unit"
    local pad=$((46 - ${#line}))
    (( pad < 0 )) && pad=0
    printf "%${pad}s${MAGENTA}║${NC}${GRAY}█${NC}\n" ""
    echo -e "  ${MAGENTA}╚══════════════════════════════════════════════╝${NC}${GRAY}█${NC}"
    echo "Physics Solve: $label = $final $unit" >> "$HISTORY_FILE"
}

solve_ch1() { # DC Circuits
    echo -e "${CYAN}--- CH1: DC CIRCUITS ---${NC}"
    echo -e " [1] Resistance (Parallel/Series) [2] Current/Voltage Division"
    echo -e " [3] Resistivity & Conductivity    [4] Ohm's Closed Circuit"
    read -p "Select: " sub
    case $sub in
        1) read -p "Type (p/s): " t; read -p "Enter values (space separated): " -a r
           local res=0
           for x in "${r[@]}"; do
                if ! is_num "$x"; then echo -e "${RED}Invalid input: $x${NC}"; return; fi
                if (( $(awk "BEGIN { print ($x < 0) }") )); then echo -e "${RED}Resistance cannot be negative.${NC}"; return; fi
           done
           if [[ "$t" == "s" ]]; then
                for x in "${r[@]}"; do res=$(awk "BEGIN { print $res + $x }"); done
           else
                for x in "${r[@]}"; do res=$(awk "BEGIN { print $res + (1/$x) }"); done
                res=$(awk "BEGIN { print 1/$res }")
           fi
           display_physics_res "Req ($t)" "$res" "ohm" ;;
        2) echo -e " [a] Current Div [b] Voltage Div"; read -p "Option: " o
           if [[ "$o" == "a" ]]; then
                read -p "Total I: " it; read -p "R branch: " rb; read -p "R other: " ro
                if ! is_num "$it" || ! is_num "$rb" || ! is_num "$ro"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local res=$(awk "BEGIN { printf \"%.15g\", $it * ($ro / ($rb + $ro)) }")
                display_physics_res "I branch" "$res" "A"
           else
                read -p "Total V: " vt; read -p "R target: " rt; read -p "R total: " rall
                if ! is_num "$vt" || ! is_num "$rt" || ! is_num "$rall"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local res=$(awk "BEGIN { printf \"%.15g\", $vt * ($rt / $rall) }")
                display_physics_res "V branch" "$res" "V"
           fi ;;
        3) read -p "R (ohm): " r; read -p "A (m²): " a; read -p "L (m): " l
           if ! is_num "$r" || ! is_num "$a" || ! is_num "$l"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           local rho=$(awk "BEGIN { printf \"%.15g\", ($r * $a) / $l }")
           local sigma=$(awk "BEGIN { printf \"%.15g\", 1 / $rho }")
           display_physics_res "Resistivity" "$rho" "ohm.m"
           display_physics_res "Conductivity" "$sigma" "S/m" ;;
        4) read -p "VB (V): " vb; read -p "Req (ohm): " req; read -p "r (ohm): " rint
           if ! is_num "$vb" || ! is_num "$req" || ! is_num "$rint"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           local i=$(awk "BEGIN { printf \"%.15g\", $vb / ($req + $rint) }")
           display_physics_res "Total I" "$i" "A" ;;
    esac
    read -p " Solve another in CH1? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_ch1; return; }
}

solve_ch2() { # Magnetism
    local PI_VAL="3.14159265358979323846"
    local u0=$(awk "BEGIN { print 4 * $PI_VAL * 1e-7 }")
    echo -e "${CYAN}--- CH2: MAGNETISM ---${NC}"
    echo -e " [1] Flux (Φm) & Density (B)  [2] Wire Magnetism (Str, Circ, Spir)"
    echo -e " [3] Magnetic Force (F)       [4] Meters (Ammeter, Voltmeter, Ohm)"
    read -p "Select: " sub
    case $sub in
        1) read -p "B (T): " b; read -p "A (m²): " a; read -p "θ (deg): " th
           if ! is_num "$b" || ! is_num "$a" || ! is_num "$th"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           local flux=$(awk "BEGIN { printf \"%.15g\", $b * $a * sin($th * $PI_VAL / 180) }")
           display_physics_res "Flux" "$flux" "Wb" ;;
        2) echo -e " [a] Straight [b] Circular [c] Spiral"; read -p "Opt: " o
           read -p "I (A): " i
           if ! is_num "$i"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           if [[ "$o" == "a" ]]; then
                read -p "d (m): " d; if ! is_num "$d"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local res=$(awk "BEGIN { printf \"%.15g\", (2e-7 * $i) / $d }")
           elif [[ "$o" == "b" ]]; then
                read -p "N: " n; read -p "r (m): " r; if ! is_num "$n" || ! is_num "$r"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local res=$(awk "BEGIN { printf \"%.15g\", ($u0 * $n * $i) / (2 * $r) }")
           else
                read -p "N: " n; read -p "L (m): " l; if ! is_num "$n" || ! is_num "$l"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local res=$(awk "BEGIN { printf \"%.15g\", ($u0 * $n * $i) / $l }")
           fi
           display_physics_res "B Density" "$res" "T" ;;
        3) read -p "B (T): " b; read -p "I (A): " i; read -p "L (m): " l; read -p "θ (deg): " th
           if ! is_num "$b" || ! is_num "$i" || ! is_num "$l" || ! is_num "$th"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           local f=$(awk "BEGIN { printf \"%.15g\", $b * $i * $l * sin($th * $PI_VAL / 180) }")
           display_physics_res "Force" "$f" "N" ;;
        4) echo -e " [a] Ammeter (Rs) [b] Voltmeter (Rm) [c] Ohmeter"; read -p "Opt: " o
           if [[ "$o" == "a" ]]; then
                read -p "Ig: " ig; read -p "Rg: " rg; read -p "I: " imax
                if ! is_num "$ig" || ! is_num "$rg" || ! is_num "$imax"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local rs=$(awk "BEGIN { printf \"%.15g\", ($ig * $rg) / ($imax - $ig) }")
                display_physics_res "Shunt Rs" "$rs" "ohm"
           elif [[ "$o" == "b" ]]; then
                read -p "Ig: " ig; read -p "Rg: " rg; read -p "V: " vmax
                if ! is_num "$ig" || ! is_num "$rg" || ! is_num "$vmax"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local rm=$(awk "BEGIN { printf \"%.15g\", ($vmax / $ig) - $rg }")
                display_physics_res "Multiplier Rm" "$rm" "ohm"
           else
                read -p "VB: " vb; read -p "Rtotal: " rt; read -p "I: " i
                if ! is_num "$vb" || ! is_num "$rt" || ! is_num "$i"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local rx=$(awk "BEGIN { printf \"%.15g\", ($vb / $i) - $rt }")
                display_physics_res "Unknown Rx" "$rx" "ohm"
           fi ;;
    esac
    read -p " Solve another in CH2? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_ch2; return; }
}

solve_ch3() { # Induction
    echo -e "${CYAN}--- CH3: INDUCTION ---${NC}"
    echo -e " [1] Faraday (EMF)   [2] Induction (Self/Mutual/Wire)"
    echo -e " [3] Dynamo (AC)     [4] Transformer"
    read -p "Select: " sub
    case $sub in
        1) read -p "N: " n; read -p "ΔΦ (Wb): " dphi; read -p "Δt (s): " dt
           if ! is_num "$n" || ! is_num "$dphi" || ! is_num "$dt"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           local res=$(awk "BEGIN { printf \"%.15g\", $n * ($dphi / $dt) }")
           display_physics_res "EMF" "$res" "V" ;;
        2) echo -e " [a] Self [b] Mutual [c] Wire"; read -p "Opt: " o
           if [[ "$o" == "c" ]]; then
                read -p "B (T): " b; read -p "L (m): " l; read -p "v (m/s): " v; read -p "θ (deg): " th
                if ! is_num "$b" || ! is_num "$l" || ! is_num "$v" || ! is_num "$th"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local res=$(awk "BEGIN { printf \"%.15g\", $b * $l * $v * sin($th * 3.14159265358979 / 180) }")
                display_physics_res "EMF Wire" "$res" "V"
           else
                read -p "Coeff (L/M): " c; read -p "ΔI: " di; read -p "Δt: " dt
                if ! is_num "$c" || ! is_num "$di" || ! is_num "$dt"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local res=$(awk "BEGIN { printf \"%.15g\", $c * ($di / $dt) }")
                display_physics_res "EMF Induction" "$res" "V"
           fi ;;
        3) read -p "N: " n; read -p "A (m²): " a; read -p "B (T): " b; read -p "ω (rad/s) or 2πf: " w
           if ! is_num "$n" || ! is_num "$a" || ! is_num "$b" || ! is_num "$w"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           local max=$(awk "BEGIN { printf \"%.15g\", $n * $a * $b * $w }")
           display_physics_res "EMF Max" "$max" "V" ;;
        4) read -p "Vp: " vp; read -p "Np: " np; read -p "Ns: " ns; read -p "Eff (%): " eff
           if ! is_num "$vp" || ! is_num "$np" || ! is_num "$ns" || ! is_num "$eff"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           local vs=$(awk "BEGIN { printf \"%.15g\", ($vp * $ns / $np) * ($eff / 100) }")
           display_physics_res "Vs (Secondary)" "$vs" "V" ;;
    esac
    read -p " Solve another in CH3? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_ch3; return; }
}

solve_ch4() { # AC Circuits
    local PI_VAL="3.14159265358979323846"
    echo -e "${CYAN}--- CH4: AC CIRCUITS ---${NC}"
    echo -e " [1] Simple (XL, XC)  [2] Advanced (Z, Resonance)"
    read -p "Select: " sub
    if [[ "$sub" == "1" ]]; then
        read -p "Type (L/C): " t; read -p "f (Hz): " f; read -p "Value (H/F): " v
        if ! is_num "$f" || ! is_num "$v"; then echo -e "${RED}Invalid input.${NC}"; return; fi
        if [[ "$t" == "L" ]]; then
            local res=$(awk "BEGIN { printf \"%.15g\", 2 * $PI_VAL * $f * $v }")
            display_physics_res "XL" "$res" "ohm"
        else
            local res=$(awk "BEGIN { printf \"%.15g\", 1 / (2 * $PI_VAL * $f * $v) }")
            display_physics_res "XC" "$res" "ohm"
        fi
    else
        read -p "R: " r; read -p "XL: " xl; read -p "XC: " xc
        if ! is_num "$r" || ! is_num "$xl" || ! is_num "$xc"; then echo -e "${RED}Invalid input.${NC}"; return; fi
        local z=$(awk "BEGIN { printf \"%.15g\", sqrt($r^2 + ($xl - $xc)^2) }")
        display_physics_res "Impedance Z" "$z" "ohm"
        local ph=$(awk "BEGIN { printf \"%.15g\", atan2(($xl - $xc), $r) * 180 / $PI_VAL }")
        display_physics_res "Phase Angle" "$ph" "deg"
    fi
    read -p " Solve another in CH4? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_ch4; return; }
}

solve_modern() { # CH5-8
    local h=6.626e-34 c=3e8 qe=1.602e-19 me=9.1e-31
    echo -e "${CYAN}--- MODERN PHYSICS (CH5-8) ---${NC}"
    echo -e " [5] Photoelectric & Wave  [6] Atomic & X-Ray"
    echo -e " [7] LASER Properties      [8] Electronics & Gates"
    read -p "Select Chapter: " ch
    case $ch in
        5) echo -e " [a] Photoelectric [b] De Broglie"; read -p "Opt: " o
           if [[ "$o" == "a" ]]; then
                read -p "f (Hz): " f; read -p "Ew (J): " ew
                if ! is_num "$f" || ! is_num "$ew"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local ke=$(awk "BEGIN { printf \"%.15g\", ($h * $f) - $ew }")
                display_physics_res "KE max" "$ke" "J"
           else
                read -p "Velocity v: " v; if ! is_num "$v"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local res=$(awk "BEGIN { printf \"%.15g\", $h / ($me * $v) }")
                display_physics_res "λ" "$res" "m"
           fi ;;
        6) read -p "Energy Level n: " n
           if ! is_num "$n"; then echo -e "${RED}Invalid input.${NC}"; return; fi
           local res=$(awk "BEGIN { printf \"%.15g\", -13.6 / ($n^2) }")
           display_physics_res "En (Hydrogen)" "$res" "eV" ;;
        8) echo -e " [a] Transistor (β, α) [b] Logic Gates"; read -p "Opt: " o
           if [[ "$o" == "a" ]]; then
                read -p "Ic: " ic; read -p "Ib: " ib
                if ! is_num "$ic" || ! is_num "$ib"; then echo -e "${RED}Invalid input.${NC}"; return; fi
                local beta=$(awk "BEGIN { print $ic / $ib }")
                local alpha=$(awk "BEGIN { print $beta / (1 + $beta) }")
                display_physics_res "Beta (β)" "$beta" ""; display_physics_res "Alpha (α)" "$alpha" ""
           else
                echo -e " [1] NOT [2] AND [3] OR"; read -p "Gate: " g
                case $g in
                    1) read -p "Input (0/1): " a
                       if [[ "$a" =~ ^[01]$ ]]; then
                           [[ $a -eq 0 ]] && display_physics_res "OUT" "1" "" || display_physics_res "OUT" "0" ""
                       else echo -e "${RED}0/1 only.${NC}"; fi ;;
                    2) read -p "A (0/1): " a; read -p "B (0/1): " b
                       if [[ "$a" =~ ^[01]$ && "$b" =~ ^[01]$ ]]; then
                           [[ $a -eq 1 && $b -eq 1 ]] && display_physics_res "OUT" "1" "" || display_physics_res "OUT" "0" ""
                       else echo -e "${RED}0/1 only.${NC}"; fi ;;
                    3) read -p "A (0/1): " a; read -p "B (0/1): " b
                       if [[ "$a" =~ ^[01]$ && "$b" =~ ^[01]$ ]]; then
                           [[ $a -eq 1 || $b -eq 1 ]] && display_physics_res "OUT" "1" "" || display_physics_res "OUT" "0" ""
                       else echo -e "${RED}0/1 only.${NC}"; fi ;;
                esac
           fi ;;
        *) echo -e "${WHITE}LASER Properties: Coherence, Collimation, Monochromaticity, High Intensity.${NC}" ;;
    esac
    read -p " Solve another in Modern? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_modern; return; }
}

solve_simul() {
    echo -e "${CYAN}--- SIMULTANEOUS EQUATIONS ---${NC}"
    echo -e " [1] 2 Unknowns (x, y)  [2] 3 Unknowns (x, y, z)"
    read -p "Select: " sub
    if [[ "$sub" == "1" ]]; then
        echo -e " Format: a1x + b1y = c1\n         a2x + b2y = c2"
        read -p "a1: " a1; read -p "b1: " b1; read -p "c1: " c1
        read -p "a2: " a2; read -p "b2: " b2; read -p "c2: " c2
        if ! is_num "$a1" || ! is_num "$b1" || ! is_num "$c1" || ! is_num "$a2" || ! is_num "$b2" || ! is_num "$c2"; then echo -e "${RED}Invalid input.${NC}"; return; fi
        local det=$(awk "BEGIN { printf \"%.15g\", ($a1*$b2) - ($a2*$b1) }")
        if (( $(awk "BEGIN { print ($det == 0) }") )); then
            echo -e "${RED}No unique solution (Det = 0)${NC}"
        else
            local dx=$(awk "BEGIN { printf \"%.15g\", ($c1*$b2) - ($c2*$b1) }")
            local dy=$(awk "BEGIN { printf \"%.15g\", ($a1*$c2) - ($a2*$c1) }")
            local x=$(format_result $(awk "BEGIN { print $dx/$det }"))
            local y=$(format_result $(awk "BEGIN { print $dy/$det }"))
            echo -e "${GREEN}Solution: x = $x, y = $y${NC}"
        fi
    else
        echo -e " Format: a1x + b1y + c1z = d1 (etc.)"
        read -p "Row 1 (a1 b1 c1 d1): " a1 b1 c1 d1
        read -p "Row 2 (a2 b2 c2 d2): " a2 b2 c2 d2
        read -p "Row 3 (a3 b3 c3 d3): " a3 b3 c3 d3
        if ! is_num "$a1" || ! is_num "$b1" || ! is_num "$c1" || ! is_num "$d1" || ! is_num "$a2" || ! is_num "$b2" || ! is_num "$c2" || ! is_num "$d2" || ! is_num "$a3" || ! is_num "$b3" || ! is_num "$c3" || ! is_num "$d3"; then echo -e "${RED}Invalid input.${NC}"; return; fi
        local det=$(awk "BEGIN { printf \"%.15g\", $a1*($b2*$c3-$b3*$c2) - $b1*($a2*$c3-$a3*$c2) + $c1*($a2*$b3-$a3*$b2) }")
        if (( $(awk "BEGIN { print ($det == 0) }") )); then
            echo -e "${RED}No unique solution (Det = 0)${NC}"
        else
            local dx=$(awk "BEGIN { printf \"%.15g\", $d1*($b2*$c3-$b3*$c2) - $b1*($d2*$c3-$d3*$c2) + $c1*($d2*$b3-$d3*$b2) }")
            local dy=$(awk "BEGIN { printf \"%.15g\", $a1*($d2*$c3-$d3*$c2) - $d1*($a2*$c3-$a3*$c2) + $c1*($a2*$d3-$a3*$d2) }")
            local dz=$(awk "BEGIN { printf \"%.15g\", $a1*($b2*$d3-$b3*$d2) - $b1*($a2*$d3-$a3*$d2) + $d1*($a2*$b3-$a3*$b2) }")
            local x=$(format_result $(awk "BEGIN { print $dx/$det }"))
            local y=$(format_result $(awk "BEGIN { print $dy/$det }"))
            local z=$(format_result $(awk "BEGIN { print $dz/$det }"))
            echo -e "${GREEN}Solution: x = $x, y = $y, z = $z${NC}"
        fi
    fi
    read -p "Press any key to continue..." -n1 -s
}

gcd() {
    local a=${1%.*} b=${2%.*}
    while [ $b -ne 0 ]; do
        local t=$b
        b=$((a % b))
        a=$t
    done
    echo $a
}

solve_ratios() {
    echo -e "${CYAN}--- PROPORTIONAL SOLVER (a/b = c/d) ---${NC}"
    echo -e " Enter '?' for the unknown variable."
    read -p "Value a: " a; read -p "Value b: " b
    read -p "Value c: " c; read -p "Value d: " d
    
    # Validation: Ensure 3 numbers and 1 '?'
    local q_count=0
    [[ "$a" == "?" ]] && ((q_count++))
    [[ "$b" == "?" ]] && ((q_count++))
    [[ "$c" == "?" ]] && ((q_count++))
    [[ "$d" == "?" ]] && ((q_count++))
    
    if [[ $q_count -ne 1 ]]; then echo -e "${RED}Must have exactly one '?'${NC}"; return; fi
    
    for v in "$a" "$b" "$c" "$d"; do
        if [[ "$v" != "?" ]] && ! is_num "$v"; then echo -e "${RED}Invalid numeric input: $v${NC}"; return; fi
    done

    local res=""
    if [[ "$a" == "?" ]]; then res=$(awk "BEGIN { printf \"%.15g\", ($b * $c) / $d }")
    elif [[ "$b" == "?" ]]; then res=$(awk "BEGIN { printf \"%.15g\", ($a * $d) / $c }")
    elif [[ "$c" == "?" ]]; then res=$(awk "BEGIN { printf \"%.15g\", ($a * $d) / $b }")
    elif [[ "$d" == "?" ]]; then res=$(awk "BEGIN { printf \"%.15g\", ($b * $c) / $a }")
    fi
    
    if [[ -n "$res" ]]; then
        display_physics_res "Unknown" "$res" ""
    else
        echo -e "${RED}Calculation error.${NC}"
    fi
}

simplify_ratios() {
    echo -e "${CYAN}--- RATIO SIMPLIFIER (x : y : z) ---${NC}"
    read -p "Enter x, y, and z (space separated): " -a vals
    local count=${#vals[@]}
    if [[ $count -eq 0 ]]; then echo -e "${RED}No input.${NC}"; return; fi

    for v in "${vals[@]}"; do
        if ! is_num "$v"; then echo -e "${RED}Invalid numeric input: $v${NC}"; return; fi
    done
    
    # Normalize decimals (e.g. 0.5 1 1.5 -> 5 10 15)
    local max_d=0
    for v in "${vals[@]}"; do
        if [[ "$v" =~ \. ]]; then
            local d=${v#*.}
            [[ ${#d} -gt $max_d ]] && max_d=${#d}
        fi
    done
    
    local mult=$(awk "BEGIN { print 10^$max_d }")
    local int_vals=()
    for v in "${vals[@]}"; do
        int_vals+=($(awk "BEGIN { printf \"%.0f\", $v * $mult }"))
    done
    
    # Find GCD of all
    local common=${int_vals[0]}
    for ((i=1; i<count; i++)); do
        common=$(gcd $common ${int_vals[$i]})
    done
    
    # Divide and display
    local res=""
    for ((i=0; i<count; i++)); do
        local simplified=$(( int_vals[$i] / common ))
        res+="$simplified"
        [[ $i -lt $((count-1)) ]] && res+=" : "
    done
    
    echo -e "${GREEN}Simplified Ratio: $res${NC}"
}

# --- Equation Solver Menu ---
show_equation_solver() {
    echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${WHITE}      VALTY THANAWEYA AMMA PHYSICS OS    ${YELLOW}│${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "  [1] CH1: DC Circuits (Ohm/Req)          "
    echo -e "  [2] CH2: Magnetism & Force              "
    echo -e "  [3] CH3: Induction & Dynamo             "
    echo -e "  [4] CH4: AC Circuits (Z/Resonance)      "
    echo -e "  [5] CH5-8: Modern & Electronics         "
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "  [P] Polynomial (Linear/Quad)            "
    echo -e "  [S] Simultaneous (2-3 Unknowns)         "
    echo -e "  [R] Ratios & Proportions                "
    echo -e "  [b] Back to Main OS                     "
    echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
    read -p "Select option: " type
    [[ "$type" == "b" ]] && { show_header; return; }

    case ${type^^} in
        1) solve_ch1 ;;
        2) solve_ch2 ;;
        3) solve_ch3 ;;
        4) solve_ch4 ;;
        5) solve_modern ;;
        P) 
           echo -e " [1] Linear (ax+b=c) [2] Quadratic (ax2+bx+c=0)"
           read -p "Type: " pt
           if [[ "$pt" == "1" ]]; then
                read -p "a: " a; read -p "b: " b; read -p "c: " c
                if ! is_num "$a" || ! is_num "$b" || ! is_num "$c"; then echo -e "${RED}Invalid input.${NC}"; else
                    local x=$(awk "BEGIN { printf \"%.15g\", ($c - $b) / $a }")
                    echo -e "${GREEN}Solution: x = $(format_result "$x")${NC}"
                fi
           else
                read -p "a: " a; read -p "b: " b; read -p "c: " c
                if ! is_num "$a" || ! is_num "$b" || ! is_num "$c"; then echo -e "${RED}Invalid input.${NC}"; else
                    local d=$(awk "BEGIN { print ($b^2) - (4*$a*$c) }")
                    if (( $(awk "BEGIN { print ($d < 0) }") )); then echo -e "${RED}No real roots.${NC}"
                    else
                        local x1=$(awk "BEGIN { printf \"%.15g\", (-$b + sqrt($d)) / (2*$a) }")
                        local x2=$(awk "BEGIN { printf \"%.15g\", (-$b - sqrt($d)) / (2*$a) }")
                        echo -e "${GREEN}x1 = $(format_result "$x1"), x2 = $(format_result "$x2")${NC}"
                    fi
                fi
           fi ;;
        S) solve_simul ;;
        R) 
           echo -e " [1] Proportional Solver (a/b = c/d) [2] Ratio Simplifier"
           read -p "Select: " rt
           [[ "$rt" == "1" ]] && solve_ratios || simplify_ratios ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
    read -p "Press any key to continue..." -n1 -s
    show_equation_solver
}

# --- History Menu ---
show_history() {
    echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│            CALCULATION HISTORY           │${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        echo -e "${GRAY}  (No history yet)                         ${NC}"
    else
        tail -n 10 "$HISTORY_FILE" | while read -r line; do
            echo -e "  ${CYAN}•${NC} ${WHITE}$line${NC}"
        done
    fi
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}  [b] Back      [x] Clear History          ${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
    read -p "Select option: " opt
    case $opt in
        x) rm -f "$HISTORY_FILE"; show_history ;;
        *) show_header ;;
    esac
}

# --- Enhanced Manual System ---
show_manual() {
    echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${WHITE}           VALTY OS: SYSTEM MANUAL       ${YELLOW}│${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}  SELECT CATEGORY:                         ${NC}"
    echo -e "  [1] Basic Math & Constants              "
    echo -e "  [2] Unit Conversion System              "
    echo -e "  [3] Thanaweya Amma Physics (CH1-8)      "
    echo -e "  [4] Advanced Math Solvers               "
    echo -e "  [5] Settings, Shortcuts & History       "
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}  [b] ⬅️  Back to Main OS                   ${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
    read -p "Select Category: " mcat
    [[ "$mcat" == "b" ]] && { show_header; return; }

    clear
    case $mcat in
        1)
            echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║${WHITE}      BASIC MATH & SCIENTIFIC CONSTANTS   ${CYAN}║${NC}"
            echo -e "${CYAN}╠══════════════════════════════════════════╣${NC}"
            echo -e " ${WHITE}OPERATORS:${NC} +, -, *, /, ^ (power), v (root)"
            echo -e " ${WHITE}FUNCTIONS:${NC} sin, cos, tan, ln, log, exp"
            echo -e " ${GRAY}Example: 'sin30 + sqrt(16)' -> 4.5${NC}"
            echo -e "${CYAN}╟──────────────────────────────────────────╢${NC}"
            echo -e " ${WHITE}CONSTANTS (Curriculum Accurate):${NC}"
            echo -e "  ${MAGENTA}pi${NC} : 3.1415...     ${MAGENTA}e${NC} : 2.7182..."
            echo -e "  ${MAGENTA}c${NC}  : 3e8 (m/s)     ${MAGENTA}h${NC} : 6.626e-34 (J.s)"
            echo -e "  ${MAGENTA}qe${NC} : 1.6e-19 (C)    ${MAGENTA}Na${NC}: 6.022e23"
            echo -e "  ${MAGENTA}G${NC}  : 6.674e-11     ${MAGENTA}kb${NC}: 1.38e-23"
            echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
            ;;
        2)
            echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
            echo -e "${BLUE}║${WHITE}          UNIT CONVERSION SYSTEM          ${BLUE}║${NC}"
            echo -e "${BLUE}╠══════════════════════════════════════════╣${NC}"
            echo -e " ${WHITE}FLOW:${NC} Category > System > From > To"
            echo -e " ${WHITE}CATEGORIES:${NC} Electricity, Mechanics, Science,"
            echo -e "             Standard, Others."
            echo -e "${BLUE}╟──────────────────────────────────────────╢${NC}"
            echo -e " ${WHITE}SYSTEMS:${NC}"
            echo -e "  ${CYAN}Metric (SI)${NC}  : m, kg, Pa, J, W, etc."
            echo -e "  ${YELLOW}Imperial${NC}     : ft, lb, psi, BTU, hp, etc."
            echo -e " ${GRAY}Tip: Use [s] in main OS to toggle system${NC}"
            echo -e " ${GRAY}highlighting for faster selection.${NC}"
            echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
            ;;
        3)
            echo -e "${MAGENTA}╔══════════════════════════════════════════╗${NC}"
            echo -e "${MAGENTA}║${WHITE}     THANAWEYA AMMA PHYSICS (CH1-8)      ${MAGENTA}║${NC}"
            echo -e "${MAGENTA}╠══════════════════════════════════════════╣${NC}"
            echo -e " ${WHITE}CH1-2:${NC} DC Circuits (Req=ΣR), Ohm's Law,"
            echo -e "        Magnetism (B=μI/2πd), Force (F=BIL)."
            echo -e " ${WHITE}CH3-4:${NC} Induction (Faraday), Dynamo (NBAω),"
            echo -e "        AC Circuits (Z=√R²+(XL-XC)²)."
            echo -e " ${WHITE}CH5-8:${NC} Modern Physics (E=hf), Hydrogen"
            echo -e "        levels, Transistors, Logic Gates."
            echo -e "${MAGENTA}╟──────────────────────────────────────────╢${NC}"
            echo -e " ${WHITE}SHORTCUTS:${NC} Type ${WHITE}e1${NC} to ${WHITE}e5${NC} from main prompt"
            echo -e " to jump directly to any chapter solver."
            echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}"
            ;;
        4)
            echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║${WHITE}         ADVANCED MATH SOLVERS            ${GREEN}║${NC}"
            echo -e "${GREEN}╠══════════════════════════════════════════╣${NC}"
            echo -e " ${WHITE}[P] Polynomial:${NC}"
            echo -e "  - Linear: ax + b = c"
            echo -e "  - Quadratic: ax² + bx + c = 0"
            echo -e " ${WHITE}[S] Simultaneous:${NC}"
            echo -e "  - 2 Unknowns (x, y) & 3 Unknowns (x, y, z)"
            echo -e "  - Uses Cramer's Determinant method."
            echo -e " ${WHITE}[R] Ratios:${NC}"
            echo -e "  - Proportions: Solve a/b = c/d (use '?')"
            echo -e "  - Simplifier: Reduce x : y : z to lowest form."
            echo -e "    ${GRAY}Example: '0.5:1:1.5' -> '1:2:3'${NC}"
            echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
            ;;
        5)
            echo -e "${GRAY}╔══════════════════════════════════════════╗${NC}"
            echo -e "${GRAY}║${WHITE}        SETTINGS, SHORTCUTS & HISTORY     ${GRAY}║${NC}"
            echo -e "${GRAY}╠══════════════════════════════════════════╣${NC}"
            echo -e " ${WHITE}[s] Settings:${NC} Toggle format, precision,"
            echo -e "               angle mode, and systems."
            echo -e " ${WHITE}[y] History:${NC}  Last 10 results are logged."
            echo -e " ${WHITE}[l] Refresh:${NC}  Clear screen/Restores header."
            echo -e " ${WHITE}[q] Shutdown:${NC} Safely exit the OS."
            echo -e "${GRAY}╟──────────────────────────────────────────╢${NC}"
            echo -e " ${WHITE}SECRET CODES:${NC}"
            echo -e "  - ${RED}itachi${NC}   : Activate Sharingan mode."
            echo -e "  - ${WHITE}assassin${NC} : Creed activation code."
            echo -e "  - ${RED}templar${NC}  : Abstergo system override."
            echo -e "${GRAY}╚══════════════════════════════════════════╝${NC}"
            ;;
        *) echo -e "${RED}Invalid category.${NC}"; sleep 1; show_manual; return ;;
    esac
    echo -e ""
    read -p "Press any key to return to Manual Menu... " -n1 -s
    echo ""
    show_manual
}

# --- Credits Menu ---
show_credits() {
    echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│            VALTY CALC CREDITS            │${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}  Idea Founder:                            ${NC}"
    echo -e "${CYAN}  Itachi sensei 17                         ${NC}"
    echo -e ""
    echo -e "${WHITE}  Code Architect:                          ${NC}"
    echo -e "${MAGENTA}  Antigravity (AI Assistant)               ${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}  [b] Back                                 ${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
    read -p "Press any key to go back... " -n1 -s
    show_header
}

# --- Easter Egg ---
show_easter_egg() {
    local type=$1
    clear
    case $type in
        "itachi")
            echo -e "${RED}"
            echo -e "          .▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄.          "
            echo -e "       ▄▀▀               ▀▀▄       "
            echo -e "     ▄▀                     ▀▄     "
            echo -e "    █     ▄▄▄         ▄▄▄     █    "
            echo -e "   █    ▄▀   ▀▄     ▄▀   ▀▄    █   "
            echo -e "  █    █   ▄   █   █   ▄   █    █  "
            echo -e "  █    █  █ █  █   █  █ █  █    █  "
            echo -e "  █    █   ▀   █   █   ▀   █    █  "
            echo -e "   █    ▀▄   ▄▀     ▀▄   ▄▀    █   "
            echo -e "    █     ▀▀▀         ▀▀▀     █    "
            echo -e "     ▀▄                     ▄▀     "
            echo -e "       ▀▄▄               ▄▄▀       "
            echo -e "          ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀          ${NC}"
            echo -e "${WHITE}      You are under my Genjutsu...${NC}"
            echo -e "${RED}       - Itachi Sensei 17 -        ${NC}"
            ;;
        "assassin")
            echo -e "${WHITE}"
            echo -e "               /\\                "
            echo -e "              /  \\               "
            echo -e "             /    \\              "
            echo -e "            /      \\             "
            echo -e "           /   /\\   \\            "
            echo -e "          /   /  \\   \\           "
            echo -e "         /   /    \\   \\          "
            echo -e "        /   /      \\   \\         "
            echo -e "       /___/        \\___\\        "
            echo -e "      (__________________)        ${NC}"
            echo -e "${CYAN}   Nothing is true, everything is permitted.${NC}"
            ;;
        "templar")
            echo -e "${RED}"
            echo -e "               _|_               "
            echo -e "              |   |              "
            echo -e "           ___|   |___           "
            echo -e "          |           |          "
            echo -e "          |___     ___|          "
            echo -e "              |   |              "
            echo -e "              |___|              ${NC}"
            echo -e "${WHITE}     May the Father of Understanding  ${NC}"
            echo -e "${WHITE}            guide us...               ${NC}"
            ;;
    esac
    echo -e ""
    sleep 2
    show_header
}

# --- Main Logic ---
startup
show_header

while true; do
    echo -ne "  ${MAGENTA}λ${NC} ${CYAN}VALTY > ${NC}"
    read -r input

    if [[ "$input" == "q" ]]; then
        shutdown; break
    elif [[ "$input" == "m" ]]; then
        show_manual; continue
    elif [[ "$input" == "u" ]]; then
        show_unit_converter; continue
    elif [[ "$input" == "y" ]]; then
        show_history; continue
    elif [[ "$input" == "l" ]]; then
        show_header; continue
    elif [[ "$input" == "k" ]]; then
        show_credits; continue
    elif [[ "$input" == "e" ]]; then
        show_equation_solver; continue
    # Direct Chapter Jumps (Fluent Shortcuts)
    elif [[ "$input" =~ ^e[1-5]$ ]]; then
        case ${input:1} in
            1) solve_ch1 ;; 2) solve_ch2 ;; 3) solve_ch3 ;; 4) solve_ch4 ;; 5) solve_modern ;;
        esac
        show_header; continue
    elif [[ "$input" == "s" ]]; then
        # --- Settings Menu ---
        echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│            VALTY OS: SETTINGS            │${NC}"
        echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
        echo -e "${WHITE}  [1] Normal (0.0001)                      ${NC}"
        echo -e "${WHITE}  [2] Scientific (1e-4)                    ${NC}"
        echo -e "${WHITE}  [3] Scientific (* 10^x)                  ${NC}"
        echo -e "${WHITE}  [4] Change Precision (0-15)              ${NC}"
        echo -e "${WHITE}  [5] Toggle Angle Mode (DEG/RAD)          ${NC}"
        echo -e "${WHITE}  [6] Toggle Unit System (MET/IMP)         ${NC}"
        echo -e "${WHITE}  [b] Back                                 ${NC}"
        echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
        read -p "Select option: " opt
        case $opt in
            1) FORMAT="normal" ;;
            2) FORMAT="sci_e" ;;
            3) FORMAT="sci_pow" ;;
            4) read -p "Enter precision: " prec; [[ "$prec" =~ ^[0-9]+$ ]] && PRECISION=$prec ;;
            5) [[ "$ANGLE_MODE" == "deg" ]] && ANGLE_MODE="rad" || ANGLE_MODE="deg" ;;
            6) [[ "$UNIT_SYSTEM" == "metric" ]] && UNIT_SYSTEM="imperial" || UNIT_SYSTEM="metric" ;;
        esac
        show_header; continue
    elif [[ "$input" == "itachi" || "$input" == "sharingan" ]]; then
        show_easter_egg "itachi"; continue
    elif [[ "$input" == "assassin" ]]; then
        show_easter_egg "assassin"; continue
    elif [[ "$input" == "templar" ]]; then
        show_easter_egg "templar"; continue
    elif [[ -z "$input" ]]; then
        continue
    else
        calculate "$input"
    fi
    echo -e "${CYAN}------------------------------------------${NC}"
done
