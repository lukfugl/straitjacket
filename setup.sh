#!/bin/sh

WEBROOT=/var/webapps/straitjacket
LOCALROOT=/var/local/straitjacket

# relocate under straitjacket user
sudo adduser straitjacket
sudo mkdir -p /var/webapps $LOCALROOT
sudo mv ../straitjacket $WEBROOT
sudo chown -R straitjacket:straitjacket $WEBROOT $LOCALROOT

# setup
cd $WEBROOT && sudo -u straitjacket python install.py
sudo -u straitjacket mkdir -p $LOCALROOT/lib $WEBROOT/static
cd $WEBROOT/src && sudo -u straitjacket make

# put C# getpwuid hack in place
sudo -u straitjacket mv $WEBROOT/src/getpwuid_r_hijack.so $LOCALROOT/lib/

# configure apparmor
sudo cp -r $WEBROOT/files/etc/apparmor.d/* /etc/apparmor.d/
sudo /etc/init.d/apparmor reload

# configure apache
sudo cp $WEBROOT/files/etc/apache2/sites-available/straitjacket /etc/apache2/sites-available/straitjacket
sudo ln -s /etc/apache2/sites-available/straitjacket /etc/apache2/sites-enabled
sudo rm /etc/apache2/sites-enabled/000-default
sudo /etc/init.d/apache2 restart

# test the setup
cd $WEBROOT && sudo -u straitjacket python server_tests.py
cd $WEBROOT && sudo -u straitjacket python remote_server_tests.py http://localhost/

# done
cd $WEBROOT && sudo -u straitjacket git checkout master
