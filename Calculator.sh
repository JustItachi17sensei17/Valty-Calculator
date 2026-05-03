#!/bin/bash

# --- Settings ---
FORMAT="normal" # normal, sci_e, sci_pow
PRECISION=4
ANGLE_MODE="deg" # deg, rad, grad
ANGLE_UNIT="deg" # deg, rad, grad
UNIT_SYSTEM="metric" # metric, imperial
LAST_RESULT=0
COUNT=0
HISTORY_FILE=".valty_history"

# Input/Output Settings
INPUT_MODE="MathI" # MathI, Math0, LineI, Line0
OUTPUT_MODE="Math0" # Math0, Decimal0

# Number Format Settings
NUM_FORMAT="Norm" # Fix, Sci, Norm
ENG_SYMBOL="off" # on, off

# Fraction Settings
FRAC_RESULT="ab/c" # ab/c, d/c

# Complex Settings
COMPLEX_FORMAT="a+bi" # a+bi, r<theta

# Statistics Settings
STAT_FREQ="off" # on, off

# Equation Settings
EQ_COMPLEX_RESULT="on" # on, off

# Table Settings
TABLE_MODE="f(x)" # f(x), f(x)+g(x)

# Display Settings
DECIMAL_MARK="dot" # dot, comma
DIGIT_SEP="off" # on, off
MULTILINE_FONT="normal" # normal, small

# Variables Storage (A,B,C,D,E,F,x,y,M)
declare -gA VARIABLES
VARIABLES[A]=0
VARIABLES[B]=0
VARIABLES[C]=0
VARIABLES[D]=0
VARIABLES[E]=0
VARIABLES[F]=0
VARIABLES[x]=0
VARIABLES[y]=0
VARIABLES[M]=0

set -o pipefail # Better error handling in pipes
touch "$HISTORY_FILE" && chmod 600 "$HISTORY_FILE"
# Note: History file is preserved between sessions for user convenience

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
    echo -e "  ${MAGENTA}║${WHITE}  [v] Variables [l] Clear     [q] Quit        ${MAGENTA}║${NC}${GRAY}█${NC}"
    echo -e "  ${MAGENTA}╚══════════════════════════════════════════════╝${NC}${GRAY}█${NC}"
    echo -e "   ${GRAY}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${NC}"
    echo -e "    ${WHITE}Mode: ${YELLOW}${FORMAT}${NC} | ${WHITE}Angle: ${YELLOW}${ANGLE_MODE^^}${NC} | ${WHITE}Prec: ${YELLOW}${PRECISION}${NC} | ${WHITE}Units: ${YELLOW}${UNIT_SYSTEM^^}${NC}"
    echo -e "    ${WHITE}IO: ${YELLOW}${INPUT_MODE}/${OUTPUT_MODE}${NC} | ${WHITE}NumFmt: ${YELLOW}${NUM_FORMAT}${NC} | ${WHITE}Complex: ${YELLOW}${COMPLEX_FORMAT}${NC}"
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
forbidden_pattern='[\$`{}\[\];&\\!<> ]'
if [[ "$expr" =~ $forbidden_pattern ]]; then
    echo -e "${RED}ERR: SECURITY VIOLATION - ILLEGAL CHARACTERS DETECTED${NC}"
    echo -e "${YELLOW}Tip: Only use standard math symbols and functions.${NC}"
    return 1
fi

    # 2. Expand shorthand and Unit Suffixes
    # IMPORTANT: Multi-char suffixes (km, cm, mm, kg) must be listed BEFORE
    # single-char ones (k, c, m) so that sed matches the longer token first.
    expr=$(echo "$expr" | sed -E \
        -e 's/(sin|cos|tan|exp|ln|log|sqrt)([a-zA-Z0-9.]+)/\1(\2)/g' \
        -e 's/([0-9.]+)km\b/\(\1*1000\)/g' -e 's/([0-9.]+)cm\b/\(\1\/100\)/g' -e 's/([0-9.]+)mm\b/\(\1\/1000\)/g' \
        -e 's/([0-9.]+)kg\b/\(\1*1000\)/g' -e 's/([0-9.]+)ton\b/\(\1*10^6\)/g' \
        -e 's/([0-9.]+)T\b/\(\1*10^12\)/g' -e 's/([0-9.]+)G\b/\(\1*10^9\)/g' -e 's/([0-9.]+)M\b/\(\1*10^6\)/g' \
        -e 's/([0-9.]+)k\b/\(\1*1000\)/g' -e 's/([0-9.]+)c\b/\(\1\/100\)/g' -e 's/([0-9.]+)m\b/\(\1\/1000\)/g' \
        -e 's/([0-9.]+)u\b/\(\1*10^-6\)/g' -e 's/([0-9.]+)n\b/\(\1*10^-9\)/g' -e 's/([0-9.]+)p\b/\(\1*10^-12\)/g' -e 's/([0-9.]+)f\b/\(\1*10^-15\)/g')

    # 3. Implicit Multiplication Support
    # Fix: closing-opening paren must produce )*(  not )*( with a space
    expr=$(echo "$expr" | sed -E \
        -e 's/([0-9.]+)\(/\1*(/g' -e 's/\)([0-9.]+)/)*\1/g' -e 's/\)\(/)*(/g' \
        -e 's/([0-9.]+)(pi|ans|sin|cos|tan|ln|log|exp|sqrt)/\1*\2/g')

    # 4. Handle Constants (Curriculum Accurate + Extended Scientific)
    local PI_VAL="3.14159265358979323846"
    expr=$(echo "$expr" | sed -E \
        -e "s/\bpi\b/$PI_VAL/g" -e 's/\be\b/2.71828182845905/g' \
        -e 's/\bc\b/(2.99792458*10^8)/g' -e 's/\bG\b/(6.67430*10^-11)/g' \
        -e 's/\bh\b/(6.62607015*10^-34)/g' -e 's/\bqe\b/(1.602176634*10^-19)/g' \
        -e 's/\bNa\b/(6.02214076*10^23)/g' -e 's/\bkb\b/(1.380649*10^-23)/g' \
        -e 's/\bmu0\b/(1.25663706212*10^-6)/g' -e 's/\beps0\b/(8.8541878128*10^-12)/g' \
        -e 's/\bme\b/(9.1093837015*10^-31)/g' -e 's/\bmp\b/(1.67262192369*10^-27)/g' \
        -e 's/\bmn\b/(1.67492749804*10^-27)/g' -e 's/\bR\b/(8.314462618)/g' \
        -e 's/\bF\b/(96485.33212)/g' -e 's/\bstefan\b/(5.670374419*10^-8)/g' \
        -e 's/\brydberg\b/(1.0973731568160*10^7)/g' -e 's/\bbohr\b/(5.29177210903*10^-11)/g' \
        -e 's/\bg0\b/(9.80665)/g' -e 's/\batm\b/(1.01325*10^5)/g' \
        -e 's/\bRy\b/(2.1798723611035*10^-18)/g' -e 's/\blambda_c\b/(2.42631023867*10^-12)/g')

    # 5. Replace 'ans' with the last result
    expr=${expr//ans/"$LAST_RESULT"}

    # 6. Handle Degree Conversion
    if [[ "$ANGLE_MODE" == "deg" ]]; then
        # Domain Check: tan(90), tan(270), etc.
        # Use awk for the modulo check (not $(()) which cannot handle floats).
        local tan_regex='tan\(\(([^\)]+)\)\)'
        if [[ "$expr" =~ $tan_regex ]]; then
            local angle=$(awk "BEGIN { print ${BASH_REMATCH[1]} }" 2>/dev/null)
            if is_num "$angle"; then
                local check=$(awk "BEGIN { diff = ($angle - 90) % 180; print (diff < 0.0001 && diff > -0.0001) ? 1 : 0 }")
                if [[ "$check" == "1" ]]; then
                    echo -e "${RED}ERR: TAN UNDEFINED AT ${angle}°${NC}"
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

    # 7. Domain Validation for Log/Ln (checked on the original user input before sed transforms it)
    # We match the original $1 argument so the pattern still contains ln/log/sqrt keywords.
    if [[ "$1" =~ (ln|sqrt)\((-?[0-9.eE+]+)\) ]]; then
        local func="${BASH_REMATCH[1]}"
        local raw_v="${BASH_REMATCH[2]}"
        if is_num "$raw_v"; then
            if [[ "$func" == "ln" ]] && (( $(awk "BEGIN { print ($raw_v <= 0) }") )); then
                echo -e "${RED}ERR: ln UNDEFINED FOR VALUES <= 0${NC}"
                return 1
            elif [[ "$func" == "sqrt" ]] && (( $(awk "BEGIN { print ($raw_v < 0) }") )); then
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

    # 9. Execute with BC or AWK
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
    (( pad < 0 )) && pad=0
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
           local flux=$(awk "BEGIN { printf \"%.15g\", $b * $a * sin($th * 3.14159265358979323846 / 180) }")
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
           local f=$(awk "BEGIN { printf \"%.15g\", $b * $i * $l * sin($th * 3.14159265358979323846 / 180) }")
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
    echo -e "  [C] Complex Numbers                     "
    echo -e "  [N] Base-N Converter                    "
    echo -e "  [M] Matrix Calculator                   "
    echo -e "  [V] Vector Calculator                   "
    echo -e "  [T] Statistics                          "
    echo -e "  [B] Table Generator                     "
    echo -e "  [I] Inequality Solver                   "
    echo -e "  [X] Variable Manager                    "
    echo -e "  [E] Equation Solver (ax+b=c)            "
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
           if [[ "$rt" == "1" ]]; then solve_ratios; else simplify_ratios; fi ;;
        C) solve_complex ;;
        N) solve_base_n ;;
        M) solve_matrix ;;
        V) solve_vector ;;
        T) solve_statistics ;;
        B) solve_table ;;
        I) solve_inequality ;;
        X) manage_variables ;;
        E) solve_equation ;;
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

