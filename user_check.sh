
#!/bin/bash

# ==========================================
# User Account Security Audit
# ==========================================

check_user_accounts() {

    echo ""
    echo "---- User Account Security Check ----"

    # Check accounts with UID 0
    echo "Checking accounts with UID 0..."

    ROOT_USERS=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)

    echo "$ROOT_USERS"

    EXTRA_ROOT=$(echo "$ROOT_USERS" | grep -v '^root$')

    if [ -n "$EXTRA_ROOT" ]; then

        log_message "HIGH" \
        "Additional UID 0 accounts detected: $EXTRA_ROOT" \
        "Investigate and remove unauthorized root-level accounts"

    else

        log_message "INFO" \
        "No additional UID 0 accounts detected" \
        "No action required"

    fi

    # Check accounts with empty passwords
    echo ""
    echo "Checking for accounts with empty passwords..."

    if [ ! -r /etc/shadow ]; then

        log_message "WARNING" \
        "Cannot read password database" \
        "Run audit with root privileges"

        return

    fi

    EMPTY_USERS=$(awk -F: '$2 == "" {print $1}' /etc/shadow)

    if [ -n "$EMPTY_USERS" ]; then

        echo "Accounts with empty passwords:"
        echo "$EMPTY_USERS"

        log_message "HIGH" \
        "Accounts with empty passwords detected: $EMPTY_USERS" \
        "Investigate accounts and configure secure passwords"

    else

        echo "No accounts with empty passwords found."

        log_message "INFO" \
        "No empty password accounts detected" \
        "No action required"

    fi

    # Display total user accounts
    TOTAL_USERS=$(awk -F: 'END {print NR}' /etc/passwd)

    echo ""
    echo "Total system accounts: $TOTAL_USERS"

    log_message "INFO" \
    "User account audit completed. Total accounts: $TOTAL_USERS" \
    "Review account list regularly"

}

