![Checksums-platform-macos](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Checksums-code-shell](https://img.shields.io/badge/code-shell-yellow.svg)
[![Checksums-depend-tnote](https://img.shields.io/badge/dependency-terminal--notifier%201.7.1-green.svg)](https://github.com/alloy/terminal-notifier)
[![Checksums-license](http://img.shields.io/badge/license-MIT+-blue.svg)](https://github.com/JayBrown/Checksums/blob/master/license.md)

# Checksums <img src="https://github.com/JayBrown/Checksums/blob/master/img/jb-img.png" height="20px"/>
**macOS workflow and shell script to calculate or automatically verify file checksums**

## Supported algorithms (native to macOS)
* CRC-32
* MD5-length: MD4, MD5, MDC-2
* SHA1-length: SHA-1, SHA-0, RIPEMD-160
* SHA2-class: SHA-224, SHA-256, SHA-384, SHA-512

Note: MD2 calculation produces an error on macOS, so it is not enabled.

## Functionality
* default algorithm: SHA-256
* calculates user-selected (or default) checksum & file size
* copies all information incl. filename to clipboard
* parses clipboard content for possible checksums and auto-compares to calculated checksum

## Planned functionality (this might take a while)
* second workflow/script for non-native algorithms (based e.g. on `rhash`)

## Installation
* [Download the latest DMG](https://github.com/JayBrown/Checksums/releases) and open

** NOT YET RELEASED **

### Workflow
* Double-click on the workflow file to install
* If you encounter problems, open it with Automator and save/install from there
* Standard Finder integration in the Services menu

### Main shell script [optional]
Only necessary if for some reason you want to run this from the shell or another shell script. For normal use the workflow will be sufficient.

* Move the script `checksums-native.sh` to `/usr/local/bin`
* In your shell enter `chmod +x /usr/local/bin/checksums-native.sh`
* Run the script with `checksums-native.sh /path/to/target`

## Uninstall
Remove the following files or folders:

```
$HOME/Library/Caches/local.lcars.Checksums
$HOME/Library/Services/Checksums.workflow
/usr/local/bin/checksums-native.sh
```

### terminal-notifier [optional, recommended]
More information: [terminal-notifier](https://github.com/alloy/terminal-notifier)

You need to have Spotlight enabled for `mdfind` to locate the terminal-notifier.app on your volume; if you don't install terminal-notifier, or if you have deactivated Spotlight, the Checksums scripts will call notifications via AppleScript instead

* install using [Homebrew](http://brew.sh) with `brew install terminal-notifier` (or with a similar manager)
* move or copy `terminal-notifier.app` from the Homebrew Cellar to a suitable location, e.g. to `/Applications`, `/Applications/Utilities`, or `$HOME/Applications`
