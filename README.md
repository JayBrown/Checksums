![Checksums-platform-macos](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Checksums-code-shell](https://img.shields.io/badge/code-shell-yellow.svg)
[![Checksums-depend-gsutil](https://img.shields.io/badge/dependency-gsutil%204.2.2-green.svg)](https://github.com/GoogleCloudPlatform/gsutil)
[![Checksums-depend-rhash](https://img.shields.io/badge/dependency-rhash%201.3.4-green.svg)](https://github.com/rhash/RHash)
[![Checksums-depend-tnote](https://img.shields.io/badge/dependency-terminal--notifier%201.7.1-green.svg)](https://github.com/alloy/terminal-notifier)
[![Checksums-depend-transm](https://img.shields.io/badge/dependency-transmission%202.9.2-green.svg)](https://github.com/transmission/transmission-releases)
[![Checksums-license](http://img.shields.io/badge/license-MIT+-blue.svg)](https://github.com/JayBrown/Checksums/blob/master/license.md)

# Checksums <img src="https://github.com/JayBrown/Checksums/blob/master/img/jb-img.png" height="20px"/>
**macOS workflow and shell script to calculate or automatically verify file checksums**

Do you still need to launch third-party software to create or verify checksums? Do you need to copy *and* paste a checksum to verify it? Do you still use the command line to calculate checksums? Do you verify checksums visually? Do you need to publish file size information, too? Do you need to compare the contents of two folders? Do you have several applications for different tasks? Is there a checksum created with an unusual algorithm you can't verify?

No need for additional tools anymore. Do all the operations you would need (in most cases!) directly from the Finder, thanks to the power of Apple's macOS Services.

Minimum OS: **OS X 10.8**

## Supported algorithms
### macOS native
* CRC (BSD), CRC (System V), CRC (legacy 32bit) [decimal]
* CRC (ISO/IEC 8802-3:1989) [decimal]
* CRC-32 (sometimes called CRC-32b to distinguish from ethernet CRC-32)
* MD5-length: MD4, MD5, MDC-2
* SHA1-length: SHA-1, SHA-0, RIPEMD-160
* SHA2-class: SHA-224, SHA-256, SHA-384, SHA-512

### Native calculations [scripted]
* Adler-32 (using `adler32` from `zlib`)

### Other [optional]
#### gsutil
* CRC-32C [hexadecimal]

#### rhash
* MD5-length: AICH, SNEFRU-128
* DC++ TTH
* SHA1-length: BTIH, HAS-160
* Tiger
* SHA3-class: SHA3-224, SHA3-256, SHA3-384, SHA3-512
* EDON-R 256, GOST, GOST CryptoPro, SNEFRU-256
* EDON-R 512, Whirlpool

#### transmission
* Bencode (BitTorrent hash)

## Functionality
* default single file algorithm: SHA-256
* calculates default or user-selected checksum
* calculates file size (output: B, MB, MiB)
* copies all information incl. filename to clipboard
* parses clipboard content for possible checksums and auto-compares to calculated checksum
* ignores clipboard checksum if the same value was already checked in the previous run
* lots of additional checksum options, e.g. GOST, if the user has installed the `rhash` CLI
* BitTorrent file hash calculation is possible, if the user has installed the `transmission` CLI
* CRC-32C hash calculation is possible, if the user has installed the `gsutil` python CLI
* creates `.sfv`, `.md5`, `.sha1`, `.sha256`, or `.sha512` checksum digests for all files in a selected directory (recursive, without invisibles)
* verifies `.sfv`, `.md5`, `.sha1`, `.sha256`, or `.sha512` checksum digests for single or multiple files incl. directories (recursive)
* compares two files using MD5
* compares contents of two directories using CRC-32 (recursive, with invisibles, without .DS_Store)

### Notes
* **MD2** calculation produces an error with `openssl` for macOS, so it is *not enabled*
* **AICH** and **DC++ TTH** (part of `rhash`) are not (yet?) available for automatic checksum comparison
* **Bencode** will work on `.torrent` files only
* For the **Adler-32** calculation, a python script called `adler32.py` will be created in `$HOME/Library/Caches/local.lcars.Checksums/bin`

### Future
* **mhash** integration via `py-mhash` (unsure)

## Installation
* [Download the latest DMG](https://github.com/JayBrown/Checksums/releases) and open

### Workflow
* Double-click on the workflow file to install
* If you encounter problems, open it with Automator and save/install from there
* Standard Finder integration in the Services menu

### Main shell script [optional]
Only necessary if for some reason you want to run this from the shell or another shell script. For normal use the workflow will be sufficient.

* Move the script `checksums.sh` to `/usr/local/bin`
* In your shell enter `chmod +x /usr/local/bin/checksums.sh`
* Run the script with `checksums.sh /path/to/target`

## Uninstall
Remove the following files or folders:

```
$HOME/Library/Caches/local.lcars.Checksums
$HOME/Library/Preferences/local.lcars.Checksums.plist
$HOME/Library/Services/Checksums.workflow
/usr/local/bin/checksums.sh
```

## Optional installations

### gsutil
More information: [gsutil](https://cloud.google.com/storage/docs/gsutil_install)

* first install current `python` (v2) with `brew install python` (or with a similar manager) which will include `pip`
* then install `gsutil` with `pip install gsutil`

### rhash [recommended]
More information: [rhash](https://github.com/rhash/RHash)

* install using [Homebrew](http://brew.sh) with `brew install rhash` (or with a similar manager)

### terminal-notifier [recommended]
More information: [terminal-notifier](https://github.com/alloy/terminal-notifier)

You need to have Spotlight enabled for `mdfind` to locate the terminal-notifier.app on your volume; if you don't install terminal-notifier, or if you have deactivated Spotlight, the Checksums scripts will call notifications via AppleScript instead

* install using [Homebrew](http://brew.sh) with `brew install terminal-notifier` (or with a similar manager)
* move or copy `terminal-notifier.app` from the Homebrew Cellar to a suitable location, e.g. to `/Applications`, `/Applications/Utilities`, or `$HOME/Applications`

### transmission
More information: [transmission](https://github.com/transmission/transmission-releases)

* install using [Homebrew](http://brew.sh) with `brew install transmission` (or with a similar manager)
* **Checksums** will use only the `transmission-show` binary

## Screengrabs
![checksum-main](https://github.com/JayBrown/Checksums/blob/master/img/checksums-main.png)

![checksum-calculated](https://github.com/JayBrown/Checksums/blob/master/img/checksums-calc.png)

![checksum-verified](https://github.com/JayBrown/Checksums/blob/master/img/checksums-verify.png)

![checksum-verified](https://github.com/JayBrown/Checksums/blob/master/img/checksums-fail.png)

![checksum-multiple](https://github.com/JayBrown/Checksums/blob/master/img/checksums-multi.png)

![checksum-algorithms](https://github.com/JayBrown/Checksums/blob/master/img/checksums-other.png)
