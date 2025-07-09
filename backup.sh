#!/bin/bash

### === CONFIGURATION === ###
# You can edit these values or pass them as environment variables or script args
REPO_URL="https://github.com/anuragstark/yii2-devops-assessment.git"
PROJECT_NAME="yii2-devops-assessment"
CLONE_DIR="$HOME/$PROJECT_NAME"
BACKUP_DIR="$HOME/backups/$PROJECT_NAME"
WEBHOOK_URL="https://webhook.site/849ebcb6-ad91-4668-a14e-d59e601f15f3"
RCLONE_REMOTE="gdrive"  # your rclone remote name
RCLONE_FOLDER="/"
ENABLE_WEBHOOK=true

# Retention policy
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=3

# Logging
LOG_FILE="$HOME/backup_log.txt"

### FUNCTIONS  ###
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

create_backup() {
    log "Cloning repo..."
    rm -rf "$CLONE_DIR"
    git clone "$REPO_URL" "$CLONE_DIR" || {
        log "Failed to clone repo"
        exit 1
    }

    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_FILE="$BACKUP_DIR/${PROJECT_NAME}_$TIMESTAMP.zip"
    
    log "Creating ZIP backup..."
    zip -r "$BACKUP_FILE" "$CLONE_DIR" > /dev/null || {
        log "Failed to create ZIP"
        exit 1
    }
    log "Backup created: $BACKUP_FILE"
}

upload_backup() {
    log "Uploading to Google Drive using rclone..."
    rclone copy "$BACKUP_FILE" "$RCLONE_REMOTE:$RCLONE_FOLDER" || {
        log "Failed to upload backup to Google Drive"
        exit 1
    }
    log "Uploaded to Google Drive: $RCLONE_FOLDER"
}

rotate_backups() {
    log "Rotating backups..."
    cd "$BACKUP_DIR"
    
    # Daily backups
    ls -1t * | grep -E "daily" | tail -n +$((KEEP_DAILY + 1)) | xargs -r rm -f

    # Weekly backups (Sundays)
    ls -1t * | grep -E "weekly" | tail -n +$((KEEP_WEEKLY + 1)) | xargs -r rm -f

    # Monthly backups
    ls -1t * | grep -E "monthly" | tail -n +$((KEEP_MONTHLY + 1)) | xargs -r rm -f
    
    log "Rotation completed"
}

send_webhook() {
    if [ "$ENABLE_WEBHOOK" = true ]; then
        log "Sending webhook notification..."
        curl -s -X POST -H "Content-Type: application/json" \
             -d "{\"project\": \"$PROJECT_NAME\", \"date\": \"$TIMESTAMP\", \"test\": \"BackupSuccessful\"}" \
             "$WEBHOOK_URL"
        log "Webhook sent"
    fi
}

### MAIN ###
create_backup
upload_backup
rotate_backups
send_webhook
log "Backup process completed."

if [ $? -eq 0 ]; then
    echo " Backup completed successfully for project: $PROJECT_NAME on $(date)" \
    | s-nail -s " Backup Successful - $PROJECT_NAME" anuragchauhan536@gmail.com  
else
    echo " Backup failed for project: $PROJECT_NAME on $(date)" \
    | s-nail -s " Backup Failed - $PROJECT_NAME" anuragchauhan536@gmail.com 
fi

exit 0
