# -*- mode: ruby -*-
# # vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
servers = YAML.load_file('servers_config.yaml')

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # Iterate through entries in YAML file
    servers.each do |servers|
        config.vm.define servers["name"] do |srv|
            srv.vm.box = servers["box"]
            srv.vm.hostname = servers["name"]
            if servers["network_type"] == "private"
                srv.vm.network "private_network", ip: servers["ip"]
            elsif servers["network_type"] == "public_dynamic"
                srv.vm.network "public_network"
            else
                srv.vm.network "public_network", ip: servers["ip"]
            end

            srv.vm.provider :virtualbox do |vb|
                vb.name = servers["name"]
                vb.memory = servers["ram"]
                vb.cpus = servers["cpu"]
            end

            srv.vm.provision :"shell", path: "./scripts/install-docker.sh"
            srv.vm.provision :"shell", path: "./scripts/install-kubectl.sh"
            srv.vm.provision :"shell", path: "./scripts/install-trivy.sh"
            srv.vm.provision :"shell", path: "./scripts/install-kube-hunter.sh"
            srv.vm.provision :"shell", path: "./scripts/install-tracee-prerequisites.sh"
        end
    end
end

