#!/bin/bash
sudo apt-get update
sudo apt-get install -y curl
sudo apt-get install -y unzip

curl -fsSL https://deno.land/install.sh | sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
nvm install node

node -v
deno -v
