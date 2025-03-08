#!/bin/bash

set -euo pipefail

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script needs to be run as root." 1>&2
   exit 1
fi

# Check if the script has execute permissions
if [ ! -x "$0" ]; then
    echo "The script does not have execution permissions. Adjusting necessary permissions."
    chmod +x "$0"
fi

# Welcome message and check for previous execution
if [ -f /opt/setup_completed ]; then
    read -rp "It appears the script has already been executed. Do you want to run it again? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Exiting the script."
        exit 0
    fi
fi

# Function to install a package if it's not already installed
install_if_not_exists() {
    if ! dpkg -s "$1" >/dev/null 2>&1; then
        echo "Installing $1..."
        sudo apt-get install -y "$1" || { echo "Failed to install $1"; exit 1; }
    else
        echo "$1 is already installed."
    fi
}

# System update
echo "Updating the system..."
sudo apt-get update && sudo apt-get upgrade -y

# Install dependencies
echo "Installing dependencies..."
dependencies=(libgbm-dev wget unzip fontconfig locales gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils git build-essential python3 python3-pip python3-venv)
for dep in "${dependencies[@]}"; do
    install_if_not_exists "$dep"
done

# Install and configure security tools
echo "Installing and configuring security tools..."
install_if_not_exists ufw
install_if_not_exists fail2ban

# Configure UFW firewall
echo "Configuring the firewall with UFW..."
sudo ufw allow OpenSSH
sudo ufw --force enable
sudo ufw status

# Configure Fail2Ban
echo "Configuring Fail2Ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Install and configure CSF (ConfigServer Security & Firewall)
echo "Installing and configuring CSF..."
if [ ! -d "/etc/csf" ]; then
    cd /usr/src
    wget https://download.configserver.com/csf.tgz
    tar -xzf csf.tgz
    cd csf
    sh install.sh
    cd ~
    rm -rf /usr/src/csf*
else
    echo "CSF is already installed."
fi

# Disable the default firewall if CSF is active
if [ -f "/etc/csf/csf.conf" ]; then
    echo "Disabling UFW in favor of CSF..."
    sudo ufw disable
fi

# Create a new admin user
read -rp "Do you want to create a new admin user? [y/N] " create_user
if [[ "$create_user" =~ ^[Yy]$ ]]; then
    read -rp "Enter the new username: " new_user
    adduser "$new_user"
    usermod -aG sudo "$new_user"
    echo "User $new_user created with admin permissions."
fi

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | bash
else
    echo "Docker is already installed."
fi
install_if_not_exists docker-compose

# Configure timezone
read -rp "Do you want to set the timezone manually? [y/N] " tz_choice
if [[ "$tz_choice" =~ ^[Yy]$ ]]; then
    read -rp "Please provide the timezone (e.g., Asia/Yangon): " timezone
    timedatectl set-timezone "$timezone"
else
    echo "Detecting and setting the timezone automatically..."
    detected_tz=$(timedatectl | grep "Time zone" | awk '{print $3}')
    echo "Detected timezone: $detected_tz"
    timedatectl set-timezone "$detected_tz"
fi

# Function to install database in Docker
install_database() {
    local db_name="$1"
    local container_name="$2"
    local port="$3"
    local password_var="$4"
    local extra_args="$5"

    read -rp "Would you like to install $db_name? [y/N] " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        echo "Installing $db_name in Docker..."
        read -rsp "Please provide a password for $db_name: " db_password
        echo
        read -rsp "Confirm the password for $db_name: " db_password_confirm
        echo

        if [ "$db_password" != "$db_password_confirm" ]; then
            echo "Passwords do not match for $db_name. Skipping installation."
            return
        fi

        docker run -e TZ="$timezone" --name "$container_name" -e "$password_var=$db_password" -p "$port:$port" -d --restart=always $extra_args "$db_name" || { echo "Failed to install $db_name"; return; }
        echo "$db_name installed successfully!"
        echo "$db_name connection details:"
        echo "  Host: localhost"
        echo "  Port: $port"
        echo "  Password: $db_password"
        echo
    fi
}

# Install databases
install_database "postgres:latest" "postgresql" "5432" "POSTGRES_PASSWORD" "-e POSTGRES_USER=postgres -v /data:/var/lib/postgresql/data"
install_database "redis:latest" "redis-server" "6379" "REDIS_PASSWORD" "--appendonly yes"
install_database "mysql:latest" "mysql-server" "3306" "MYSQL_ROOT_PASSWORD" "-v /data:/var/lib/mysql"

# Set up Python virtual environment for Flask app
# echo "Setting up Python virtual environment for Flask app..."
# read -rp "Enter the directory for your Flask app (e.g., /opt/my_flask_app): " flask_app_dir
# mkdir -p "$flask_app_dir"
# cd "$flask_app_dir"

# python3 -m venv venv
# source venv/bin/activate
# pip install --upgrade pip
# pip install Flask

# echo "Flask app environment set up at $flask_app_dir with a virtual environment named 'venv'."

# Mark the script as complete
touch /opt/setup_completed

echo "Setup complete. The script will not run again unless you manually remove /opt/setup_completed."