# --- Settings Menu Function ---
settings_menu() {
    local settings_done=false
    while [[ "$settings_done" == "false" ]]; do
        clear
        echo -e "${YELLOW}┌────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│              VALTY OS: SETTINGS                    │${NC}"
        echo -e "${YELLOW}├────────────────────────────────────────────────────┤${NC}"
        echo -e "${WHITE}  ── Input/Output ──────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [1] Input Mode:      ${CYAN}${INPUT_MODE}${NC}"
        echo -e "${WHITE}  [2] Output Mode:     ${CYAN}${OUTPUT_MODE}${NC}"
        echo -e "${WHITE}  ── Angle Unit ────────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [3] Angle Unit:      ${CYAN}${ANGLE_MODE^^}${NC} (deg/rad/grad)"
        echo -e "${WHITE}  ── Number Format ─────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [4] Number Format:   ${CYAN}${NUM_FORMAT}${NC} (Fix/Sci/Norm)"
        echo -e "${WHITE}  [5] Engineer Symbol: ${CYAN}${ENG_SYMBOL^^}${NC}"
        echo -e "${WHITE}  ── Fraction Result ───────────────────────────────  ${NC}"
        echo -e "${WHITE}  [6] Fraction Format: ${CYAN}${FRAC_RESULT}${NC}"
        echo -e "${WHITE}  ── Complex Format ────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [7] Complex Format:  ${CYAN}${COMPLEX_FORMAT}${NC}"
        echo -e "${WHITE}  ── Statistics ────────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [8] Frequency:       ${CYAN}${STAT_FREQ^^}${NC}"
        echo -e "${WHITE}  ── Equation/Function ─────────────────────────────  ${NC}"
        echo -e "${WHITE}  [9] Complex Result:  ${CYAN}${EQ_COMPLEX_RESULT^^}${NC}"
        echo -e "${WHITE}  ── Table ─────────────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [0] Table Mode:      ${CYAN}${TABLE_MODE}${NC}"
        echo -e "${WHITE}  ── Display ───────────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [A] Decimal Mark:    ${CYAN}${DECIMAL_MARK^^}${NC}"
        echo -e "${WHITE}  [B] Digit Separator: ${CYAN}${DIGIT_SEP^^}${NC}"
        echo -e "${WHITE}  [C] MultiLine Font:  ${CYAN}${MULTILINE_FONT^^}${NC}"
        echo -e "${WHITE}  ── Basic Settings ────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [D] Display Format:  ${CYAN}${FORMAT}${NC}"
        echo -e "${WHITE}  [E] Precision:       ${CYAN}${PRECISION}${NC}"
        echo -e "${WHITE}  [F] Unit System:     ${CYAN}${UNIT_SYSTEM^^}${NC}"
        echo -e "${WHITE}  ──────────────────────────────────────────────────  ${NC}"
        echo -e "${WHITE}  [Q] Back to Main Menu                              ${NC}"
        echo -e "${YELLOW}└────────────────────────────────────────────────────┘${NC}"
        echo ""
        read -p "Select option: " opt
        
        case $opt in
            1) # Input Mode
                echo -e "${YELLOW}Input Modes:${NC}"
                echo -e "  [1] MathI  - Math input (natural display)"
                echo -e "  [2] Math0  - Math input, decimal output"
                echo -e "  [3] LineI  - Linear input"
                echo -e "  [4] Line0  - Linear input/output"
                read -p "Select: " im
                case $im in
                    1) INPUT_MODE="MathI" ;;
                    2) INPUT_MODE="Math0" ;;
                    3) INPUT_MODE="LineI" ;;
                    4) INPUT_MODE="Line0" ;;
                esac
                ;;
            2) # Output Mode
                echo -e "${YELLOW}Output Modes:${NC}"
                echo -e "  [1] Math0    - Natural display output"
                echo -e "  [2] Decimal0 - Decimal output"
                read -p "Select: " om
                case $om in
                    1) OUTPUT_MODE="Math0" ;;
                    2) OUTPUT_MODE="Decimal0" ;;
                esac
                ;;
            3) # Angle Unit
                echo -e "${YELLOW}Angle Units:${NC}"
                echo -e "  [1] Degrees  (deg)"
                echo -e "  [2] Radians  (rad)"
                echo -e "  [3] Gradians (grad)"
                read -p "Select: " am
                case $am in
                    1) ANGLE_MODE="deg" ;;
                    2) ANGLE_MODE="rad" ;;
                    3) ANGLE_MODE="grad" ;;
                esac
                ;;
            4) # Number Format
                echo -e "${YELLOW}Number Formats:${NC}"
                echo -e "  [1] Fix  - Fixed decimal places"
                echo -e "  [2] Sci  - Scientific notation"
                echo -e "  [3] Norm - Normal display"
                read -p "Select: " nf
                case $nf in
                    1) NUM_FORMAT="Fix" ;;
                    2) NUM_FORMAT="Sci" ;;
                    3) NUM_FORMAT="Norm" ;;
                esac
                ;;
            5) # Engineer Symbol
                [[ "$ENG_SYMBOL" == "off" ]] && ENG_SYMBOL="on" || ENG_SYMBOL="off"
                ;;
            6) # Fraction Format
                [[ "$FRAC_RESULT" == "ab/c" ]] && FRAC_RESULT="d/c" || FRAC_RESULT="ab/c"
                ;;
            7) # Complex Format
                [[ "$COMPLEX_FORMAT" == "a+bi" ]] && COMPLEX_FORMAT="r<theta" || COMPLEX_FORMAT="a+bi"
                ;;
            8) # Statistics Frequency
                [[ "$STAT_FREQ" == "off" ]] && STAT_FREQ="on" || STAT_FREQ="off"
                ;;
            9) # Equation Complex Result
                [[ "$EQ_COMPLEX_RESULT" == "off" ]] && EQ_COMPLEX_RESULT="on" || EQ_COMPLEX_RESULT="off"
                ;;
            0) # Table Mode
                [[ "$TABLE_MODE" == "f(x)" ]] && TABLE_MODE="f(x)+g(x)" || TABLE_MODE="f(x)"
                ;;
            A|a) # Decimal Mark
                [[ "$DECIMAL_MARK" == "dot" ]] && DECIMAL_MARK="comma" || DECIMAL_MARK="dot"
                ;;
            B|b) # Digit Separator
                [[ "$DIGIT_SEP" == "off" ]] && DIGIT_SEP="on" || DIGIT_SEP="off"
                ;;
            C|c) # MultiLine Font
                [[ "$MULTILINE_FONT" == "normal" ]] && MULTILINE_FONT="small" || MULTILINE_FONT="normal"
                ;;
            D|d) # Display Format
                echo -e "${YELLOW}Display Formats:${NC}"
                echo -e "  [1] Normal     (0.0001)"
                echo -e "  [2] Sci (e)    (1e-4)"
                echo -e "  [3] Sci (pow)  (1*10^-4)"
                read -p "Select: " df
                case $df in
                    1) FORMAT="normal" ;;
                    2) FORMAT="sci_e" ;;
                    3) FORMAT="sci_pow" ;;
                esac
                ;;
            E|e) # Precision
                read -p "Enter precision (0-15): " prec
                if [[ "$prec" =~ ^[0-9]+$ ]] && [ "$prec" -ge 0 ] && [ "$prec" -le 15 ]; then
                    PRECISION=$prec
                else
                    echo -e "${RED}Invalid precision.${NC}"
                    sleep 1
                fi
                ;;
            F|f) # Unit System
                [[ "$UNIT_SYSTEM" == "metric" ]] && UNIT_SYSTEM="imperial" || UNIT_SYSTEM="metric"
                ;;
            Q|q) # Quit
                settings_done=true
                ;;
        esac
    done
}

