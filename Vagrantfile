# Vagrantfile
Vagrant.configure("2") do |config|
  
  # 1. GATEWAY VM
  # This serves the API to the outside world
  config.vm.define "gateway-vm" do |gateway|
    gateway.vm.box = "ubuntu/focal64"           # The OS Image (Ubuntu 20.04)
    gateway.vm.hostname = "gateway-vm"
    gateway.vm.network "private_network", ip: "192.168.56.10"
    
    # Forward port 8080 so you can access it at http://localhost:8080 on your laptop
    gateway.vm.network "forwarded_port", guest: 8080, host: 8080
    
    # Sync your code folder to the VM
    gateway.vm.synced_folder "./srcs/api-gateway", "/app"
    gateway.vm.synced_folder "./scripts", "/scripts"

    # Give it some RAM
    gateway.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
    end
  end

  # 2. INVENTORY VM
  # This holds the Movies DB and API
  config.vm.define "inventory-vm" do |inventory|
    inventory.vm.box = "ubuntu/focal64"
    inventory.vm.hostname = "inventory-vm"
    inventory.vm.network "private_network", ip: "192.168.56.11"
    
    # Sync folders
    inventory.vm.synced_folder "./srcs/inventory-app", "/app"
    inventory.vm.synced_folder "./scripts", "/scripts"

    # Needs more RAM for Postgres
    inventory.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
  end

  # 3. BILLING VM
  # This holds RabbitMQ and Billing DB
  config.vm.define "billing-vm" do |billing|
    billing.vm.box = "ubuntu/focal64"
    billing.vm.hostname = "billing-vm"
    billing.vm.network "private_network", ip: "192.168.56.12"
    
    # Sync folders
    billing.vm.synced_folder "./srcs/billing-app", "/app"
    billing.vm.synced_folder "./scripts", "/scripts"

    # Needs RAM for RabbitMQ + Postgres
    billing.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
  end
  
end