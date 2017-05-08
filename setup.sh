#!/usr/bin/env bash

echo ">>> Instalando Servidor Apache"

PASSWORD='123'

# Atualizando o Sistema
sudo apt-get update

# Instalando Curl
sudo apt-get install -y curl
# Instalando Apache
# -qq implies -y --force-yes
sudo apt-get install -y apache2

echo ">>> Configurando Apache"

# Apache Config
sudo a2enmod rewrite actions ssl

sudo echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
 
sudo a2enconf fqdn
 
sudo service apache2 restart


echo ">>> Instalando PHP"

export LANG=C.UTF-8


	sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:ondrej/php


	sudo apt-get -y update
	sudo apt-get -y upgrade

    # Instalando PHP
    # -qq implies -y --force-yes
    sudo apt-get install -y php5.6 libapache2-mod-php5.6 php5.6-curl php5.6-gd php5.6-mcrypt  php5.6-mysql php5.6-xdebug  php5.6-mbstring --assume-yes --force-yes 

	sudo apt-get install -y php5.6-xml
	
	apt-get -y autoremove
	
	sudo apt-get install -y php-gettext
		
	sudo a2enmod php5.6

    # xdebug Config
    cat > $(find /etc/php5 -name xdebug.ini) << EOF
zend_extension=$(find /usr/lib/php5 -name xdebug.so)
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1

; var_dump display
xdebug.var_display_max_depth = 5
xdebug.var_display_max_children = 256
xdebug.var_display_max_data = 1024
EOF

    # PHP Error Reporting Config
    sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
    sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini    
	
	sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/5.6/apache2/php.ini
    sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/5.6/apache2/php.ini

    # PHP Date Timezone
    sudo sed -i "s/;date.timezone =.*/date.timezone = America\/\Sao_Paulo/" /etc/php5/apache2/php.ini
    sudo sed -i "s/;date.timezone =.*/date.timezone = America\/\Sao_Paulo/" /etc/php5/apache2/php.ini
	
	# PHP Date Timezone
    sudo sed -i "s/;date.timezone =.*/date.timezone = America\/\Sao_Paulo/" /etc/php/5.6/apache2/php.ini
    sudo sed -i "s/;date.timezone =.*/date.timezone = America\/\Sao_Paulo/" /etc/php/5.6/apache2/php.ini

echo ">>> Instalando MariaDB"

# default version
MARIADB_VERSION='10.1'

sudo apt-get -qq install python-software-properties
# Import repo key
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

# Add repo for MariaDB
sudo add-apt-repository "deb [arch=amd64,i386] http://mirrors.accretive-networks.net/mariadb/repo/$MARIADB_VERSION/ubuntu trusty main"

# Update
sudo apt-get update

# Install MariaDB without password prompt
# Set username to 'root' and password to 'mariadb_root_password' (see Vagrantfile)
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password $PASSWORD"

# Install MariaDB
# -qq implies -y --force-yes
sudo apt-get install -qq mariadb-server

#phpMyAdmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get install -y phpmyadmin

# Make Maria connectable from outside world without SSH tunnel

    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
    MYSQL=`which mysql`

    Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$PASSWORD' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    $MYSQL -uroot -p$PASSWORD -e "$SQL"

    service mysql restart


sudo pecl install xdebug

sudo a2dismod php5
sudo a2enmod rewrite

sudo apt-get -y update
sudo apt-get -y upgrade

echo ">>> Installing *.dev self-signed SSL"

SSL_DIR="/etc/apache2/ssl/"
DOMAIN="localhost"
PASSPHRASE="alexnascimento"

SUBJ="
C=US
ST=Connecticut
O=Alex Nascimento
localityName=New Haven
commonName=$DOMAIN
organizationalUnitName=
emailAddress=
"

sudo mkdir -p "$SSL_DIR"

sudo openssl genrsa -out "$SSL_DIR/localhost.key" 1024
sudo openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/localhost.key" -out "$SSL_DIR/localhost.csr" -passin pass:$PASSPHRASE
sudo openssl x509 -req -days 1825 -in "$SSL_DIR/localhost.csr" -signkey "$SSL_DIR/localhost.key" -out "$SSL_DIR/localhost.crt" -sha256 -extfile "$SSL_DIR/v3.ext"
sudo cp "$SSL_DIR/localhost.crt" "$SSL_DIR/localhost.pem"

