
#!/bin/bash

# ==========================================
# Password Policy Security Check
# ==========================================

check_password_policy() {

    echo ""
    echo "---- Password Policy Check ----"

    CONFIG_FILE="/etc/login.defs"

    if [ ! -f "$CONFIG_FILE" ]; then
        log_message "HIGH" "Password configuration file missing" "Check /etc/login.defs"
        return
    fi

    # Read password policy values
    MIN_LENGTH=$(awk '$1=="PASS_MIN_LEN" {print $2; exit}' "$CONFIG_FILE")
    MAX_DAYS=$(awk '$1=="PASS_MAX_DAYS" {print $2; exit}' "$CONFIG_FILE")

    MIN_LENGTH=${MIN_LENGTH:-0}
    MAX_DAYS=${MAX_DAYS:-99999}

    echo "Minimum Password Length: $MIN_LENGTH"
    echo "Maximum Password Age: $MAX_DAYS days"

    # Check minimum password length
    if [ "$MIN_LENGTH" -lt "$MIN_PASSWORD_LENGTH" ]; then

        log_message "HIGH" \
        "Minimum password length is insecure: $MIN_LENGTH" \
        "Set PASS_MIN_LEN to $MIN_PASSWORD_LENGTH in /etc/login.defs"

    else

        log_message "INFO" \
        "Minimum password length is acceptable" \
        "No action required"

    fi

    # Check maximum password age
    if [ "$MAX_DAYS" -gt "$MAX_PASSWORD_DAYS" ]; then

        log_message "MEDIUM" \
        "Password maximum age is too high: $MAX_DAYS days" \
        "Set PASS_MAX_DAYS to $MAX_PASSWORD_DAYS in /etc/login.defs"

    else

        log_message "INFO" \
        "Password maximum age is acceptable" \
        "No action required"

    fi
}

