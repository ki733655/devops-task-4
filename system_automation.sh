#!/bin/bash
# --------------------------------------------------
# Script Name : system_automation.sh
# Author      : Khairul Islam
# Description : 
#   - Prints system information
#   - Uses variables, conditionals, and loops
#   - Automates log backup & cleanup
#   - Redirects output to files
# --------------------------------------------------

# ---------- VARIABLES ----------
LOG_DIR="/var/log"
BACKUP_DIR="$HOME/log_backup"
DATE=$(date +"%Y-%m-%d")
REPORT_FILE="$HOME/system_report_$DATE.txt"

# ---------- CREATE BACKUP DIRECTORY IF NOT EXISTS ----------
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# ---------- SYSTEM INFORMATION ----------
echo "System Information Report - $DATE" > "$REPORT_FILE"
echo "---------------------------------" >> "$REPORT_FILE"

echo "Hostname      : $(hostname)" >> "$REPORT_FILE"
echo "OS Info       : $(uname -a)" >> "$REPORT_FILE"
echo "Uptime        : $(uptime -p)" >> "$REPORT_FILE"
echo "CPU Info      : $(lscpu | grep 'Model name' | awk -F: '{print $2}')" >> "$REPORT_FILE"
echo "Memory Usage  :" >> "$REPORT_FILE"
free -h >> "$REPORT_FILE"

# ---------- DISK USAGE CHECK (CONDITIONAL) ----------
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "⚠ WARNING: Disk usage is above 80% ($DISK_USAGE%)" >> "$REPORT_FILE"
else
    echo "✅ Disk usage is normal ($DISK_USAGE%)" >> "$REPORT_FILE"
fi

# ---------- BACKUP & CLEANUP LOG FILES (LOOP) ----------
echo "" >> "$REPORT_FILE"
echo "Backing up log files..." >> "$REPORT_FILE"

for file in $LOG_DIR/*.log; do
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR"
        echo "Backed up: $(basename "$file")" >> "$REPORT_FILE"
    fi
done

# ---------- DELETE LOG FILES OLDER THAN 7 DAYS ----------
find "$BACKUP_DIR" -type f -mtime +7 -exec rm {} \;

echo "" >> "$REPORT_FILE"
echo "Old backups (older than 7 days) removed." >> "$REPORT_FILE"

# ---------- SCRIPT COMPLETION ----------
echo "Script executed successfully at $(date)" >> "$REPORT_FILE"

