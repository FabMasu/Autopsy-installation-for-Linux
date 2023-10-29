#!/bin/bash

# Installation script for forensic software Autopsy GNU-Linux OS.
# This script wroks for Debian type distributions (Ubuntu, Mint, ...)
# Tested on Linux Mint 21.1 and Autopsy 4.20.0 with Sleuthkit 4.12.0-1
# By Fabrice MASURIER with the help of Nicolas CANOVA (le testeur).

echo "Installation of Autopsy on a linux X64 computer"
echo "Installation of dependencies"

if [ -d "/home/Desktop" ];then
alias Bureau='Desktop';
echo "Your DESKTOP seems to be the english way!";
else echo "Vos dossiers ont été francisés Vous avez un dossier 'Bureau'.";
fi
read -p "What is the last SleuthKit version? Just give the version number without the '-1' at the end (ex:4.12.0) : " versionSleuthKit
read -p "What is the last Autopsy version? As well, just give the version number ex:4.20.0) : " versionAutopsy
clear

# removing older versions

echo "Removing older versions."
cd /home/$USER
sudo rm -rf /home/$USER/Autopsy /home/$USER/./autopsy 
sudo rm -rf /home/$USER/Bureau/Autopsy.desktop
sudo apt remove -y sleuthkit-java

# Preparing sources

echo "Preparing the sources..."
sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
if [[ $? -ne 0 ]]; then
    echo "Failling to prepare the sources." >>/dev/stderr
    exit 1
fi

# Prerequistes installation

echo "prerequistes installation..."
sudo apt update && \
    sudo apt -y install \
        openjdk-17-jdk openjdk-17-jre \
        build-essential autoconf libtool automake git zip wget ant \
        libde265-dev libheif-dev \
        libpq-dev \
        testdisk libafflib-dev libewf-dev libvhdi-dev libvmdk-dev \
        libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x \
        gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio flatpak
if [[ $? -ne 0 ]]; then
    echo "Failed to install necessary dependencies" >>/dev/stderr
    exit 1
fi
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo



clear
echo "Netbeans installation..."
flatpak -y install netbeans
clear

if [[ $? -ne 0 ]]; then
    echo "Failling to install prérequistes." >>/dev/stderr
    exit 1
fi

# Java installation
echo "Java 17 installation: "
update-java-alternatives -l | grep java-1.17
sleep 5

#echo "Checking for Java..."
#sleep 5
#testjava=/usr/local/jdk-17
#if [ -e $testjava ] 
#then
#    echo "Java 17 is already installed!"
#    exit 1
#fi

#echo "Prérequis d'Autopsy installés."
#echo "Java path at /usr/lib/jvm/java-17-openjdk-amd64: "
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export JDK_HOME=”${JAVA_HOME}”
export PATH=”${JAVA_HOME}/bin:${PATH}”
sudo echo "JAVA_HOME='/usr/lib/jvm/java-17-openjdk-amd64'" >> .bashrc


export PATH=$JAVA_HOME/bin:$PATH

# Sleuthkit installation

workingdir=`pwd`
repauto=/home/$USER/Autopsy
if [ -d $repauto ] 
then
    echo "The Autopsy folder already exists!"
    sleep 5
else 
    mkdir /home/$USER/Autopsy
    chmod 770 -R /home/$USER/Autopsy
    cd /home/$USER/Autopsy
fi
clear

testsk=/usr/share/java/sleuthkit-$versionSleuthKit.jar
if [ -e $testsk ] 
then
    echo "The same Sleuthkit version is already installed!"
    echo "Sleuthkit won't be réinstalled!"
    sleep 5
else 
    sudo dpkg --configure -a
    echo "SleuthKit installation : "    
    cd /home/$USER/Autopsy 
    wget -q --show-progress "https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-"$versionSleuthKit"/sleuthkit-java_"$versionSleuthKit"-1_amd64.deb" /home/$USER/Autopsy
    sleep 5
    sudo dpkg -i /home/$USER/Autopsy/sleuthkit-java_$versionSleuthKit-1_amd64.deb
    sudo apt-get -y install -f
   sleep 5
fi
clear

# Autopsy installation

testauto=/home/$USER/Autopsy/autopsy-$versionAutopsy
if [ -e $testauto ] 
then
    echo "The same Autopsy version is already installed!" 
    echo "Autopsy won't be réinstalled!"
    sleep 5
