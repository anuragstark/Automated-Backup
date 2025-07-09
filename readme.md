#  Automated Backup and Rotation Script

A comprehensive bash script for automating GitHub repository backups with Google Drive integration, rotational retention policy, and multi-channel notifications.


## Features

-  **Automated Repository Cloning**: Clone any GitHub repository automatically
-  **ZIP Compression**: Create compressed backups for efficient storage
-  **Google Drive Integration**: Upload backups to Google Drive using rclone
-  **Rotational Backup Strategy**: Maintain daily, weekly, and monthly backups
-  **Email Notifications**: Get notified via email for backup status
-  **Webhook Support**: Send notifications to external services
-  **Comprehensive Logging**: Track all backup operations with timestamps
-  **Cron Job Ready**: Designed for automated scheduling

## Prerequisites

Before running this script, ensure you have the following installed:

```bash
# Required packages
sudo apt update
sudo apt install -y git zip curl rclone s-nail

# OR for CentOS/RHEL
sudo yum install -y git zip curl rclone s-nail
```

## Configuration

### 1. Script Configuration

Edit the configuration section at the top of the script:

```bash
#!/bin/bash
### === CONFIGURATION === ###
REPO_URL="https://github.com/yourusername/your-repo.git"
PROJECT_NAME="your-project-name"
CLONE_DIR="$HOME/$PROJECT_NAME"
BACKUP_DIR="$HOME/backups/$PROJECT_NAME"
WEBHOOK_URL="https://webhook.site/your-unique-url"
RCLONE_REMOTE="gdrive"  # your rclone remote name
RCLONE_FOLDER="/"
ENABLE_WEBHOOK=true

# Retention policy
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=3

# Logging
LOG_FILE="$HOME/backup_log.txt"
```

### 2. Google Drive Setup (rclone)

#### Step 1: Initialize rclone configuration
```bash
rclone config
```

#### Step 2: Configure Google Drive remote
Follow these prompts:

```
Storage> 22 (Google Drive)
client_id> (press Enter - use default)
client_secret> (press Enter - use default)
scope> 1 (Full access)
root_folder_id> (press Enter - leave blank)
service_account_file> (press Enter)
Edit advanced config? > n
Use auto config? > y (if local) or n (if remote server)
Configure this as a team drive? > n
```

#### Step 3: Verify configuration
```bash
rclone listremotes
# Should show: gdrive:
```

#### Step 4: Test connection
```bash
rclone ls gdrive:
```

### 3. Email Configuration (s-nail)

Create or edit `~/.mailrc`:

```bash
cat > ~/.mailrc << 'EOF'
set v15-compat
set mta="smtp://smtp.gmail.com:587"
set smtp-auth=login
set smtp-auth-user="your-email@gmail.com"
set smtp-auth-password="your-app-password"
set from="your-email@gmail.com"
set smtp-use-starttls
EOF
```

**Important**: Use App Password for Gmail, not your regular password!

#### Generate Gmail App Password:
1. Go to [Google Account Settings](https://myaccount.google.com/)
2. Security → 2-Step Verification → App passwords
3. Generate password for "Mail"
4. Use this password in the configuration

### 4. Webhook Configuration

For testing, use [webhook.site](https://webhook.site/):
1. Visit https://webhook.site/
2. Copy your unique URL
3. Update `WEBHOOK_URL` in the script

For production, replace with your actual webhook endpoint (Slack, Discord, etc.)

##  Usage

### Manual Execution

```bash
# Run the backup script
./backup.sh

# Run with custom parameters (if you modify the script to accept them)
REPO_URL="https://github.com/user/repo.git" ./backup.sh
```

### Automated Execution (Cron)

#### Setup daily backups at 2 AM:
```bash
crontab -e
```

Add this line:
```bash
0 2 * * * /bin/bash /path/to/backup.sh >> /home/user/cron_backup_log.txt 2>&1
```

#### Common cron schedules:
```bash
# Daily at 2 AM
0 2 * * * /bin/bash /path/to/backup.sh

# Every 6 hours
0 */6 * * * /bin/bash /path/to/backup.sh

# Weekly on Sunday at 3 AM
0 3 * * 0 /bin/bash /path/to/backup.sh

# Monthly on 1st at 4 AM
0 4 1 * * /bin/bash /path/to/backup.sh
```

#### Verify cron job:
```bash
crontab -l
```

## Backup Retention Policy

The script implements a **3-tier retention strategy**:

### Default Retention Settings
- **Daily**: Keep last 7 days
- **Weekly**: Keep last 4 weeks (Sundays)
- **Monthly**: Keep last 3 months

### How It Works

```bash
# Example with KEEP_DAILY=7, KEEP_WEEKLY=4, KEEP_MONTHLY=3

Day 1-7:     Keep all daily backups
Week 1-4:    Keep Sunday backups only
Month 1-3:   Keep first backup of each month
Older:       Delete automatically
```

### Customization

Modify retention periods in the script:
```bash
KEEP_DAILY=14    # Keep 14 daily backups
KEEP_WEEKLY=8    # Keep 8 weekly backups
KEEP_MONTHLY=6   # Keep 6 monthly backups
```

## Monitoring and Notifications

### Email Notifications

The script sends emails for:
- ✅ **Success**: Backup completed successfully
- ❌ **Failure**: Backup failed with error details

### Webhook Notifications

JSON payload sent to webhook URL:
```json
{
  "project": "your-project-name",
  "date": "2024-12-07_14-30-45",
  "test": "BackupSuccessful"
}
```

### Log Files

- **Main log**: `~/backup_log.txt`
- **Cron log**: `~/cron_backup_log.txt`

#### View recent logs:
```bash
tail -f ~/backup_log.txt
tail -f ~/cron_backup_log.txt
```

##  Troubleshooting

### Common Issues

#### 1. **rclone not found**
```bash
# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Or using package manager
sudo apt install rclone
```

#### 2. **Google Drive authentication failed**
```bash
# Reconfigure rclone
rclone config

# Test connection
rclone ls gdrive:
```

#### 3. **Email sending failed**
```bash
# Test email configuration
echo "Test message" | s-nail -s "Test Subject" your-email@gmail.com

# Check Gmail app password
# Ensure 2FA is enabled and app password is used
```

#### 4. **Permission denied**
```bash
# Make script executable
chmod +x backup.sh

# Check file permissions
ls -la backup.sh
```

### Debug Mode

Enable debug mode for detailed output:
```bash
# Add to top of script
set -x

# Or run with bash -x
bash -x backup.sh
```

### Log Analysis

Check logs for specific issues:
```bash
# Search for errors
grep -i "error\|failed\|exception" ~/backup_log.txt

# Check last 50 lines
tail -n 50 ~/backup_log.txt

# Monitor in real-time
tail -f ~/backup_log.txt
```


## Support

If you encounter any issues or have questions:

1. Review the logs for error messages
2. Open an issue on GitHub
3. Contact: [Anuragchauhan536@gmail.com](mailto:anuragchauhan536@gmail.com.com)

---