echo "<VirtualHost *:443>" >> /etc/apache2/sites-enabled/000-default.conf
echo "ServerAdmin webmaster@localhost" >> /etc/apache2/sites-enabled/000-default.conf
echo "DocumentRoot /var/www" >> /etc/apache2/sites-enabled/000-default.conf
echo "<Directory />" >> /etc/apache2/sites-enabled/000-default.conf
echo "Options FollowSymLinks" >> /etc/apache2/sites-enabled/000-default.conf
echo "AllowOverride All" >> /etc/apache2/sites-enabled/000-default.conf
echo "</Directory>" >> /etc/apache2/sites-enabled/000-default.conf
echo "<Directory /var/www/>" >> /etc/apache2/sites-enabled/000-default.conf
echo "Options Indexes FollowSymLinks MultiViews" >> /etc/apache2/sites-enabled/000-default.conf
    echo "AllowOverride All" >> /etc/apache2/sites-enabled/000-default.conf
    echo "Order allow,deny" >> /etc/apache2/sites-enabled/000-default.conf
    echo "Allow from all" >> /etc/apache2/sites-enabled/000-default.conf
  echo "</Directory>" >> /etc/apache2/sites-enabled/000-default.conf
  echo "ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/" >> /etc/apache2/sites-enabled/000-default.conf
  echo "<Directory "/usr/lib/cgi-bin">" >> /etc/apache2/sites-enabled/000-default.conf
    echo "AllowOverride None" >> /etc/apache2/sites-enabled/000-default.conf
    echo "Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/apache2/sites-enabled/000-default.conf
    echo "Order allow,deny" >> /etc/apache2/sites-enabled/000-default.conf
    echo "Allow from all" >> /etc/apache2/sites-enabled/000-default.conf
  echo "</Directory>" >> /etc/apache2/sites-enabled/000-default.conf
  echo "SSLEngine on" >> /etc/apache2/sites-enabled/000-default.conf
  echo "SSLCertificateFile /etc/apache2/ssl/localhost.pem" >> /etc/apache2/sites-enabled/000-default.conf
  echo "SSLCertificateKeyFile /etc/apache2/ssl/localhost.key" >> /etc/apache2/sites-enabled/000-default.conf
  echo "ErrorLog ${APACHE_LOG_DIR}/error.log" >> /etc/apache2/sites-enabled/000-default.conf
  echo "# Possible values include: debug, info, notice, warn, error, crit," >> /etc/apache2/sites-enabled/000-default.conf
  echo "# alert, emerg." >> /etc/apache2/sites-enabled/000-default.conf
  echo "LogLevel warn" >> /etc/apache2/sites-enabled/000-default.conf
  echo "CustomLog ${APACHE_LOG_DIR}/access.log combined" >> /etc/apache2/sites-enabled/000-default.conf
echo "</VirtualHost>" >> /etc/apache2/sites-enabled/000-default.conf


echo "Adicionando Vhost Dinamicos"

sudo a2enmod vhost_alias

echo "<Virtualhost *:80>" >> /etc/apache2/apache2.conf
    echo 'VirtualDocumentRoot "/var/www/vhosts/%1"' >> /etc/apache2/apache2.conf
    echo "ServerName vhosts.dev" >> /etc/apache2/apache2.conf 
    echo "ServerAlias *.dev" >> /etc/apache2/apache2.conf 
    echo "UseCanonicalName Off" >> /etc/apache2/apache2.conf 
    echo '<Directory "/var/www/vhosts/*"> ' >> /etc/apache2/apache2.conf 
        echo "Options Indexes FollowSymLinks MultiViews" >> /etc/apache2/apache2.conf 
        echo "AllowOverride All" >> /etc/apache2/apache2.conf
        echo "Order allow,deny" >> /etc/apache2/apache2.conf 
        echo "Allow from all" >> /etc/apache2/apache2.conf 
    echo "</Directory>" >> /etc/apache2/apache2.conf 
echo "</Virtualhost>" >> /etc/apache2/apache2.conf 

sudo service apache2 restart

sudo sed -i "s/exit 0*/sleep 5/" /etc/rc.local
echo "sudo /etc/init.d/apache2 restart" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

echo "apachectl start" >> /etc/profile