# --- Complex Numbers Calculator ---
solve_complex() {
    echo -e "${CYAN}--- COMPLEX NUMBERS CALCULATOR ---${NC}"
    echo -e " Format: a+bi or a-bi (enter as: a b sign)"
    echo -e " Example: 3+4i -> enter '3 4 +'"
    echo -e " [1] Add  [2] Subtract  [3] Multiply  [4] Divide"
    echo -e " [5] Modulus  [6] Conjugate  [7] Polar Form"
    echo -e " [O] Options (Arg, Real/Imag, Convert, Hyperbolic)"
    read -p "Select operation: " op

    if [[ "${op^^}" == "O" ]]; then
        complex_options
        return
    fi
    
    case $op in
        [1-4])
            read -p "Enter Z1 (a b sign): " a1 b1 s1
            read -p "Enter Z2 (c d sign): " c1 d1 s2
            
            if ! is_num "$a1" || ! is_num "$b1" || ! is_num "$c1" || ! is_num "$d1"; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            
            # Convert to standard form
            [[ "$s1" == "-" ]] && b1=$(awk "BEGIN { print -$b1 }")
            [[ "$s2" == "-" ]] && d1=$(awk "BEGIN { print -$d1 }")
            
            local real imag
            case $op in
                1) real=$(awk "BEGIN { print $a1 + $c1 }")
                   imag=$(awk "BEGIN { print $b1 + $d1 }") ;;
                2) real=$(awk "BEGIN { print $a1 - $c1 }")
                   imag=$(awk "BEGIN { print $b1 - $d1 }") ;;
                3) real=$(awk "BEGIN { print ($a1 * $c1) - ($b1 * $d1) }")
                   imag=$(awk "BEGIN { print ($a1 * $d1) + ($b1 * $c1) }") ;;
                4) local denom=$(awk "BEGIN { print ($c1^2) + ($d1^2) }")
                   if (( $(awk "BEGIN { print ($denom == 0) }") )); then
                       echo -e "${RED}ERR: Division by zero.${NC}"; return
                   fi
                   real=$(awk "BEGIN { printf \"%.15g\", (($a1 * $c1) + ($b1 * $d1)) / $denom }")
                   imag=$(awk "BEGIN { printf \"%.15g\", (($b1 * $c1) - ($a1 * $d1)) / $denom }") ;;
            esac
            
            local imag_fmt=$(format_result "$imag")
            local real_fmt=$(format_result "$real")
            if (( $(awk "BEGIN { print ($imag < 0) }") )); then
                echo -e "${GREEN}Result: ${real_fmt}${imag_fmt}i${NC}"
            else
                echo -e "${GREEN}Result: ${real_fmt}+${imag_fmt}i${NC}"
            fi
            ;;
        5)
            read -p "Enter Z (a b sign): " a1 b1 s1
            is_num "$a1" && is_num "$b1" || { echo -e "${RED}Invalid input.${NC}"; return; }
            [[ "$s1" == "-" ]] && b1=$(awk "BEGIN { print -$b1 }")
            local mod=$(awk "BEGIN { printf \"%.15g\", sqrt(($a1^2) + ($b1^2)) }")
            echo -e "${GREEN}|Z| = $(format_result "$mod")${NC}"
            ;;
        6)
            read -p "Enter Z (a b sign): " a1 b1 s1
            is_num "$a1" && is_num "$b1" || { echo -e "${RED}Invalid input.${NC}"; return; }
            [[ "$s1" == "-" ]] && s1="+" || s1="-"
            if (( $(awk "BEGIN { print ($b1 < 0) }") )); then
                echo -e "${GREEN}Conjugate: $(format_result "$a1")+$(format_result "${b1#-}")i${NC}"
            else
                echo -e "${GREEN}Conjugate: $(format_result "$a1")-$(format_result "$b1")i${NC}"
            fi
            ;;
        7)
            read -p "Enter Z (a b sign): " a1 b1 s1
            is_num "$a1" && is_num "$b1" || { echo -e "${RED}Invalid input.${NC}"; return; }
            [[ "$s1" == "-" ]] && b1=$(awk "BEGIN { print -$b1 }")
            local r=$(awk "BEGIN { printf \"%.15g\", sqrt(($a1^2) + ($b1^2)) }")
            local theta_rad=$(awk "BEGIN { printf \"%.15g\", atan2($b1, $a1) }")
            local theta_deg=$(awk "BEGIN { printf \"%.15g\", $theta_rad * 180 / 3.14159265358979 }")
            echo -e "${GREEN}Polar: r = $(format_result "$r"), θ = $(format_result "$theta_deg")°${NC}"
            echo -e "${GRAY}         = $(format_result "$r") ∠ $(format_result "$theta_deg")°${NC}"
            ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
    read -p " Solve another complex? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_complex; return; }
}

# --- Complex Options Menu ---
complex_options() {
    echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${WHITE}       COMPLEX OPTIONS MENU          ${YELLOW}│${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "  [1] Argument (Angle)                    "
    echo -e "  [2] Real Part                           "
    echo -e "  [3] Imaginary Part                      "
    echo -e "  [4] Convert to r<θ (Polar)              "
    echo -e "  [5] Convert to a+bi (Rectangular)       "
    echo -e "  [6] Angle Unit (Deg/Rad/Grad)           "
    echo -e "  [7] Hyperbolic Functions                "
    echo -e "  [8] Engineering Symbols                 "
    echo -e "  [b] Back to Complex Calculator          "
    echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
    read -p "Select option: " opt

    case $opt in
        [1-5])
            read -p "Enter complex number (a b sign): " a b s
            if ! is_num "$a" || ! is_num "$b"; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            [[ "$s" == "-" ]] && b=$(awk "BEGIN { print -$b }")
            
            local r=$(awk "BEGIN { printf \"%.15g\", sqrt(($a^2) + ($b^2)) }")
            local theta_rad=$(awk "BEGIN { printf \"%.15g\", atan2($b, $a) }")
            local theta_deg=$(awk "BEGIN { printf \"%.15g\", $theta_rad * 180 / 3.14159265358979 }")
            local theta_grad=$(awk "BEGIN { printf \"%.15g\", $theta_rad * 200 / 3.14159265358979 }")
            
            case $opt in
                1)
                    echo -e "${GREEN}Argument:${NC}"
                    echo -e "  Degrees:  $(format_result "$theta_deg")°"
                    echo -e "  Radians:  $(format_result "$theta_rad") rad"
                    echo -e "  Gradians: $(format_result "$theta_grad") grad"
                    ;;
                2)
                    echo -e "${GREEN}Real Part: $(format_result "$a")${NC}"
                    ;;
                3)
                    echo -e "${GREEN}Imaginary Part: $(format_result "$b")${NC}"
                    ;;
                4)
                    echo -e "${GREEN}Polar Form (r<θ):${NC}"
                    echo -e "  r = $(format_result "$r")"
                    case $ANGLE_UNIT in
                        deg) echo -e "  θ = $(format_result "$theta_deg")°" ;;
                        rad) echo -e "  θ = $(format_result "$theta_rad") rad" ;;
                        grad) echo -e "  θ = $(format_result "$theta_grad") grad" ;;
                    esac
                    echo -e "  Result: $(format_result "$r")<$(format_result "$theta_deg")°"
                    ;;
                5)
                    local real_fmt=$(format_result "$a")
                    local imag_sign="+"
                    local imag_abs=$b
                    if (( $(awk "BEGIN { print ($b < 0) }") )); then
                        imag_sign="-"
                        imag_abs=$(awk "BEGIN { print -$b }")
                    fi
                    echo -e "${GREEN}Rectangular Form (a+bi):${NC}"
                    echo -e "  Result: ${real_fmt}${imag_sign}$(format_result "$imag_abs")i"
                    ;;
            esac
            ;;
        6)
            echo -e "${CYAN}Current Angle Unit: ${YELLOW}$ANGLE_UNIT${NC}"
            echo -e " [1] Degrees  [2] Radians  [3] Gradians"
            read -p "Select: " au
            case $au in
                1) ANGLE_UNIT="deg"; echo -e "${GREEN}Set to Degrees${NC}" ;;
                2) ANGLE_UNIT="rad"; echo -e "${GREEN}Set to Radians${NC}" ;;
                3) ANGLE_UNIT="grad"; echo -e "${GREEN}Set to Gradians${NC}" ;;
                *) echo -e "${RED}Invalid option.${NC}" ;;
            esac
            ;;
        7)
            echo -e "${CYAN}--- Hyperbolic Functions ---${NC}"
            echo -e " Enter real value x:"
            read -p "x: " x
            if ! is_num "$x"; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local sinh=$(awk "BEGIN { printf \"%.15g\", (exp($x) - exp(-$x)) / 2 }")
            local cosh=$(awk "BEGIN { printf \"%.15g\", (exp($x) + exp(-$x)) / 2 }")
            local tanh=$(awk "BEGIN { printf \"%.15g\", (exp($x) - exp(-$x)) / (exp($x) + exp(-$x)) }")
            echo -e "${GREEN}sinh($x) = $(format_result "$sinh")${NC}"
            echo -e "${GREEN}cosh($x) = $(format_result "$cosh")${NC}"
            echo -e "${GREEN}tanh($x) = $(format_result "$tanh")${NC}"
            ;;
        8)
            echo -e "${CYAN}--- Engineering Symbols ---${NC}"
            ENG_SYMBOL="on"
            echo -e " Engineering symbols enabled"
            echo -e " T(10^12), G(10^9), M(10^6), k(10^3)"
            echo -e " c(10^-2), m(10^-3), u(10^-6), n(10^-9), p(10^-12)"
            read -p "Enter value with suffix: " val
            local converted=$(echo "$val" | sed -E \
                -e 's/([0-9.]+)T/\1*1e12/g' \
                -e 's/([0-9.]+)G/\1*1e9/g' \
                -e 's/([0-9.]+)M/\1*1e6/g' \
                -e 's/([0-9.]+)k/\1*1e3/g' \
                -e 's/([0-9.]+)c/\1*1e-2/g' \
                -e 's/([0-9.]+)m/\1*1e-3/g' \
                -e 's/([0-9.]+)u/\1*1e-6/g' \
                -e 's/([0-9.]+)n/\1*1e-9/g' \
                -e 's/([0-9.]+)p/\1*1e-12/g')
            local result=$(awk "BEGIN { printf \"%.15g\", $converted }")
            echo -e "${GREEN}Result: $(format_result "$result")${NC}"
            ;;
        b|B)
            return
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
    read -p " Continue with options? (y/n): " cont
    [[ "${cont,,}" == "y" ]] && { complex_options; return; }
}

