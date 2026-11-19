
#!/bin/bash

# ==========================================
# File Permission Audit and Remediation
# ==========================================

check_world_writable() {

    echo ""
    echo "---- World-Writable File Detection ----"

    WORLD_FILES=$(find / \
        \( -path /proc -o -path /sys -o -path /dev \
        -o -path /run -o -path /tmp -o -path /var/tmp \
        \) -prune -o -type f -perm -0002 -print 2>/dev/null)

    if [ -z "$WORLD_FILES" ]; then

        echo "No world-writable files found."

        log_message "INFO" \
        "No world-writable files detected" \
        "No action required"

        return
    fi

    echo "World-writable files found:"
    echo "$WORLD_FILES"

    while IFS= read -r FILE
    do

        log_message "HIGH" \
        "World-writable file detected: $FILE" \
        "Remove unnecessary world-write permission"

        if [ "$REMEDIATION" = true ] && \
           [ "$REMEDIATE_WORLD_WRITABLE" = "true" ]; then

            BACKUP_PATH=$(backup_file "$FILE")

            if [ -n "$BACKUP_PATH" ]; then

                if chmod o-w "$FILE"; then

                    log_message "INFO" \
                    "World-write permission removed: $FILE" \
                    "Backup saved at $BACKUP_PATH"

                else

                    log_message "HIGH" \
                    "Permission correction failed: $FILE" \
                    "Check file permissions manually"

                fi

            else

                log_message "HIGH" \
                "Backup failed for $FILE" \
                "File was not modified"

            fi

        fi

    done <<< "$WORLD_FILES"
}


# ==========================================
# Sensitive File Permission Check
# ==========================================

check_sensitive_permissions() {

    echo ""
    echo "---- Sensitive File Permission Check ----"

    for FILE in /etc/passwd /etc/shadow /etc/ssh/sshd_config
    do

        [ -f "$FILE" ] || continue

        PERMISSIONS=$(stat -c "%a" "$FILE" 2>/dev/null)

        echo "$FILE : $PERMISSIONS"

        EXPECTED=""
        VALID=false

        case "$FILE" in

            /etc/passwd)
                EXPECTED="644"
                [ "$PERMISSIONS" = "644" ] && VALID=true
                ;;

            /etc/shadow)
   		 EXPECTED="000"
   		 [ "$PERMISSIONS" = "0" ] || [ "$PERMISSIONS" = "000" ]
   		 [ "$?" -eq 0 ] && VALID=true
   		 ;;

            /etc/ssh/sshd_config)
                EXPECTED="600"
                [ "$PERMISSIONS" = "600" ] && VALID=true
                ;;

        esac

        if [ "$VALID" = true ]; then

            log_message "INFO" \
            "Secure permissions on $FILE: $PERMISSIONS" \
            "No action required"

        else

            log_message "HIGH" \
            "Unexpected permissions on $FILE: $PERMISSIONS" \
            "Set permissions to $EXPECTED after review"

            if [ "$REMEDIATION" = true ] && \
               [ "$REMEDIATE_SENSITIVE_PERMISSIONS" = "true" ]; then

                if [ "$(id -u)" -ne 0 ]; then

                    log_message "HIGH" \
                    "Permission remediation requires root" \
                    "Run the script as root"

                    continue
                fi

                BACKUP_PATH=$(backup_file "$FILE")

                if [ -n "$BACKUP_PATH" ]; then

                    if chmod "$EXPECTED" "$FILE"; then

                        log_message "INFO" \
                        "Permissions corrected on $FILE" \
                        "Backup saved at $BACKUP_PATH"

                    else

                        log_message "HIGH" \
                        "Permission correction failed on $FILE" \
                        "Restore backup and review manually"

                    fi

                else

                    log_message "HIGH" \
                    "Backup failed for $FILE" \
                    "File was not modified"

                fi

            fi
        fi

    done
}

