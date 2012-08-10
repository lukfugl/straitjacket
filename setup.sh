# tested on a VirtualBox i386 Ubuntu Precise VM. run as root
cd .. # out of straitjacket checkout

# install dependencies
aptitude install apache2-mpm-itk gcc mono-gmcs g++ guile-1.8 ghc lua5.1 ocaml \
                 php5 python ruby ruby1.9.3 scala racket golang openjdk-6-jdk \
                 python-pip gcc-multilib xdg-utils nodejs npm make \
                 python-webpy python-libapparmor apparmor libapache2-mod-wsgi
wget http://ftp.digitalmars.com/dmd_2.060-0_i386.deb
dpkg -i dmd_2.060-0_i386.deb
rm dmd_2.060-0_i386.deb

# setup and relocate
adduser straitjacket
mkdir -p /var/webapps /var/local/straitjacket/lib /var/local/straitjacket/tmp
chown -R straitjacket:straitjacket /var/local/straitjacket straitjacket
mv straitjacket /var/webapps/straitjacket
cd /var/webapps/straitjacket/src && make
cd /var/webapps/straitjacket

# put configurations in place
mv src/getpwuid_r_hijack.so /var/local/straitjacket/lib/
cp -r files/etc/apparmor.d/* /etc/apparmor.d/
/etc/init.d/apparmor reload
cp files/etc/apache2/sites-available/straitjacket \
   /etc/apache2/sites-available/straitjacket
ln -s /etc/apache2/sites-available/straitjacket /etc/apache2/sites-enabled
rm /etc/apache2/sites-enabled/000-default
mkdir -p static
/etc/init.d/apache2 restart

# test the setup
git checkout testing
python server_tests.py
python remote_server_tests.py http://localhost/

# done
git checkout master
