#!/bin/bash

echo "Updating packages..."
sudo apt-get update -y

# 1. Install Python
echo "Installing Python..."
sudo apt-get install -y python3 python3-pip python3-venv

# 2. Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

# 3. Configure Billing Database
echo "Configuring Database..."
sudo -u postgres psql -c "CREATE DATABASE billing_db;"
sudo -u postgres psql -c "CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE billing_db TO myuser;"

# 4. Install RabbitMQ
echo "Installing RabbitMQ..."
sudo apt-get install -y rabbitmq-server

# 5. Enable and Start RabbitMQ
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

# 6. Enable the RabbitMQ Management Plugin (Optional but super helpful for debugging)
# This lets you see queues at http://192.168.56.12:15672
sudo rabbitmq-plugins enable rabbitmq_management

# 7. Create a RabbitMQ user (so Gateway can connect)
# Syntax: add_user <username> <password>
sudo rabbitmqctl add_user myuser mypassword
sudo rabbitmqctl set_user_tags myuser administrator
sudo rabbitmqctl set_permissions -p / myuser ".*" ".*" ".*"

echo "Billing Setup Complete!"