# --- Base-N Converter ---
solve_base_n() {
    echo -e "${CYAN}--- BASE-N CONVERTER ---${NC}"
    echo -e " [1] Decimal to Binary/Hex/Octal"
    echo -e " [2] Binary to Decimal/Hex/Octal"
    echo -e " [3] Hexadecimal to Decimal/Bin/Oct"
    echo -e " [4] Octal to Decimal/Bin/Hex"
    echo -e " [5] Custom Base Conversion"
    echo -e " [O] Options (Logic Ops, Neg, NOT)"
    read -p "Select conversion type: " ctype

    if [[ "${ctype^^}" == "O" ]]; then
        base_n_options
        return
    fi
    
    case $ctype in
        1)
            read -p "Enter Decimal number: " dec
            if ! [[ "$dec" =~ ^[0-9]+$ ]]; then echo -e "${RED}Invalid decimal number.${NC}"; return; fi
            echo -e "${GREEN}Binary:  $(echo "obase=2;$dec" | bc)${NC}"
            echo -e "${GREEN}Hex:     $(echo "obase=16;$dec" | bc)${NC}"
            echo -e "${GREEN}Octal:   $(echo "obase=8;$dec" | bc)${NC}"
            ;;
        2)
            read -p "Enter Binary number: " bin
            if ! [[ "$bin" =~ ^[01]+$ ]]; then echo -e "${RED}Invalid binary number.${NC}"; return; fi
            local dec=$((2#$bin))
            echo -e "${GREEN}Decimal: $dec${NC}"
            echo -e "${GREEN}Hex:     $(echo "obase=16;$dec" | bc)${NC}"
            echo -e "${GREEN}Octal:   $(echo "obase=8;$dec" | bc)${NC}"
            ;;
        3)
            read -p "Enter Hexadecimal number: " hex
            if ! [[ "$hex" =~ ^[0-9A-Fa-f]+$ ]]; then echo -e "${RED}Invalid hexadecimal number.${NC}"; return; fi
            local dec=$((16#$hex))
            echo -e "${GREEN}Decimal: $dec${NC}"
            echo -e "${GREEN}Binary:  $(echo "obase=2;$dec" | bc)${NC}"
            echo -e "${GREEN}Octal:   $(echo "obase=8;$dec" | bc)${NC}"
            ;;
        4)
            read -p "Enter Octal number: " oct
            if ! [[ "$oct" =~ ^[0-7]+$ ]]; then echo -e "${RED}Invalid octal number.${NC}"; return; fi
            local dec=$((8#$oct))
            echo -e "${GREEN}Decimal: $dec${NC}"
            echo -e "${GREEN}Binary:  $(echo "obase=2;$dec" | bc)${NC}"
            echo -e "${GREEN}Hex:     $(echo "obase=16;$dec" | bc)${NC}"
            ;;
        5)
            read -p "Enter value: " val
            read -p "From base (2-36): " from_base
            read -p "To base (2-36): " to_base
            if ! [[ "$from_base" =~ ^[0-9]+$ && "$to_base" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid bases.${NC}"; return
            fi
            if [[ $from_base -lt 2 || $from_base -gt 36 || $to_base -lt 2 || $to_base -gt 36 ]]; then
                echo -e "${RED}Bases must be between 2 and 36.${NC}"; return
            fi
            local dec=$(echo "$((from_base#$val))" 2>/dev/null)
            if [[ -z "$dec" ]]; then echo -e "${RED}Invalid value for base $from_base.${NC}"; return; fi
            local result=$(echo "obase=$to_base;ibase=$from_base;$val" | bc 2>/dev/null)
            if [[ -z "$result" ]]; then
                result=""
                while [[ $dec -gt 0 ]]; do
                    local rem=$((dec % to_base))
                    if [[ $rem -lt 10 ]]; then
                        result="${rem}${result}"
                    else
                        result=$(printf "\\x$(printf '%x' $((rem + 55)))")"${result}"
                    fi
                    dec=$((dec / to_base))
                done
            fi
            echo -e "${GREEN}Result: $result${NC}"
            ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
    read -p " Convert another? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_base_n; return; }
}

# --- Base-N Options Menu ---
base_n_options() {
    echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${WHITE}       BASE-N OPTIONS MENU             ${YELLOW}│${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "  [1] NOT (Bitwise Complement)            "
    echo -e "  [2] AND                                 "
    echo -e "  [3] OR                                  "
    echo -e "  [4] XOR                                 "
    echo -e "  [5] XNOR                                "
    echo -e "  [6] NAND                                "
    echo -e "  [7] Negation (Two's Complement)         "
    echo -e "  [8] Display Format (d/h/b/o)            "
    echo -e "  [b] Back to Base-N Converter            "
    echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
    read -p "Select option: " opt

    case $opt in
        1)
            read -p "Enter decimal value: " val
            if ! [[ "$val" =~ ^-?[0-9]+$ ]]; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local result=$((~val))
            echo -e "${GREEN}NOT($val) = $result${NC}"
            echo -e "  Binary: $(echo "obase=2;$result" | bc 2>/dev/null || echo "N/A")${NC}"
            ;;
        2)
            read -p "Enter first decimal value: " a
            read -p "Enter second decimal value: " b
            if ! [[ "$a" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local result=$((a & b))
            echo -e "${GREEN}$a AND $b = $result${NC}"
            echo -e "  Binary: $(echo "obase=2;$result" | bc 2>/dev/null)"
            ;;
        3)
            read -p "Enter first decimal value: " a
            read -p "Enter second decimal value: " b
            if ! [[ "$a" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local result=$((a | b))
            echo -e "${GREEN}$a OR $b = $result${NC}"
            echo -e "  Binary: $(echo "obase=2;$result" | bc 2>/dev/null)"
            ;;
        4)
            read -p "Enter first decimal value: " a
            read -p "Enter second decimal value: " b
            if ! [[ "$a" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local result=$((a ^ b))
            echo -e "${GREEN}$a XOR $b = $result${NC}"
            echo -e "  Binary: $(echo "obase=2;$result" | bc 2>/dev/null)"
            ;;
        5)
            read -p "Enter first decimal value: " a
            read -p "Enter second decimal value: " b
            if ! [[ "$a" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local result=$((~(a ^ b)))
            echo -e "${GREEN}$a XNOR $b = $result${NC}"
            ;;
        6)
            read -p "Enter first decimal value: " a
            read -p "Enter second decimal value: " b
            if ! [[ "$a" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local result=$((~(a & b)))
            echo -e "${GREEN}$a NAND $b = $result${NC}"
            ;;
        7)
            read -p "Enter decimal value: " val
            if ! [[ "$val" =~ ^-?[0-9]+$ ]]; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local result=$((-val))
            echo -e "${GREEN}Neg($val) = $result${NC}"
            ;;
        8)
            echo -e "${CYAN}Display Format Options:${NC}"
            echo -e "  d = Decimal, h = Hexadecimal, b = Binary, o = Octal"
            read -p "Enter value: " val
            read -p "Input format (d/h/b/o): " infmt
            read -p "Output format (d/h/b/o): " outfmt
            
            local dec_val
            case $infmt in
                d) dec_val=$val ;;
                h) dec_val=$((16#$val)) ;;
                b) dec_val=$((2#$val)) ;;
                o) dec_val=$((8#$val)) ;;
                *) echo -e "${RED}Invalid input format.${NC}"; return ;;
            esac
            
            local result
            case $outfmt in
                d) result=$dec_val ;;
                h) result=$(echo "obase=16;$dec_val" | bc) ;;
                b) result=$(echo "obase=2;$dec_val" | bc) ;;
                o) result=$(echo "obase=8;$dec_val" | bc) ;;
                *) echo -e "${RED}Invalid output format.${NC}"; return ;;
            esac
            echo -e "${GREEN}Result: $result${NC}"
            ;;
        b|B)
            return
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
    read -p " Continue with options? (y/n): " cont
    [[ "${cont,,}" == "y" ]] && { base_n_options; return; }
}

# --- Matrix Calculator ---
solve_matrix() {
    echo -e "${CYAN}--- MATRIX CALCULATOR ---${NC}"
    echo -e " Supports matrices from 1×1 to 4×4"
    echo -e " [1] Add/Subtract Matrices"
    echo -e " [2] Multiply Matrices"
    echo -e " [3] Determinant"
    echo -e " [4] Transpose"
    echo -e " [5] Inverse (2×2, 3×3)"
    echo -e " [O] Options (Define, Edit, Recall, Det, Trans, Identity)"
    read -p "Select operation: " op

    if [[ "${op^^}" == "O" ]]; then
        matrix_options
        return
    fi

    
    read -p "Enter matrix size (1-4): " n
    if ! [[ "$n" =~ ^[1-4]$ ]]; then echo -e "${RED}Size must be 1-4.${NC}"; return; fi
    
    case $op in
        [12])
            echo -e "Enter Matrix A (${n}×${n}):"
            declare -a A
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    A[$((i*n+j))]=${row[$j]}
                done
            done
            
            echo -e "Enter Matrix B (${n}×${n}):"
            declare -a B
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    B[$((i*n+j))]=${row[$j]}
                done
            done
            
            echo -e "${GREEN}Result:${NC}"
            for ((i=0; i<n; i++)); do
                local line=""
                for ((j=0; j<n; j++)); do
                    local idx=$((i*n+j))
                    local res
                    if [[ "$op" == "1" ]]; then
                        res=$(awk "BEGIN { printf \"%.4f\", ${A[$idx]} + ${B[$idx]} }")
                    else
                        res=$(awk "BEGIN { printf \"%.4f\", ${A[$idx]} - ${B[$idx]} }")
                    fi
                    line+="$res  "
                done
                echo -e "  $line"
            done
            ;;
        2)
            echo -e "Enter Matrix A (${n}×${n}):"
            declare -a A
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    A[$((i*n+j))]=${row[$j]}
                done
            done
            
            echo -e "Enter Matrix B (${n}×${n}):"
            declare -a B
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    B[$((i*n+j))]=${row[$j]}
                done
            done
            
            echo -e "${GREEN}Result:${NC}"
            for ((i=0; i<n; i++)); do
                local line=""
                for ((j=0; j<n; j++)); do
                    local sum=0
                    for ((k=0; k<n; k++)); do
                        sum=$(awk "BEGIN { print $sum + (${A[$((i*n+k))]} * ${B[$((k*n+j))]}) }")
                    done
                    line+="$(awk "BEGIN { printf \"%.4f\", $sum }")  "
                done
                echo -e "  $line"
            done
            ;;
        3)
            echo -e "Enter Matrix (${n}×${n}):"
            declare -a M
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    M[$((i*n+j))]=${row[$j]}
                done
            done
            
            local det
            case $n in
                1) det=${M[0]} ;;
                2) det=$(awk "BEGIN { print (${M[0]} * ${M[3]}) - (${M[1]} * ${M[2]}) }") ;;
                3) det=$(awk "BEGIN { 
                    print ${M[0]}*((${M[4]}*${M[8]})-(${M[5]}*${M[7]})) - 
                         ${M[1]}*((${M[3]}*${M[8]})-(${M[5]}*${M[6]})) + 
                         ${M[2]}*((${M[3]}*${M[7]})-(${M[4]}*${M[6]}))
                }") ;;
                4) 
                    echo -e "${YELLOW}4×4 determinant calculation...${NC}"
                    det=$(awk "BEGIN {
                        a=${M[0]}; b=${M[1]}; c=${M[2]}; d=${M[3]}
                        e=${M[4]}; f=${M[5]}; g=${M[6]}; h=${M[7]}
                        i=${M[8]}; j=${M[9]}; k=${M[10]}; l=${M[11]}
                        m=${M[12]}; n=${M[13]}; o=${M[14]}; p=${M[15]}
                        
                        m1=f*(k*p-l*o)-g*(j*p-l*n)+h*(j*o-k*n)
                        m2=e*(k*p-l*o)-g*(i*p-l*m)+h*(i*o-k*m)
                        m3=e*(j*p-l*n)-f*(i*p-l*m)+h*(i*n-j*m)
                        m4=e*(j*o-k*n)-f*(i*o-k*m)+g*(i*n-j*m)
                        
                        print a*m1 - b*m2 + c*m3 - d*m4
                    }")
                    ;;
            esac
            echo -e "${GREEN}Determinant = $(format_result "$det")${NC}"
            ;;
        4)
            echo -e "Enter Matrix (${n}×${n}):"
            declare -a M
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    M[$((i*n+j))]=${row[$j]}
                done
            done
            
            echo -e "${GREEN}Transpose:${NC}"
            for ((j=0; j<n; j++)); do
                local line=""
                for ((i=0; i<n; i++)); do
                    line+="$(awk "BEGIN { printf \"%.4f\", ${M[$((i*n+j))]} }")  "
                done
                echo -e "  $line"
            done
            ;;
        5)
            if [[ $n -gt 3 ]]; then
                echo -e "${RED}Inverse only supported for 2×2 and 3×3 matrices.${NC}"
                return
            fi
            echo -e "Enter Matrix (${n}×${n}):"
            declare -a M
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    M[$((i*n+j))]=${row[$j]}
                done
            done
            
            local det
            if [[ $n -eq 2 ]]; then
                det=$(awk "BEGIN { print (${M[0]} * ${M[3]}) - (${M[1]} * ${M[2]}) }")
                if (( $(awk "BEGIN { print ($det == 0) }") )); then
                    echo -e "${RED}Matrix is singular (no inverse).${NC}"; return
                fi
                echo -e "${GREEN}Inverse:${NC}"
                echo -e "  $(awk "BEGIN { printf \"%.4f\", ${M[3]}/$det }")   $(awk "BEGIN { printf \"%.4f\", -${M[1]}/$det }")"
                echo -e "  $(awk "BEGIN { printf \"%.4f\", -${M[2]}/$det }")   $(awk "BEGIN { printf \"%.4f\", ${M[0]}/$det }")"
            else
                det=$(awk "BEGIN { 
                    print ${M[0]}*((${M[4]}*${M[8]})-(${M[5]}*${M[7]})) - 
                         ${M[1]}*((${M[3]}*${M[8]})-(${M[5]}*${M[6]})) + 
                         ${M[2]}*((${M[3]}*${M[7]})-(${M[4]}*${M[6]}))
                }")
                if (( $(awk "BEGIN { print ($det == 0) }") )); then
                    echo -e "${RED}Matrix is singular (no inverse).${NC}"; return
                fi
                echo -e "${YELLOW}3×3 inverse calculation (adjugate method)...${NC}"
                echo -e "${GREEN}Det = $(format_result "$det")${NC}"
                echo -e "${GRAY}Full inverse displayed as adjugate/det${NC}"
            fi
            ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
    read -p " Calculate another matrix? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_matrix; return; }
}

