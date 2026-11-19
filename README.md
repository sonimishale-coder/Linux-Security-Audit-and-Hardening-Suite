
# Linux Security Audit and Hardening Automation Suite

## 1. Introduction

The Linux Security Audit and Hardening Automation Suite is a Bash-based tool developed to identify common security vulnerabilities and misconfigurations in Linux systems.

It performs automated security checks and provides options for automatic remediation.

## 2. Objectives

- Automate Linux security auditing.
- Identify common security issues.
- Detect insecure file permissions.
- Identify open network ports.
- Check SSH and password policies.
- Provide automatic security remediation.
- Generate audit logs and reports.

## 3. Technologies Used

- Operating System: CentOS 6.10
- Programming Language: Bash Shell Scripting
- Tools: AWK, SED, FIND, NETSTAT, STAT
- Virtualization: VMware Workstation

## 4. Security Checks

1. Password Policy Check
2. SSH Security Check
3. Open Port Detection
4. World-Writable File Detection
5. User Account Security Audit
6. Sensitive File Permission Check

## 5. Scan Profiles

### Basic Profile
Checks password policies and SSH configuration.

### Standard Profile
Includes Basic checks, open port detection and world-writable file detection.

### Full Profile
Performs all available security checks.

## 6. Automatic Remediation

The suite provides remediation options for selected security issues.

Features include:
- Disabling root SSH login.
- Correcting sensitive file permissions.
- Removing unnecessary world-write permissions when explicitly enabled.
- Creating backup copies before supported changes.

## 7. Project Structure

LinuxSecurityAuditSuite/
- security_audit.sh
- config.conf
- checks/
- logs/
- reports/
- README.md

## 8. How to Execute

Basic Scan:

./security_audit.sh --profile basic

Standard Scan:

./security_audit.sh --profile standard

Full Scan:

./security_audit.sh --profile full

Remediation Mode:

./security_audit.sh --profile full --remediate

Help:

./security_audit.sh --help

## 9. Configuration

The config.conf file contains customizable security policies, including:

- Minimum password length.
- Maximum password age.
- SSH root login policy.
- File permission settings.
- Remediation options.
- Default scan profile.

## 10. Logs and Reports

The logs directory stores timestamped security audit entries.

The reports directory stores generated security reports.

Each log entry includes:
- Timestamp
- Severity level
- Security issue
- Recommended remediation action

## 11. Safety Features

- Backup creation before supported remediation.
- Optional remediation mode.
- SSH configuration validation.
- Configurable remediation policies.
- Manual review of security findings.

## 12. Limitations

- Primarily designed for CentOS 6.10.
- Requires root privileges for certain checks and remediation.
- Detected open ports require manual security review.
- Password checks examine default password policies, not actual password strength.
- Some remediation actions depend on system configuration.

## 13. Conclusion

This project demonstrates how Bash scripting can automate Linux security auditing and hardening.

It helps reduce manual work, identify common security issues and improve system security through controlled remediation.

