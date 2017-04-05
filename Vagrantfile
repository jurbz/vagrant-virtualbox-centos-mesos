#Shell script to install puppet agent
$puppet = <<SCRIPT
sudo yum install -y epel-release && sudo yum install -y puppet
SCRIPT

$masterip = "10.0.0.101" # Master's IP address
$agentip = "10.0.0.201" # Agent's IP address

# Select Vagrant Box 
BOX = "centos/7"

Vagrant.configure("2") do |config|

config.vm.provision "shell", inline: $puppet

# Master VM setup
  config.vm.define "master" do |subconfig|
    subconfig.vm.box = BOX
    subconfig.vm.hostname = "master"
    subconfig.vm.network :private_network, ip: $masterip
    subconfig.vm.provision :puppet do |puppet|
      puppet.facter = {
      "mesos" => "master",
      "masterip" => $masterip
      }
    end
  end

# Agent VM setup
  config.vm.define "agent" do |subconfig|
    subconfig.vm.box = BOX
    subconfig.vm.hostname = "agent"
    subconfig.vm.network :private_network, ip: $agentip
    subconfig.vm.provision :puppet do |puppet|
      puppet.facter = {
      "mesos" => "agent",
      "agentip" => $agentip
      }
    end
  end

end
