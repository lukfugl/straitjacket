# tested on a VirtualBox i386 Ubuntu Precise VM. run as root
checkout=$0 # pathname portion only

# install dependencies
aptitude install apache2-mpm-itk gcc mono-gmcs g++ guile-1.8 ghc lua5.1 ocaml \
                 php5 python ruby ruby1.9 scala racket golang openjdk-6-jdk \
                 python-pip
add-apt-repository ppa:chris-lea/node.js
aptitude update && aptitude install nodejs npm
wget http://ftp.digitalmars.com/dmd_2.060-0_i386.deb
dpkg -i dmd_2.060-0_i386.deb
rm dmd_2.060-0_i386.deb

# setup and relocate
adduser straitjacket
mkdir -p /var/webapps /var/local/straitjacket/{lib,tmp}
mv $checkout /var/webapps/straitjacket
cd /var/webapps/straitjacket/src && make

# put configurations in place
mv /var/webapp/straitjacket/src/getpwuid_r_hijack.so \
   /var/local/straitjacket/lib
cp -r /var/webapp/straitjacket/files/etc/apparmor.d/* /etc/apparmor.d/
cp /var/webapp/straitjacket/files/etc/apache2/sites-available/straitjacket \
   /etc/apache2/sites-available/straitjacket
sudo chown -R straitjacket:straitjacket /var/local/straitjacket \
                                        /var/webapps/straitjacket
/etc/init.d/apache2 restart

# test the setup
cd /var/webapps/straitjacket && git checkout testing
rm /var/webapps/straitjacket/config/cache*
python /var/webapp/straitjacket/server_test.py
python /var/webapps/straitjacket/remote_server_test.py

# done
cd /var/webapps/straitjacket && git checkout master
