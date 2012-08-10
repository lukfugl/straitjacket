#!/bin/sh

# relocate under straitjacket user
sudo adduser straitjacket
sudo mkdir -p /var/webapps /var/local/straitjacket
sudo mv ../straitjacket /var/webapps/straitjacket
sudo chown -R straitjacket:straitjacket /var/webapps/straitjacket \
                                        /var/local/straitjacket
cd /var/webapps/straitjacket

# setup
sudo -u straitjacket python install.py
sudo -u straitjacket mkdir -p /var/local/straitjacket/lib static
cd src && sudo -u straitjacket make

# put C# getpwuid hack in place
sudo -u straitjacket mv src/getpwuid_r_hijack.so /var/local/straitjacket/lib/

# configure apparmor
sudo cp -r files/etc/apparmor.d/* /etc/apparmor.d/
sudo /etc/init.d/apparmor reload

# configure apache
sudo cp files/etc/apache2/sites-available/straitjacket \
        /etc/apache2/sites-available/straitjacket
sudo ln -s /etc/apache2/sites-available/straitjacket /etc/apache2/sites-enabled
sudo rm /etc/apache2/sites-enabled/000-default
sudo /etc/init.d/apache2 restart

# test the setup
sudo -u straitjacket git checkout testing
sudo -u straitjacket python server_tests.py
sudo -u straitjacket python remote_server_tests.py http://localhost/

# done
sudo -u straitjacket git checkout master
