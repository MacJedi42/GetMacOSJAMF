# macOS Download Script

This script is designed to download macOS Installers directly from Apple's servers. If the download isn't successful, the script will try again and resume from where it left off until it is successful... or give up after 5 attempts. 
This script is designed to be run as a script policy in Jamf Pro, but should work in other MDM solutions. If there is less than 30GB of space, this script will stop and refuse to download the installer.

## Prerequisites

- macOS system
- Terminal access
- Sufficient disk space (at least 30GB)

## Usage

```bash
./macOS_download_script.sh
```

## Configuration

Change the URL variable to the macOS version you want. For example, BigSur 11.7 would be:

```bash
URL="https://swcdn.apple.com/content/downloads/01/07/032-69593-A_15V577BH7O/fau3wbhcg9pmo81cgkb2qjp0gfbp1jxu26/InstallAssistant.pkg"
```

I recommend using [Mr. Macintosh](https://mrmacintosh.com/) to get InstallAssistant.pkg URLs.

## How It Works

1. The script first runs a fix for Spotlight indexes getting stuck during the upgrade. This process can take a long time to complete in some cases.
2. The script then checks if there's enough space on the local disk. It requires at least 30GB spare, or it won't attempt to download.
3. If the `/Library/Application Support/macOSCache/` directory doesn't exist, the script creates it.
4. The script starts the download from Apple's Servers.
5. If successful, it installs the macOS installer into `/Applications/`.
6. If the download is interrupted, the script will wait for 30 minutes before trying again. It will give up after 5 attempts.

## Author

- Sebastian Whincop, 2023