else 
    cd /home/$USER/Autopsy
    echo "Autopsy installation : "
    wget -q --show-progress "https://github.com/sleuthkit/autopsy/releases/download/autopsy-$versionAutopsy/autopsy-$versionAutopsy.zip" /home/$USER/Autopsy
    cd /home/$USER/Autopsy
    unzip autopsy-$versionAutopsy.zip
    echo "jdkhome=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    echo "JDK=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    
    # Installation 
    jdkhome=$JAVA_PATH        
    chown -R $(whoami)
    cd /home/$USER/Autopsy/autopsy-$versionAutopsy
    chmod u+x unix_setup.sh 
    bash ./unix_setup.sh -j /usr/lib/jvm/java-17-openjdk-amd64 -n autopsy
    
    # Icon creation on the desk
    clear    
    cd //home/$USER/Autopsy/autopsy-$versionAutopsy
    echo "Removing .zip et .deb"
    rm /home/$USER/Autopsy/autopsy-$versionAutopsy.zip|rm /home/$USER/Autopsy/sleuthkit-java_$versionSleuthKit-1_amd64.deb
    echo "Creation of a starting link on the desk"
    /bin/echo "[Desktop Entry]" >/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Version=$versionAutopsy" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Type=Application" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Terminal=false" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Name[fr_FR]=AUTOPSY" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Exec=sh /home/$USER/Autopsy/autopsy-$versionAutopsy/bin/autopsy" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Name=AUTOPSY" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Icon=/home/$USER/Autopsy/autopsy-$versionAutopsy/icon.ico" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/chmod 711 /home/$USER/Bureau/Autopsy.desktop
    /bin/chmod 777 /home/$USER/Autopsy/autopsy-$versionAutopsy/bin/autopsy
    /bin/chmod 777 /home/$USER/Autopsy/autopsy-$versionAutopsy/icon.ico
    echo "Autopsy will start. Once done, it will create its own configuration folders,
you could close it, so, but leave the terminal carry on working for modules installation. 
At start, a dialog will ask you to use the Central repository. You should use it."
    sleep 20
    clear
    echo "Close the application, do not close the terminal it will close itself"
    echo ok | sh /home/$USER/Autopsy/autopsy-$versionAutopsy/bin/autopsy --nosplash
    
fi

clear

# Modules installation

cd /home/$USER/Bureau
testmaster=/home/$USER/.autopsy/dev/python_modules/Skype.py
if [ -e $testmaster ] 
then
    echo "Masters folder is already installed!"
    sleep 5
else 
    echo "Python plugins installation."
    wget -q --show-progress "https://github.com/markmckinnon/Autopsy-Plugins/archive/master.zip"
    unzip master.zip
    mv Autopsy-Plugins-master/* /home/$USER/.autopsy/dev/python_modules/
    mv Custom_Autopsy_Plugins-master/* /home/$USER/.autopsy/dev/python_modules/

    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/Chrome_Passwords/chrome_password_identifier/ChromePasswords.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/GoogleDrive/google_drive/GDrive.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/IE%20Tiles/ie_tiles/IETiles.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/iPhone_Backup_Plist_Analyzer/connected_iphone_analyzer/Iphones.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/Skype/skype_analyzer/Skype.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/Windows_Communication_App/windows_communication_App/WindowsCommAppFileIngestModule.py
    
    mv ChromePasswords.py /home/$USER/.autopsy/dev/python_modules/
    mv GDrive.py /home/$USER/.autopsy/dev/python_modules/
    mv IETiles.py /home/$USER/.autopsy/dev/python_modules/
    mv Iphones.py /home/$USER/.autopsy/dev/python_modules/
    mv Skype.py /home/$USER/.autopsy/dev/python_modules/
    mv WindowsCommAppFileIngestModule.py /home/$USER/.autopsy/dev/python_modules/
    rm -R Autopsy-Plugins-master
    rm -R master.zip
fi
clear
cd /home/$USER/Bureau
testmod=/home/$USER/Bureau/ModulesNetBeans/autopsy-ahbm.nbm
if [ -e $testmod ] 
then
    echo "Netbeans modules is already instest déjà installé!"
    sleep 5
else 
    mkdir ModulesNetBeans
    chmod 770 ModulesNetBeans
    echo "Netbeans module are on the desk. To install them in Autopsy, go to Tools, plugins, and in the open box, choose Downloaded modules and select all the folder packs on the desk. They will be installed."
    sleep 10
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/sdhash/autopsy-ahbm.nbm
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/CopyMove/de-fau-copymoveforgerydetection.nbm
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/VirusTotal/org-sleuthkit-autopsy-modules-virustotalonlinecheck.nbm
    mv autopsy-ahbm.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv de-fau-copymoveforgerydetection.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv org-sleuthkit-autopsy-modules-virustotalonlinecheck.nbm /home/$USER/Bureau/ModulesNetBeans/
    rm /home/$USER/Bureau/InstallAutopsy.sh
fi

clear
echo "Installation is now done. Have a nice day!"
sleep 10



