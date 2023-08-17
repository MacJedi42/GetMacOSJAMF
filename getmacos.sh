#!/bin/bash
##macOS download script written by Sebastian Whincop 2022
##This script is designed to download macOS Installers directly from Apple's servers.
##If the download isn't successful the script will try again and resume from where it left off until it is successful... or give up after 5 attempts.
##This script is designed to be run as a script policy in Jamf Pro.
##If there is less than 30GB of space this script will stop and refuse to download the installer.

## Change this variable to the macOS version you want. i.e https://swcdn.apple.com/content/downloads/00/52/012-38280-A_U42U8QWY6W/xlqy3umkvwvbsjyh471ips53ux8r0jdywq/InstallAssistant.pkg is BigSur 11.7
## Recommend https://mrmacintosh.com/ to get InstallAssistant.pkg URLs (https://mrmacintosh.com/macos-ventura-13-full-installer-database-download-directly-from-apple/)
URL="https://swcdn.apple.com/content/downloads/01/07/032-69593-A_15V577BH7O/fau3wbhcg9pmo81cgkb2qjp0gfbp1jxu26/InstallAssistant.pkg"
##Updated link 24/07/2023 - 13.5 <-------


## First we'll run a fix for Spotlight indexes getting stuck during the upgrade.
## This process can take a long time to complete in some cases.
## See here for info: https://mrmacintosh.com/macos-upgrade-to-big-sur-failed-stuck-progress-bar-fix-prevention/

rm -rf /private/var/folders/*/*/C/com.apple.mdworker.bundle
rm -rf /private/var/folders/*/*/C/com.apple.metadata.mdworker

##Now let's make sure there's enough space on the local disk. We want at least 30GB spare or we wont attempt to download.
FREESPACE=$(df -Pk . | sed 1d | grep -v used | awk '{ print $4 "\t" }')   # df -k not df -h to find the total disk space in bytes.
##If freespace is less than 30G then log an error and don't run the rest of the script.
if [ "$FREESPACE" -lt "30485760" ];# 30G = 30*1024*1024k
	then               
  	  echo "Not enough space. macOS Installer download will not be attempted. "
  	  exit 202 
	else
	  echo "More than 30GB of space detected, proceeding to download...."
fi

##Double check /Library/Application Support/macOSCache/ exists 
if [ -d "/Library/Application Support/macOSCache/" ]
then
	echo "/Library/Application Support/macOSCache/ exits, beginning download...."
else
	echo "/Library/Application Support/macOSCache/ is missing. Creating directory...."
	mkdir /Library/Application\ Support/macOSCache/
fi

##Start the download from Apple's Servers
curl -o /Library/Application\ Support/macOSCache/InstallAssistant.pkg  -C - $URL
##Get the exit code from CURL so that it's known to this script
res=$?

## If successful, install the macOS installer into /Applications/
if [[ "$res" = "0" ]]; then
 installer -pkg /Library/Application\ Support/macOSCache/InstallAssistant.pkg -target /
  echo "macOS Installer copied to /Applications/"
  	 sleep 5
  echo "Removing /Library/Application Support/macOSCache/InstallAssistant.pkg "
  	 rm -rf /Library/Application\ Support/macOSCache/InstallAssistant.pkg
   	exit 0
else


##Get the exit code from CURL so that it's known to this script
#res=$?

###echo "$res"

##While the exit code is not 0 (exit code 0 means the download was successful) keep trying to download the installer from Apple.
while [[ "$res" != "0" ]]
do
   echo "Download was interrupted, I will wait 30 mins before trying again."
   echo "Curl command failed with: $res"
   ##Wait a bit before trying again.
    sleep 1800
###$res ='0'
curl -o /Library/Application\ Support/macOSCache/InstallAssistant.pkg  -C - $URL
##Get the new exit code from CURL so that it's known to this script
	res=$?
###echo "After retrying the curl command failed with: $res"
##If the exit code was 0 (exit code 0 means download was successful) then exit this loop
  	 if [[ "$res" = "0" ]]; then
##Install the macOS Installer into /Applications/	 
  	 installer -pkg /Library/Application\ Support/macOSCache/InstallAssistant.pkg -target /
  	 echo "Installer has run InstallAssistant.pkg to /"
  	 sleep 5
  	 echo "Removing /Library/Application\ Support/macOSCache/InstallAssistant.pkg "
  	 rm -rf /Library/Application\ Support/macOSCache/InstallAssistant.pkg
   	break
   	 fi
##Give up after 5 attempts
    ((c++)) && ((c==5)) && c=0 && echo "I tried 5 times, can't be bothered anymore." && exit 5 #break
done
fi
exit 0
