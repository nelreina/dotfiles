#!/bin/bash

# Caddy Installation Script for Ubuntu
# Created for a Curaçao-based system developer

# Text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Caddy Web Server Installation Script ===${NC}"
echo "This script will install Caddy on your Ubuntu system."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

echo -e "\n${GREEN}Step 1: Installing dependencies...${NC}"
apt update
apt install -y gnupg curl apt-transport-https debian-keyring debian-archive-keyring

echo -e "\n${GREEN}Step 2: Adding Caddy GPG key...${NC}"
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

echo -e "\n${GREEN}Step 3: Adding Caddy repository...${NC}"
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list

echo -e "\n${GREEN}Step 4: Updating package index...${NC}"
apt update

echo -e "\n${GREEN}Step 5: Installing Caddy...${NC}"
apt install caddy -y

echo -e "\n${GREEN}Step 6: Starting Caddy service...${NC}"
systemctl enable caddy
systemctl start caddy

echo -e "\n${GREEN}Step 7: Configuring firewall (if UFW is active)...${NC}"
if command -v ufw &>/dev/null && ufw status | grep -q "active"; then
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw reload
  echo "Firewall configured to allow HTTP and HTTPS traffic."
else
  echo "UFW not active or not installed. Skipping firewall configuration."
fi

# Verify installation
CADDY_VERSION=$(caddy version)
echo -e "\n${GREEN}Caddy installed successfully!${NC}"
echo -e "Version: ${BLUE}$CADDY_VERSION${NC}"
echo -e "Status: $(systemctl is-active caddy)"

# Get server IP for testing
SERVER_IP=$(hostname -I | awk '{print $1}')
echo -e "\n${GREEN}Testing Instructions:${NC}"
echo -e "1. Access Caddy at: ${BLUE}http://$SERVER_IP${NC}"
echo -e "2. Default config file: ${BLUE}/etc/caddy/Caddyfile${NC}"
echo -e "3. Control Caddy with: ${BLUE}systemctl [start|stop|restart|status] caddy${NC}"

echo -e "\n${GREEN}Installation complete!${NC}"