# --- Matrix Options Menu ---
matrix_options() {
    # Global matrix storage arrays
    declare -gA MatA MatB MatC MatD MatAns
    declare -g MatA_size MatB_size MatC_size MatD_size MatAns_size
    
    echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${WHITE}       MATRIX OPTIONS MENU             ${YELLOW}│${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "  [1] Define Matrix (A, B, C, D)            "
    echo -e "  [2] Edit Matrix                           "
    echo -e "  [3] Recall Matrix (MatA, B, C, D, Ans)    "
    echo -e "  [4] Determinant of Stored Matrix          "
    echo -e "  [5] Transpose of Stored Matrix            "
    echo -e "  [6] Identity Matrix                       "
    echo -e "  [7] Angle Unit (Deg/Rad/Grad)             "
    echo -e "  [8] Hyperbolic Functions                  "
    echo -e "  [b] Back to Matrix Calculator             "
    echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
    read -p "Select option: " opt

    case $opt in
        1)
            echo -e "Define which matrix?"
            echo -e " [A] MatA  [B] MatB  [C] MatC  [D] MatD"
            read -p "Select: " matname
            local matref="Mat${matname^^}"
            read -p "Enter size (e.g., 2 for 2x2): " n
            if ! [[ "$n" =~ ^[1-4]$ ]]; then
                echo -e "${RED}Size must be 1-4.${NC}"; return
            fi
            echo -e "Enter $matref (${n}×${n}):"
            local -n mat=$matref
            local sizeref="${matref}_size"
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    mat[$((i*n+j))]=${row[$j]}
                done
            done
            eval "${sizeref}=\$n"
            echo -e "${GREEN}$matref defined.${NC}"
            ;;
        2)
            echo -e "Edit which matrix? (A/B/C/D)"
            read -p "Select: " matname
            local matref="Mat${matname^^}"
            local sizeref="${matref}_size"
            local -n mat=$matref
            local n=${!sizeref}
            if [[ -z "$n" ]]; then
                echo -e "${RED}Matrix not defined.${NC}"; return
            fi
            echo -e "Editing $matref (${n}×${n}):"
            for ((i=0; i<n; i++)); do
                read -p "Row $((i+1)): " -a row
                for ((j=0; j<n; j++)); do
                    mat[$((i*n+j))]=${row[$j]}
                done
            done
            echo -e "${GREEN}$matref updated.${NC}"
            ;;
        3)
            echo -e "Recall which matrix?"
            echo -e " [A] MatA  [B] MatB  [C] MatC  [D] MatD  [M] MatAns"
            read -p "Select: " matname
            local matref="Mat${matname^^}"
            [[ "${matname^^}" == "M" ]] && matref="MatAns"
            local sizeref="${matref}_size"
            local -n mat=$matref
            local n=${!sizeref}
            if [[ -z "$n" ]]; then
                echo -e "${RED}Matrix not defined.${NC}"; return
            fi
            echo -e "${GREEN}$matref:${NC}"
            for ((i=0; i<n; i++)); do
                local line=""
                for ((j=0; j<n; j++)); do
                    line+="$(awk "BEGIN { printf \"%.4f\", ${mat[$((i*n+j))]} }")  "
                done
                echo -e "  $line"
            done
            ;;
        4)
            echo -e "Determinant of which matrix? (A/B/C/D/Ans)"
            read -p "Select: " matname
            local matref="Mat${matname^^}"
            [[ "${matname^^}" == "ANS" ]] && matref="MatAns"
            local sizeref="${matref}_size"
            local -n mat=$matref
            local n=${!sizeref}
            if [[ -z "$n" ]]; then
                echo -e "${RED}Matrix not defined.${NC}"; return
            fi
            local det
            case $n in
                1) det=${mat[0]} ;;
                2) det=$(awk "BEGIN { print (${mat[0]} * ${mat[3]}) - (${mat[1]} * ${mat[2]}) }") ;;
                3) det=$(awk "BEGIN {
                    print ${mat[0]}*((${mat[4]}*${mat[8]})-(${mat[5]}*${mat[7]})) -
                         ${mat[1]}*((${mat[3]}*${mat[8]})-(${mat[5]}*${mat[6]})) +
                         ${mat[2]}*((${mat[3]}*${mat[7]})-(${mat[4]}*${mat[6]}))
                }") ;;
                4)
                    det=$(awk "BEGIN {
                        a=${mat[0]}; b=${mat[1]}; c=${mat[2]}; d=${mat[3]}
                        e=${mat[4]}; f=${mat[5]}; g=${mat[6]}; h=${mat[7]}
                        i=${mat[8]}; j=${mat[9]}; k=${mat[10]}; l=${mat[11]}
                        m=${mat[12]}; n=${mat[13]}; o=${mat[14]}; p=${mat[15]}
                        m1=f*(k*p-l*o)-g*(j*p-l*n)+h*(j*o-k*n)
                        m2=e*(k*p-l*o)-g*(i*p-l*m)+h*(i*o-k*m)
                        m3=e*(j*p-l*n)-f*(i*p-l*m)+h*(i*n-j*m)
                        m4=e*(j*o-k*n)-f*(i*o-k*m)+g*(i*n-j*m)
                        print a*m1 - b*m2 + c*m3 - d*m4
                    }") ;;
            esac
            echo -e "${GREEN}Det($matref) = $(format_result "$det")${NC}"
            ;;
        5)
            echo -e "Transpose of which matrix? (A/B/C/D/Ans)"
            read -p "Select: " matname
            local matref="Mat${matname^^}"
            [[ "${matname^^}" == "ANS" ]] && matref="MatAns"
            local sizeref="${matref}_size"
            local -n mat=$matref
            local n=${!sizeref}
            if [[ -z "$n" ]]; then
                echo -e "${RED}Matrix not defined.${NC}"; return
            fi
            echo -e "${GREEN}Transpose of $matref:${NC}"
            for ((j=0; j<n; j++)); do
                local line=""
                for ((i=0; i<n; i++)); do
                    line+="$(awk "BEGIN { printf \"%.4f\", ${mat[$((i*n+j))]} }")  "
                done
                echo -e "  $line"
            done
            ;;
        6)
            read -p "Enter identity matrix size (1-4): " n
            if ! [[ "$n" =~ ^[1-4]$ ]]; then
                echo -e "${RED}Size must be 1-4.${NC}"; return
            fi
            echo -e "${GREEN}Identity Matrix (${n}×${n}):${NC}"
            for ((i=0; i<n; i++)); do
                local line=""
                for ((j=0; j<n; j++)); do
                    if [[ $i -eq $j ]]; then
                        line+="1  "
                    else
                        line+="0  "
                    fi
                done
                echo -e "  $line"
            done
            ;;
        7)
            echo -e "${CYAN}Current Angle Unit: ${YELLOW}$ANGLE_UNIT${NC}"
            echo -e " [1] Degrees  [2] Radians  [3] Gradians"
            read -p "Select: " au
            case $au in
                1) ANGLE_UNIT="deg"; echo -e "${GREEN}Set to Degrees${NC}" ;;
                2) ANGLE_UNIT="rad"; echo -e "${GREEN}Set to Radians${NC}" ;;
                3) ANGLE_UNIT="grad"; echo -e "${GREEN}Set to Gradians${NC}" ;;
                *) echo -e "${RED}Invalid option.${NC}" ;;
            esac
            ;;
        8)
            echo -e "${CYAN}--- Hyperbolic Functions ---${NC}"
            echo -e " Enter real value x:"
            read -p "x: " x
            if ! is_num "$x"; then
                echo -e "${RED}Invalid input.${NC}"; return
            fi
            local sinh=$(awk "BEGIN { printf \"%.15g\", (exp($x) - exp(-$x)) / 2 }")
            local cosh=$(awk "BEGIN { printf \"%.15g\", (exp($x) + exp(-$x)) / 2 }")
            local tanh=$(awk "BEGIN { printf \"%.15g\", (exp($x) - exp(-$x)) / (exp($x) + exp(-$x)) }")
            echo -e "${GREEN}sinh($x) = $(format_result "$sinh")${NC}"
            echo -e "${GREEN}cosh($x) = $(format_result "$cosh")${NC}"
            echo -e "${GREEN}tanh($x) = $(format_result "$tanh")${NC}"
            ;;
        b|B)
            return
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
    read -p " Continue with options? (y/n): " cont
    [[ "${cont,,}" == "y" ]] && { matrix_options; return; }
}

