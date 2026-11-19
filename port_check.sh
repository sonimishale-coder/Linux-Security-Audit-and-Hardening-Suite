
#!/bin/bash

# ==========================================
# Open Port Detection
# ==========================================

check_open_ports() {

    echo ""
    echo "---- Open Port Detection ----"

    if ! command -v netstat >/dev/null 2>&1; then

        log_message "HIGH" \
        "Netstat command is not installed" \
        "Install net-tools package"

        return
    fi

    # Detect listening TCP and UDP ports
    PORT_DATA=$(netstat -tuln 2>/dev/null | awk '
    NR > 2 && NF >= 4 {
        state = ($6 == "" ? "N/A" : $6)
        print $1, $4, state
    }')

    if [ -z "$PORT_DATA" ]; then

        echo "No listening network ports detected."

        log_message "INFO" \
        "No listening network ports detected" \
        "No action required"

        return
    fi

    echo "Listening Network Ports:"
    echo "$PORT_DATA"

    # Record every detected endpoint
    echo "$PORT_DATA" | while read PROTOCOL ADDRESS STATE
    do

        log_message "MEDIUM" \
        "Network endpoint detected: $PROTOCOL $ADDRESS ($STATE)" \
        "Review the service and restrict unnecessary network access"

    done
}


