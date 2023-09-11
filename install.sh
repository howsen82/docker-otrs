sudo apt update
sudo apt install -y postgresql apache2 zip unzip build-essential bash-completion libapache2-mod-perl2 libdbd-pg-perl libtimedate-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl libdigest-md5-perl libcrypt-ssleay-perl libdatetime-perl libauthen-ntlm-perl libpdf-api2-simple-perl libgd-text-perl libgd-graph-perl libyaml-libyaml-perl libmoo-perl apt-transport-https certbot python3-certbot-apache
sudo su - postgres
psql
CREATE USER otrsdbuser WITH PASSWORD 'dktLkE(UvUWupy3Y7d((9b';
CREATE DATABASE "otrsdb" WITH OWNER "otrsdbuser" ENCODING 'UTF8';
\q
exit

wget https://github.com/OTRS/otrs/archive/refs/heads/rel-6_0.zip
unzip rel-6_0.zip
sudo rm -f rel-6_0.zip
sudo mv otrs-* /opt/otrs
sudo useradd -d /opt/otrs -c 'OTRS user' otrs
sudo usermod -G www-data otrs
sudo cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm
sudo vim /opt/otrs/Kernel/Config.pm
sudo vim /opt/otrs/scripts/apache2-perl-startup.pl

sudo chown -R otrs:otrs /opt/otrs
sudo /opt/otrs/bin/otrs.CheckModules.pl
sudo perl -cw /opt/otrs/bin/cgi-bin/index.pl
sudo perl -cw /opt/otrs/bin/cgi-bin/customer.pl
sudo perl -cw /opt/otrs/bin/otrs.Console.pl
sudo a2enmod headers
sudo a2enmod rewrite
sudo a2enmod perl
sudo a2enmod deflate
sudo a2enmod filter
sudo vim /etc/apache2/sites-available/otrs.heyvaldemar.net.conf
sudo vim /etc/apache2/sites-available/otrs.heyvaldemar.net-ssl.conf
sudo vim /etc/apache2/sites-available/support.heyvaldemar.net.conf
sudo vim /etc/apache2/sites-available/support.heyvaldemar.net-ssl.conf
cd /opt/otrs
sudo bin/otrs.SetPermissions.pl --otrs-user=www-data --web-group=www-data
sudo a2ensite otrs.heyvaldemar.net.conf
sudo a2ensite otrs.heyvaldemar.net-ssl.conf
sudo a2ensite support.heyvaldemar.net.conf
sudo a2ensite support.heyvaldemar.net-ssl.conf
sudo ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/zzz_otrs.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl restart apache2
sudo systemctl status apache2
sudo certbot --apache -d otrs.heyvaldemar.net -d support.heyvaldemar.net
sudo certbot renew --dry-run
sudo su - otrs -c "/opt/otrs/bin/otrs.Daemon.pl start"
cd /opt/otrs/var/cron
sudo cp aaa_base.dist aaa_base
sudo cp otrs_daemon.dist otrs_daemon
sudo su - otrs -c "/opt/otrs/bin/Cron.sh start"