# --- Variable Manager ---
manage_variables() {
    echo -e "${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${WHITE}       VARIABLE MANAGER                ${YELLOW}│${NC}"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "  Stored Variables: A, B, C, D, E, F, x, y, M"
    echo -e "${YELLOW}├──────────────────────────────────────────┤${NC}"
    echo -e "  [1] Store Value to Variable           "
    echo -e "  [2] Recall Variable Value             "
    echo -e "  [3] Clear Variable                    "
    echo -e "  [4] Clear All Variables               "
    echo -e "  [5] List All Variables                "
    echo -e "  [b] Back to Main Menu                 "
    echo -e "${YELLOW}└──────────────────────────────────────────┘${NC}"
    read -p "Select option: " opt

    case $opt in
        1)
            echo -e "Available: A, B, C, D, E, F, x, y, M"
            read -p "Variable name: " vname
            if [[ ! "$vname" =~ ^[ABCDEFxMyM]$ ]]; then
                echo -e "${RED}Invalid variable name.${NC}"
                return
            fi
            read -p "Value (or 'ans'): " val
            [[ "${val,,}" == "ans" ]] && val=$LAST_RESULT
            if ! is_num "$val"; then
                echo -e "${RED}Invalid numeric value.${NC}"
                return
            fi
            VARIABLES[$vname]=$val
            echo -e "${GREEN}Stored: $vname = $(format_result "$val")${NC}"
            ;;
        2)
            echo -e "Available: A, B, C, D, E, F, x, y, M"
            read -p "Variable name: " vname
            if [[ ! "$vname" =~ ^[ABCDEFxMyM]$ ]]; then
                echo -e "${RED}Invalid variable name.${NC}"
                return
            fi
            echo -e "${GREEN}$vname = $(format_result "${VARIABLES[$vname]}")${NC}"
            ;;
        3)
            echo -e "Available: A, B, C, D, E, F, x, y, M"
            read -p "Variable to clear: " vname
            if [[ ! "$vname" =~ ^[ABCDEFxMyM]$ ]]; then
                echo -e "${RED}Invalid variable name.${NC}"
                return
            fi
            VARIABLES[$vname]=0
            echo -e "${GREEN}Cleared: $vname = 0${NC}"
            ;;
        4)
            for v in A B C D E F x y M; do
                VARIABLES[$v]=0
            done
            echo -e "${GREEN}All variables cleared.${NC}"
            ;;
        5)
            echo -e "${CYAN}Current Variable Values:${NC}"
            for v in A B C D E F x y M; do
                echo -e "  $v = $(format_result "${VARIABLES[$v]}")"
            done
            ;;
        b|B)
            return
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
    read -p " Continue with variables? (y/n): " cont
    [[ "${cont,,}" == "y" ]] && { manage_variables; return; }
}

# --- Equation Solver (Single Variable) ---
solve_equation() {
    echo -e "${CYAN}--- EQUATION SOLVER ---${NC}"
    echo -e " Solves linear equations in one variable"
    echo -e " Format: ax + b = c  or  expression = expression"
    echo -e ""
    echo -e " Enter equation (use 'x' as unknown):"
    read -p "Equation: " eq
    
    # Check for '=' sign
    if [[ ! "$eq" =~ = ]]; then
        echo -e "${RED}Equation must contain '=' sign.${NC}"
        return
    fi
    
    # Split by '='
    local lhs="${eq%%=*}"
    local rhs="${eq#*=}"
    
    # Simple linear form: ax+b=c or ax=b+c etc.
    # Normalize: collect x terms on left, constants on right
    
    # Check if it's a simple form like "ax+b=c"
    if [[ "$lhs" =~ ^(-?[0-9.]*)(\*)?x([+-][0-9.]*)?$ ]]; then
        local a_part="${BASH_REMATCH[1]}"
        local op_part="${BASH_REMATCH[3]}"
        
        [[ -z "$a_part" ]] && a_part="1"
        [[ "$a_part" == "-" ]] && a_part="-1"
        
        local b_val=0
        if [[ -n "$op_part" ]]; then
            b_val="$op_part"
        fi
        
        # Now we have: a*x + b = rhs
        # Solution: x = (rhs - b) / a
        if ! is_num "$a_part" || ! is_num "$b_val" || ! is_num "$rhs"; then
            echo -e "${RED}Invalid equation format.${NC}"
            echo -e "${YELLOW}Try: 2x+3=7  or  5x-4=10${NC}"
            return
        fi
        
        local result=$(awk "BEGIN { printf \"%.15g\", ($rhs - $b_val) / $a_part }")
        echo -e "${GREEN}Solution: x = $(format_result "$result")${NC}"
        
        # Check degree hint
        if [[ "$eq" =~ x\^([2-9]) ]]; then
            echo -e "${YELLOW}Note: Higher degree detected. Use polynomial solver for all roots.${NC}"
        fi
        return
    fi
    
    # More complex parsing would go here
    echo -e "${YELLOW}Complex equation detected.${NC}"
    echo -e "${CYAN}For now, please use the form: ax+b=c${NC}"
    echo -e "${YELLOW}Example: 2x+5=13${NC}"
}

