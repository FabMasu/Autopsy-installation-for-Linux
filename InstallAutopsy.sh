#!/bin/bash

# Installation script for Autopsy.
# Runs on Debian (Ubuntu, Mint, ...)
# Tested on Linux Mint 20.1 and Autopsy 4.17.0 with Sleuthkit 4.10.1-1
# By Fabrice MASURIER.


echo "Installation of Autopsy on a linux X64 computer"
echo "Installation of componants"
echo "Installation of Testdisk"

if [ -d "/home/Desktop" ];then
alias Bureau='Desktop';
echo "Your folders are not french, your desktop is DESKTOP!";
else echo "Your folders are french, Vous avez un dossier 'Bureau'.";
fi

testdsk=/usr/bin/testdisk

if [ -e $testdsk ] 
then
    echo "Testdisk is already installed!"
    sleep 5
else 
    sudo dpkg --configure -a
    sudo apt-get update 
    sudo apt-get install testdisk
fi

clear

echo "Checking of ImageMagick installation...'"
imgmgk=/usr/local/lib/ImageMagick*
if [ -e $imgmgk ] 
then
    echo "ImageMagick already installed!"
    sleep 5
else 
   # Imagemagick Installation 
    echo "ImageMagick installation, please wait..."
    nbproc= nproc
    sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get install build-essential autoconf libtool git-core -y
    sudo apt-get build-dep imagemagick libmagickcore-dev libde265 libheif
    clear
    cd /usr/src/ 
    sudo git clone https://github.com/strukturag/libde265.git 
    sudo git clone https://github.com/strukturag/libheif.git 
    cd libde265/ 
    sudo ./autogen.sh 
    sudo ./configure 
    sudo make -j$nbproc
    sudo make install -j$nbproc
    clear
    cd /usr/src/libheif/ 
    sudo ./autogen.sh 
    sudo ./configure 
    sudo make -j$nbproc
    sudo make install -j$nbproc
    clear
    cd /usr/src/ 
    sudo wget https://www.imagemagick.org/download/ImageMagick.tar.gz 
    sudo tar xf ImageMagick.tar.gz 
    cd ImageMagick-7*
    sudo ./configure --with-heic=yes 
    sudo make -j$nbproc
    sudo make install -j$nbproc
    sudo ldconfig 
fi
clear

workingdir=`pwd`
repauto=/home/$USER/Autopsy
if [ -d $repauto ] 
then
    echo "Autopsy folder already exists!"
    sleep 5
else 
    mkdir /home/$USER/Autopsy
    chmod 770 -R /home/$USER/Autopsy
    cd /home/$USER/Autopsy
fi
clear

echo "Checking of Java installation"
sleep 5
testjava=/usr/lib/jvm/bellsoft*
if [ -e $testjava ] 
then
    echo "Java 8 is already installed!"
     sleep 5
else 
    echo "Installation of java"
    echo "Keys acquisition : "
    wget -q -O - "https://download.bell-sw.com/pki/GPG-KEY-bellsoft" | sudo apt-key add -
    echo "Sources copy : "
    echo "deb [arch=amd64] https://apt.bell-sw.com/ stable main" | sudo tee /etc/apt/sources.list.d/bellsoft.list
    echo "Copying from Ubuntu and installation of java 8."
    sudo apt-get update
    sudo apt-get install bellsoft-java8-full 
    export JAVA_HOME=/usr/lib/jvm/bellsoft-java8-full-amd64
    export PATH=$PATH:$JAVA_HOME/bin
    source /etc/environment
    echo "Java localisation : " $JAVA_HOME
    echo "Java path localisation : " $PATH
    echo "JAVA_HOME=/usr/lib/jvm/bellsoft-java8-full-amd64" |sudo  tee -a /etc/environment
    sleep 3
fi
clear

read -p "Last SleuthKit version? Just give the version number without '-1' on end : " versionSleuthKit
read -p "Last autopsy version? Just give, as well, the version number : " versionAutopsy
clear

testsk=/usr/share/java/sleuthkit-$versionSleuthKit.jar
if [ -e $testsk ] 
then
    echo "The Sleuthkit version you want is already installed!"
    sleep 5
else 
    sudo dpkg --configure -a
    echo "SleuthKit installation : " 
    wget -q --show-progress "https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-"$versionSleuthKit"/sleuthkit-java_"$versionSleuthKit"-1_amd64.deb" /home/$USER/Autopsy
    cd /home/$USER/Autopsy
    sudo dpkg -i *.deb
    sudo apt-get install -fy
    sleep 5
fi
clear

testauto=/home/$USER/Autopsy/autopsy-$versionAutopsy
if [ -e $testauto ] 
then
    echo "The Autopsy version you want is already installed!" 
    echo "Autopsy won't be reinstalled!"
    sleep 5
else 
    echo "Autopsy installation : "
    wget -q --show-progress "https://github.com/sleuthkit/autopsy/releases/download/autopsy-$versionAutopsy/autopsy-$versionAutopsy.zip" /home/$USER/Autopsy
    cd /home/$USER/Autopsy
    unzip autopsy-$versionAutopsy.zip
    cd autopsy-$versionAutopsy
    sh unix_setup.sh
    sleep 5
       
    cd //home/$USER/Autopsy/autopsy-$versionAutopsy
    echo "Deleting files .zip and .deb"
    rm /home/$USER/Autopsy/autopsy-$versionAutopsy.zip|rm /home/$USER/Autopsy/sleuthkit-java_"$versionSleuthKit"_amd64.deb
    echo "Creation of link and  icon on the desktop"
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
    echo "Autopsy will start. Once the software will run, it will create configuration files, you will then close it, but let the terminal continue to run for modules installation. On the first run, a dialog should come but is hidden behind the starting panel. This dialog is asking the user to use the central repository. It is highly recommanded to use this tool. If nothing moves, click 2X on TAB then Enter."
    sleep 20
    clear
	echo "If nothing moves, click 2X on TAB then Enter."
    echo ok | sh /home/$USER/Autopsy/autopsy-$versionAutopsy/bin/autopsy
    
fi
clear

cd /home/$USER/Bureau
testmaster=/home/$USER/.autopsy/dev/python_modules/Skype.py
if [ -e $testmaster ] 
then
    echo "Master folder is already installed!"
    sleep 5
else 
    echo "Python plugins installation."
    wget -q --show-progress "https://github.com/markmckinnon/Autopsy-Plugins/archive/master.zip"
    unzip master.zip
    mv Autopsy-Plugins-master/* /home/$USER/.autopsy/dev/python_modules/
   
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
    echo "The netbeans modules folder is already installed!"
    sleep 5
else 
    mkdir ModulesNetBeans
    chmod 770 ModulesNetBeans
    echo "The NetBeans modules are in a fonder on the desktop. To install them, on Autopsy, go to Tools, plugins,on the dialog choose downloaded modules et select the files in the folder on the desktop. They will be installed."
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
echo "Installation is complete. Have a nice day!"
sleep 10




