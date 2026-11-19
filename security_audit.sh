
#!/bin/bash

# ==========================================
# Linux Security Audit and Hardening Suite
# Main Script
# Compatible with CentOS 6.10
# ==========================================

# Project directory
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASE_DIR"

# Load configuration
if [ -f "$BASE_DIR/config.conf" ]; then
    source "$BASE_DIR/config.conf"
else
    echo "ERROR: config.conf not found!"
    exit 1
fi

# Default settings
PROFILE="${DEFAULT_PROFILE:-standard}"
REMEDIATION=false

# Create required directories
mkdir -p "$BASE_DIR/logs"
mkdir -p "$BASE_DIR/reports"

LOG_FILE="$BASE_DIR/$LOG_FILE"

# Create log file if it does not exist
touch "$LOG_FILE"

# Record starting log line
START_LINE=$(wc -l < "$LOG_FILE")

log_message() {
    LEVEL="$1"
    MESSAGE="$2"
    ACTION="$3"

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    ENTRY="[$TIMESTAMP] [$LEVEL] $MESSAGE | Action: $ACTION"

    echo "$ENTRY" | tee -a "$LOG_FILE"
}

# Create timestamped backup before modifying files
backup_file() {

    FILE="$1"

    if [ ! -f "$FILE" ]; then
        return 1
    fi

    BACKUP="${FILE}.backup.$(date +%Y%m%d_%H%M%S)"

    if cp -p "$FILE" "$BACKUP"; then
        echo "$BACKUP"
        return 0
    else
        return 1
    fi
}


# Display usage
usage() {
    echo "Linux Security Audit and Hardening Suite"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --profile PROFILE   Select scan profile"
    echo "  -r, --remediate         Enable remediation mode"
    echo "  -h, --help              Display help"
    echo ""
    echo "Profiles:"
    echo "  basic"
    echo "  standard"
    echo "  full"
}

# Read command-line arguments
while [ $# -gt 0 ]
do
    case "$1" in
        -p|--profile)
            if [ -z "$2" ]; then
                echo "ERROR: Profile name required."
                exit 1
            fi
            PROFILE="$2"
            shift 2
            ;;
        -r|--remediate)
            REMEDIATION=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate scan profile
case "$PROFILE" in
    basic|standard|full)
        ;;
    *)
        echo "ERROR: Invalid scan profile: $PROFILE"
        usage
        exit 1
        ;;
esac

# Check root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "WARNING: Some security checks require root privileges."
fi

# Audit starting message
echo ""
echo "======================================"
echo " LINUX SECURITY AUDIT SUITE"
echo "======================================"
echo "Scan Profile : $PROFILE"
echo "Remediation  : $REMEDIATION"
echo "Started      : $(date)"
echo "======================================"

log_message "INFO" "Security audit started with profile $PROFILE" "Audit initialized"

# Load security check modules
MODULES=(
    "password_check.sh"
    "ssh_check.sh"
    "port_check.sh"
    "permission_check.sh"
    "user_check.sh"
)

for MODULE in "${MODULES[@]}"
do
    if [ -f "$BASE_DIR/checks/$MODULE" ]; then
        source "$BASE_DIR/checks/$MODULE"
    fi
done

# Execute security checks
run_check() {
    CHECK_FUNCTION="$1"

    if type "$CHECK_FUNCTION" >/dev/null 2>&1; then
        "$CHECK_FUNCTION"
    else
        log_message "WARNING" "$CHECK_FUNCTION module not available yet" "Create the required check module"
    fi
}

echo ""
echo "Starting security checks..."

# Basic profile
run_check check_password_policy
run_check check_ssh_security

# Standard profile
if [ "$PROFILE" = "standard" ] || [ "$PROFILE" = "full" ]; then
    run_check check_open_ports
    run_check check_world_writable
fi

# Full profile
if [ "$PROFILE" = "full" ]; then
    run_check check_user_accounts
    run_check check_sensitive_permissions
fi

# Audit completion
echo ""
echo "======================================"
echo " SECURITY AUDIT COMPLETED"
echo "======================================"


log_message "INFO" "Security audit completed" "Review the generated audit log"

# Generate individual security report
REPORT_FILE="$BASE_DIR/$REPORT_DIR/security_report_$(date +%Y%m%d_%H%M%S).txt"

tail -n +"$((START_LINE + 1))" "$LOG_FILE" > "$REPORT_FILE"

echo ""
echo "Security Report Generated Successfully!"
echo "Log File: $LOG_FILE"
echo "Report File: $REPORT_FILE"

echo "======================================"