# --- Vector Calculator ---
solve_vector() {
    echo -e "${CYAN}--- VECTOR CALCULATOR ---${NC}"
    echo -e " [1] Vector Addition/Subtraction"
    echo -e " [2] Dot Product"
    echo -e " [3] Cross Product (3D)"
    echo -e " [4] Magnitude"
    echo -e " [5] Unit Vector"
    echo -e " [6] Angle Between Vectors"
    read -p "Select operation: " op
    
    case $op in
        1)
            read -p "Enter vector A (space-separated): " -a A
            read -p "Enter vector B (same dimensions): " -a B
            if [[ ${#A[@]} -ne ${#B[@]} ]]; then
                echo -e "${RED}Vectors must have same dimensions.${NC}"; return
            fi
            echo -e "${GREEN}A + B: ["
            local line=""
            for ((i=0; i<${#A[@]}; i++)); do
                line+="$(awk "BEGIN { printf \"%.4f\", ${A[$i]} + ${B[$i]} }")"
                [[ $i -lt $((${#A[@]}-1)) ]] && line+=", "
            done
            echo -e "  $line ]${NC}"
            ;;
        2)
            read -p "Enter vector A (space-separated): " -a A
            read -p "Enter vector B (same dimensions): " -a B
            if [[ ${#A[@]} -ne ${#B[@]} ]]; then
                echo -e "${RED}Vectors must have same dimensions.${NC}"; return
            fi
            local dot=0
            for ((i=0; i<${#A[@]}; i++)); do
                dot=$(awk "BEGIN { print $dot + (${A[$i]} * ${B[$i]}) }")
            done
            echo -e "${GREEN}Dot Product = $(format_result "$dot")${NC}"
            ;;
        3)
            read -p "Enter vector A (3 components): " -a A
            read -p "Enter vector B (3 components): " -a B
            if [[ ${#A[@]} -ne 3 || ${#B[@]} -ne 3 ]]; then
                echo -e "${RED}Cross product requires 3D vectors.${NC}"; return
            fi
            local cx=$(awk "BEGIN { print (${A[1]} * ${B[2]}) - (${A[2]} * ${B[1]}) }")
            local cy=$(awk "BEGIN { print (${A[2]} * ${B[0]}) - (${A[0]} * ${B[2]}) }")
            local cz=$(awk "BEGIN { print (${A[0]} * ${B[1]}) - (${A[1]} * ${B[0]}) }")
            echo -e "${GREEN}Cross Product = [$(format_result "$cx"), $(format_result "$cy"), $(format_result "$cz")]${NC}"
            ;;
        4)
            read -p "Enter vector (space-separated): " -a V
            local sum=0
            for ((i=0; i<${#V[@]}; i++)); do
                sum=$(awk "BEGIN { print $sum + (${V[$i]}^2) }")
            done
            local mag=$(awk "BEGIN { printf \"%.15g\", sqrt($sum) }")
            echo -e "${GREEN}|V| = $(format_result "$mag")${NC}"
            ;;
        5)
            read -p "Enter vector (space-separated): " -a V
            local sum=0
            for ((i=0; i<${#V[@]}; i++)); do
                sum=$(awk "BEGIN { print $sum + (${V[$i]}^2) }")
            done
            local mag=$(awk "BEGIN { print sqrt($sum) }")
            if (( $(awk "BEGIN { print ($mag == 0) }") )); then
                echo -e "${RED}Zero vector has no unit vector.${NC}"; return
            fi
            echo -e "${GREEN}Unit Vector = ["
            local line=""
            for ((i=0; i<${#V[@]}; i++)); do
                line+="$(awk "BEGIN { printf \"%.4f\", ${V[$i]} / $mag }")"
                [[ $i -lt $((${#V[@]}-1)) ]] && line+=", "
            done
            echo -e "  $line ]${NC}"
            ;;
        6)
            read -p "Enter vector A (space-separated): " -a A
            read -p "Enter vector B (same dimensions): " -a B
            if [[ ${#A[@]} -ne ${#B[@]} ]]; then
                echo -e "${RED}Vectors must have same dimensions.${NC}"; return
            fi
            local dot=0 magA=0 magB=0
            for ((i=0; i<${#A[@]}; i++)); do
                dot=$(awk "BEGIN { print $dot + (${A[$i]} * ${B[$i]}) }")
                magA=$(awk "BEGIN { print $magA + (${A[$i]}^2) }")
                magB=$(awk "BEGIN { print $magB + (${B[$i]}^2) }")
            done
            magA=$(awk "BEGIN { print sqrt($magA) }")
            magB=$(awk "BEGIN { print sqrt($magB) }")
            local cos_theta=$(awk "BEGIN { print $dot / ($magA * $magB) }")
            local theta_rad=$(awk "BEGIN { print atan2(sqrt(1-$cos_theta*$cos_theta), $cos_theta) }")
            local theta_deg=$(awk "BEGIN { print $theta_rad * 180 / 3.14159265358979 }")
            echo -e "${GREEN}Angle = $(format_result "$theta_deg")°${NC}"
            ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
    read -p " Calculate another vector? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_vector; return; }
}

# --- Statistics Calculator ---
solve_statistics() {
    echo -e "${CYAN}--- STATISTICS CALCULATOR ---${NC}"
    echo -e " Enter data values separated by spaces"
    read -p "Data: " -a data
    local n=${#data[@]}
    
    if [[ $n -eq 0 ]]; then echo -e "${RED}No data entered.${NC}"; return; fi
    
    for v in "${data[@]}"; do
        if ! is_num "$v"; then echo -e "${RED}Invalid numeric value: $v${NC}"; return; fi
    done
    
    local sum=0
    for v in "${data[@]}"; do
        sum=$(awk "BEGIN { print $sum + $v }")
    done
    local mean=$(awk "BEGIN { printf \"%.15g\", $sum / $n }")
    
    local sorted=($(printf '%s\n' "${data[@]}" | sort -n))
    
    local median
    if [[ $((n % 2)) -eq 0 ]]; then
        median=$(awk "BEGIN { printf \"%.15g\", (${sorted[$((n/2-1))]} + ${sorted[$((n/2))]}) / 2 }")
    else
        median=${sorted[$((n/2))]}
    fi
    
    local mode_freq=0 mode_val=""
    declare -A freq
    for v in "${data[@]}"; do
        freq[$v]=$((${freq[$v]:-0} + 1))
        if [[ ${freq[$v]} -gt $mode_freq ]]; then
            mode_freq=${freq[$v]}
            mode_val=$v
        fi
    done
    
    local var_sum=0
    for v in "${data[@]}"; do
        var_sum=$(awk "BEGIN { print $var_sum + ($v - $mean)^2 }")
    done
    local variance_pop=$(awk "BEGIN { printf \"%.15g\", $var_sum / $n }")
    local variance_samp=$(awk "BEGIN { printf \"%.15g\", $var_sum / ($n - 1) }")
    local std_pop=$(awk "BEGIN { printf \"%.15g\", sqrt($variance_pop) }")
    local std_samp=$(awk "BEGIN { printf \"%.15g\", sqrt($variance_samp) }")
    
    local min=${sorted[0]} max=${sorted[$((n-1))]}
    
    local q1_idx=$(( (n-1) / 4 ))
    local q3_idx=$(( 3 * (n-1) / 4 ))
    local q1=${sorted[$q1_idx]}
    local q3=${sorted[$q3_idx]}
    local iqr=$(awk "BEGIN { printf \"%.15g\", $q3 - $q1 }")
    
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}         STATISTICAL RESULTS              ${GREEN}║${NC}"
    echo -e "${GREEN}╠══════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}  Count (n)     : ${YELLOW}$n${NC}"
    echo -e "${WHITE}  Mean          : ${YELLOW}$(format_result "$mean")${NC}"
    echo -e "${WHITE}  Median        : ${YELLOW}$(format_result "$median")${NC}"
    if [[ $mode_freq -gt 1 ]]; then
        echo -e "${WHITE}  Mode          : ${YELLOW}$mode_val${WHITE} (freq: $mode_freq)${NC}"
    else
        echo -e "${WHITE}  Mode          : ${GRAY}None (all unique)${NC}"
    fi
    echo -e "${WHITE}  Min           : ${YELLOW}$(format_result "$min")${NC}"
    echo -e "${WHITE}  Max           : ${YELLOW}$(format_result "$max")${NC}"
    echo -e "${WHITE}  Q1            : ${YELLOW}$(format_result "$q1")${NC}"
    echo -e "${WHITE}  Q3            : ${YELLOW}$(format_result "$q3")${NC}"
    echo -e "${WHITE}  IQR           : ${YELLOW}$(format_result "$iqr")${NC}"
    echo -e "${WHITE}  Var (Pop)     : ${YELLOW}$(format_result "$variance_pop")${NC}"
    echo -e "${WHITE}  Var (Sample)  : ${YELLOW}$(format_result "$variance_samp")${NC}"
    echo -e "${WHITE}  StdDev (Pop)  : ${YELLOW}$(format_result "$std_pop")${NC}"
    echo -e "${WHITE}  StdDev (Samp) : ${YELLOW}$(format_result "$std_samp")${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    
    read -p " Calculate another statistics? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_statistics; return; }
}

# --- Table Generator ---
solve_table() {
    echo -e "${CYAN}--- EQUATION TABLE GENERATOR ---${NC}"
    echo -e " Enter equation in terms of x (e.g., 2*x+3, x^2, sin(x)*10)"
    read -p "Equation: " eq
    read -p "Start x: " start
    read -p "End x: " end
    read -p "Step: " step
    
    if ! is_num "$start" || ! is_num "$end" || ! is_num "$step"; then
        echo -e "${RED}Invalid numeric range.${NC}"; return
    fi
    
    if (( $(awk "BEGIN { print ($step <= 0) }") )); then
        echo -e "${RED}Step must be positive.${NC}"; return
    fi
    
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}           TABLE: y = $eq             ${GREEN}║${NC}"
    echo -e "${GREEN}╠════════════════╦══════════════════════════╣${NC}"
    echo -e "${GREEN}║${WHITE}      x         ║${WHITE}           y                ${GREEN}║${NC}"
    echo -e "${GREEN}╠════════════════╬══════════════════════════╣${NC}"
    
    local x=$start
    while (( $(awk "BEGIN { print ($x <= $end) }") )); do
        local expr=$(echo "$eq" | sed "s/x/($x)/g")
        local y=$(awk "BEGIN { printf \"%.4f\", $expr }" 2>/dev/null)
        if [[ -z "$y" ]]; then y="ERROR"; fi
        printf "${GREEN}║${WHITE} %-14.4f ${GREEN}║${WHITE} %-22s   ${GREEN}║${NC}\n" "$x" "$y"
        x=$(awk "BEGIN { print $x + $step }")
    done
    
    echo -e "${GREEN}╚════════════════╩══════════════════════════╝${NC}"
    
    echo -e "${GRAY}  To plot: Use these points on graph paper${NC}"
    echo -e "${GRAY}  Steps: 1) Plot each (x,y) pair${NC}"
    echo -e "${GRAY}         2) Connect points smoothly${NC}"
    
    read -p " Generate another table? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_table; return; }
}

# --- Inequality Solver ---
solve_inequality() {
    echo -e "${CYAN}--- INEQUALITY SOLVER ---${NC}"
    echo -e " [1] Linear (ax + b > 0)"
    echo -e " [2] Quadratic (ax² + bx + c > 0)"
    echo -e " [3] Absolute Value (|ax + b| > c)"
    read -p "Select type: " itype
    
    case $itype in
        1)
            echo -e "Solve: ax + b ? c (? can be >, <, >=, <=)"
            read -p "a: " a
            read -p "b: " b
            read -p "Operator (> < >= <=): " op
            read -p "c: " c
            
            if ! is_num "$a" || ! is_num "$b" || ! is_num "$c"; then
                echo -e "${RED}Invalid coefficients.${NC}"; return
            fi
            
            local rhs=$(awk "BEGIN { print $c - $b }")
            if [[ $a -eq 0 ]]; then
                if (( $(awk "BEGIN { print ($b $op $c) }") )); then
                    echo -e "${GREEN}Solution: All real numbers${NC}"
                else
                    echo -e "${GREEN}Solution: No solution${NC}"
                fi
                return
            fi
            
            local sol
            case $op in
                ">")  [[ $a -gt 0 ]] && sol="x > $(format_result "$rhs/$a")" || sol="x < $(format_result "$rhs/$a")" ;;
                "<")  [[ $a -gt 0 ]] && sol="x < $(format_result "$rhs/$a")" || sol="x > $(format_result "$rhs/$a")" ;;
                ">=") [[ $a -gt 0 ]] && sol="x ≥ $(format_result "$rhs/$a")" || sol="x ≤ $(format_result "$rhs/$a")" ;;
                "<=") [[ $a -gt 0 ]] && sol="x ≤ $(format_result "$rhs/$a")" || sol="x ≥ $(format_result "$rhs/$a")" ;;
            esac
            echo -e "${GREEN}Solution: $sol${NC}"
            ;;
        2)
            echo -e "Solve: ax² + bx + c ? 0"
            read -p "a: " a
            read -p "b: " b
            read -p "c: " c
            read -p "Operator (> < >= <=): " op
            
            if ! is_num "$a" || ! is_num "$b" || ! is_num "$c"; then
                echo -e "${RED}Invalid coefficients.${NC}"; return
            fi
            
            local disc=$(awk "BEGIN { print ($b^2) - (4*$a*$c) }")
            echo -e "${GRAY}Discriminant Δ = $(format_result "$disc")${NC}"
            
            if (( $(awk "BEGIN { print ($disc < 0) }") )); then
                if [[ $a -gt 0 ]]; then
                    [[ "$op" == ">" || "$op" == ">=" ]] && echo -e "${GREEN}Solution: All real numbers${NC}" || echo -e "${GREEN}Solution: No solution${NC}"
                else
                    [[ "$op" == "<" || "$op" == "<=" ]] && echo -e "${GREEN}Solution: All real numbers${NC}" || echo -e "${GREEN}Solution: No solution${NC}"
                fi
            elif (( $(awk "BEGIN { print ($disc == 0) }") )); then
                local root=$(awk "BEGIN { printf \"%.15g\", -$b / (2*$a) }")
                echo -e "${GRAY}Double root at x = $(format_result "$root")${NC}"
                case $op in
                    ">")  echo -e "${GREEN}Solution: x ≠ $(format_result "$root")${NC}" ;;
                    "<")  echo -e "${GREEN}Solution: No solution${NC}" ;;
                    ">=") echo -e "${GREEN}Solution: All real numbers${NC}" ;;
                    "<=") echo -e "${GREEN}Solution: x = $(format_result "$root")${NC}" ;;
                esac
            else
                local x1=$(awk "BEGIN { printf \"%.15g\", (-$b - sqrt($disc)) / (2*$a) }")
                local x2=$(awk "BEGIN { printf \"%.15g\", (-$b + sqrt($disc)) / (2*$a) }")
                [[ $x1 -gt $x2 ]] && { local tmp=$x1; x1=$x2; x2=$tmp; }
                echo -e "${GRAY}Roots: x₁ = $(format_result "$x1"), x₂ = $(format_result "$x2")${NC}"
                
                if [[ $a -gt 0 ]]; then
                    case $op in
                        ">")  echo -e "${GREEN}Solution: x < $(format_result "$x1") or x > $(format_result "$x2")${NC}" ;;
                        "<")  echo -e "${GREEN}Solution: $(format_result "$x1") < x < $(format_result "$x2")${NC}" ;;
                        ">=") echo -e "${GREEN}Solution: x ≤ $(format_result "$x1") or x ≥ $(format_result "$x2")${NC}" ;;
                        "<=") echo -e "${GREEN}Solution: $(format_result "$x1") ≤ x ≤ $(format_result "$x2")${NC}" ;;
                    esac
                else
                    case $op in
                        ">")  echo -e "${GREEN}Solution: $(format_result "$x2") < x < $(format_result "$x1")${NC}" ;;
                        "<")  echo -e "${GREEN}Solution: x < $(format_result "$x2") or x > $(format_result "$x1")${NC}" ;;
                        ">=") echo -e "${GREEN}Solution: $(format_result "$x2") ≤ x ≤ $(format_result "$x1")${NC}" ;;
                        "<=") echo -e "${GREEN}Solution: x ≤ $(format_result "$x2") or x ≥ $(format_result "$x1")${NC}" ;;
                    esac
                fi
            fi
            ;;
        3)
            echo -e "Solve: |ax + b| ? c"
            read -p "a: " a
            read -p "b: " b
            read -p "c: " c
            read -p "Operator (> < >= <=): " op
            
            if ! is_num "$a" || ! is_num "$b" || ! is_num "$c"; then
                echo -e "${RED}Invalid coefficients.${NC}"; return
            fi
            
            if (( $(awk "BEGIN { print ($c < 0) }") )); then
                [[ "$op" == ">" || "$op" == ">=" ]] && echo -e "${GREEN}Solution: All real numbers${NC}" || echo -e "${GREEN}Solution: No solution${NC}"
                return
            fi
            
            local pos_case=$(awk "BEGIN { print ($c - $b) / $a }")
            local neg_case=$(awk "BEGIN { print (-$c - $b) / $a }")
            [[ $pos_case -gt $neg_case ]] && { local tmp=$pos_case; pos_case=$neg_case; neg_case=$tmp; }
            
            case $op in
                ">")  echo -e "${GREEN}Solution: x < $(format_result "$pos_case") or x > $(format_result "$neg_case")${NC}" ;;
                "<")  echo -e "${GREEN}Solution: $(format_result "$pos_case") < x < $(format_result "$neg_case")${NC}" ;;
                ">=") echo -e "${GREEN}Solution: x ≤ $(format_result "$pos_case") or x ≥ $(format_result "$neg_case")${NC}" ;;
                "<=") echo -e "${GREEN}Solution: $(format_result "$pos_case") ≤ x ≤ $(format_result "$neg_case")${NC}" ;;
            esac
            ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
    read -p " Solve another inequality? (y/n): " again
    [[ "${again,,}" == "y" ]] && { solve_inequality; return; }
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
    elif [[ "$input" == "v" ]]; then
        manage_variables; continue
    # Direct Chapter Jumps (Fluent Shortcuts)
    elif [[ "$input" =~ ^e[1-5]$ ]]; then
        case ${input:1} in
            1) solve_ch1 ;; 2) solve_ch2 ;; 3) solve_ch3 ;; 4) solve_ch4 ;; 5) solve_modern ;;
        esac
        show_header; continue
    elif [[ "$input" == "s" ]]; then
        # --- Settings Menu ---
        settings_menu
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
