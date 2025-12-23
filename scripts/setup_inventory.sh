#!/bin/bash

#1. Update the package list (Standard first step)
echo "Updating packages"
sudo apt-get update -y

#2. Install Python and Pip (Package Manager)
echo "Installing python"
sudo apt-get install -y python3 python3-pip python3-venv

#3.Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

#4. Start the Postgres Service
sudo systemctl start postgresql
sudo systemctl enable postgresql

#5. Create the Database and the User
# We use 'sudo -u postgres psql' to run SQL commands as the superuser

echo "Configuring Database..."
sudo -u postgres psql -c "CREATE DATABASE movies_db;"
sudo -u postgres psql -c "CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE movies_db TO myuser;"

echo "Inventory Setup Complete!"


