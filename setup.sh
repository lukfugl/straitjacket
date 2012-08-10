# tested on a VirtualBox i386 Ubuntu Precise VM

# install dependencies
sudo aptitude install apache2-mpm-itk gcc mono-gmcs g++ guile-1.8 ghc lua5.1 \
                      ocaml php5 python ruby ruby1.9.3 scala racket golang \
                      openjdk-6-jdk python-pip gcc-multilib xdg-utils nodejs \
                      npm make python-webpy python-libapparmor apparmor \
                      libapache2-mod-wsgi

# install DMD (not available in apt)
wget http://ftp.digitalmars.com/dmd_2.060-0_i386.deb
sudo dpkg -i dmd_2.060-0_i386.deb
rm dmd_2.060-0_i386.deb

# relocate under straitjacket user
sudo adduser straitjacket
sudo mkdir -p /var/webapps
sudo mv ../straitjacket /var/webapps/straitjacket
sudo chown -R straitjacket:straitjacket /var/webapps/straitjacket
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
