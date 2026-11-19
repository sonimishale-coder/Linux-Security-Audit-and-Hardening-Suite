
#!/bin/bash

# ==========================================
# SSH Security Check and Remediation
# ==========================================

check_ssh_security() {

    echo ""
    echo "---- SSH Security Check ----"

    SSH_CONFIG="/etc/ssh/sshd_config"

    if [ ! -f "$SSH_CONFIG" ]; then
        log_message "HIGH" "SSH configuration file not found" \
        "Check OpenSSH server installation"
        return
    fi

    ROOT_LOGIN=$(awk '
    /^[[:space:]]*#/ {next}
    $1 == "PermitRootLogin" {
        value=$2
    }
    END {print value}
    ' "$SSH_CONFIG")

    if [ "$ROOT_LOGIN" = "no" ]; then

        echo "Root SSH Login: Disabled"

        log_message "INFO" "Root SSH login is disabled" \
        "No action required"

    else

        echo "Root SSH Login: Enabled or not explicitly disabled"

        log_message "HIGH" "Root SSH login is not explicitly disabled" \
        "Disable root SSH login"

        if [ "$REMEDIATION" = true ]; then

            if [ "$DISABLE_ROOT_LOGIN" != "true" ]; then
                log_message "WARNING" "SSH remediation blocked by policy" \
                "Enable DISABLE_ROOT_LOGIN in config.conf"
                return
            fi

            if [ "$(id -u)" -ne 0 ]; then
                log_message "HIGH" "SSH remediation requires root" \
                "Run the script as root"
                return
            fi

            BACKUP_PATH=$(backup_file "$SSH_CONFIG")

            if [ -z "$BACKUP_PATH" ]; then
                log_message "HIGH" "SSH backup failed" \
                "No changes were made"
                return
            fi

            sed -i '/^[[:space:]]*PermitRootLogin[[:space:]]/d' "$SSH_CONFIG"

            sed -i '1iPermitRootLogin no' "$SSH_CONFIG"

            if sshd -t -f "$SSH_CONFIG"; then

                if service sshd reload; then
                    SSH_RELOADED=true
                elif service sshd restart; then
                    SSH_RELOADED=true
                else
                    SSH_RELOADED=false
                fi

                if [ "$SSH_RELOADED" = true ]; then
                    log_message "INFO" \
                    "Root SSH login successfully disabled" \
                    "Backup saved at $BACKUP_PATH"
                else
                    cp -p "$BACKUP_PATH" "$SSH_CONFIG"
                    service sshd restart

                    log_message "HIGH" \
                    "SSH reload failed; original configuration restored" \
                    "Review SSH service status"
                fi

            else

                cp -p "$BACKUP_PATH" "$SSH_CONFIG"

                log_message "HIGH" \
                "Invalid SSH configuration; original file restored" \
                "Review SSH configuration manually"

            fi

        fi
    fi
}
