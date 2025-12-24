#!/bin/bash

echo "Updating packages..."
sudo apt-get update -y

#Install Python
echo "Installing Python..."
sudo apt-get install -y python3 python3-pip python3-venv

echo "Gateway Setup Complete"