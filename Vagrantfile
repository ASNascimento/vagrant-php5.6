# Configurações do Servidor 

hostname        = "localhost"

# Definir um endereço IP de rede local
# Você pode usar os seguintes intervalos de IP:
#   10.0.0.1    - 10.255.255.254
#   172.16.0.1  - 172.31.255.254
#   192.168.0.1 - 192.168.255.254
server_ip             = "192.168.22.10"
server_cpus           = "1"   # Cores
server_memory         = "512" # MB
server_swap           = "1024" # Opções: false | Int (MB) - Entre uma ou duas vezes mais que server_memory

server_timezone  = "America/Sao_Paulo"

# Configurações Banco de Dados

mysql_root_password   = "root"   # Vamos colocar usuario como "root"
mysql_enable_remote   = "false"  # Para ativar acesso remoto coloque como TRUE


# Configurações do PHP
php_timezone          = "America/Sao_Paulo"    	# http://php.net/manual/en/timezones.php
php_version           = "5.6"    				# Opções: 5.5 | 5.6

Vagrant.configure("2") do |config|

	# Vamos utilizar o servidor Ubuntu 14.04
    config.vm.box = "ubuntu/trusty64"
	
	config.vm.network :private_network, ip: server_ip
    config.vm.network :forwarded_port, guest: 80, host: 80
	config.vm.network :forwarded_port, guest: 443, host: 443
	config.vm.network :forwarded_port, guest: 3306, host: 3306
	
	config.ssh.forward_agent = true
	
	config.vm.synced_folder "www/", "/var/www", mount_options: ['dmode=777','fmode=666']
    config.vm.synced_folder "ssl/", "/etc/apache2/ssl", mount_options: ['dmode=777','fmode=666']
	
	config.vm.synced_folder "~", "/vagrant", owner: "vagrant", group: "vagrant"
	
	config.vm.provider "virtualbox" do |machine|
    	machine.memory = server_memory
    	machine.name = "server-php"
    end
    config.vm.provision :shell, path: "setup.sh"
end

