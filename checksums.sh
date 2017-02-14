#!/bin/bash

# Checksums v1.6.0
# Checksums (shell script version)

# minimum compatibility: native macOS checksum algorithms
# for the extended algorithms, e.g. SHA-3, please install the rhash CLI
# for Bencode support, please install the transmission CLI

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
ACCOUNT=$(/usr/bin/id -un)
CURRENT_VERSION="1.60"

# set -x
# PS4=':$LINENO+'

# clipboard checksum parsing
cscn () {
	case $1 in
		( *[!0-9A-Fa-f]* | "" ) echo "false" ;;
		( * )
			case ${#1} in
				( 4 ) echo "cksum-unix" ;;
				( 5 ) echo "cksum-unix" ;;
				( 8 ) echo "crc" ;;
				( 9 ) echo "cksum-modern" ;;
				( 10 ) echo "cksum3" ;;
				( 32 ) echo "md" ;;
				( 40 ) echo "sha" ;;
				( 56 ) echo "224" ;;
				( 64 ) echo "256" ;;
				( 96 ) echo "384" ;;
				( 128 ) echo "512" ;;
				( * ) echo "false" ;;
			esac
	esac
}

cscx () {
	case $1 in
		( *[!0-9A-Fa-f]* | "" ) echo "false" ;;
		( * )
			case ${#1} in
				( 4 ) echo "cksum-unix" ;;
				( 5 ) echo "cksum-unix" ;;
				( 8 ) echo "crc" ;;
				( 9 ) echo "cksum-modern" ;;
				( 10 ) echo "cksum3" ;;
				( 32 ) echo "md" ;;
				( 40 ) echo "sha" ;;
				( 48 ) echo "tiger" ;;
				( 56 ) echo "224" ;;
				( 64 ) echo "256" ;;
				( 96 ) echo "384" ;;
				( 128 ) echo "512" ;;
				( * ) echo "false" ;;
			esac
	esac
}

# notify function
notify () {
 	if [[ "$NOTESTATUS" == "osa" ]] ; then
		/usr/bin/osascript &>/dev/null << EOT
tell application "System Events"
	display notification "$2" with title "Checksums [" & "$ACCOUNT" & "]" subtitle "$1"
end tell
EOT
	elif [[ "$NOTESTATUS" == "tn" ]] ; then
		"$TERMNOTE_LOC/Contents/MacOS/terminal-notifier" \
			-title "Checksums [$ACCOUNT]" \
			-subtitle "$1" \
			-message "$2" \
			-appIcon "$ICON_LOC" \
			>/dev/null
	fi
}

# check for update
updater () {
	echo "Checking for update..."
	NEWEST_VERSION=$(/usr/bin/curl --silent https://api.github.com/repos/JayBrown/Checksums/releases/latest | /usr/bin/awk '/tag_name/ {print $2}' | xargs)
	if [[ "$NEWEST_VERSION" == "" ]] ; then
		NEWEST_VERSION="0"
	fi
	NEWEST_VERSION=${NEWEST_VERSION//,}
	if (( $(echo "$NEWEST_VERSION > $CURRENT_VERSION" | /usr/bin/bc -l) )) ; then
		notify "⚠️ Update available" "Checksums v$NEWEST_VERSION"
		/usr/bin/open "https://github.com/JayBrown/Checksums/releases/latest"
	fi
}

# check compatibility
MACOS2NO=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')
if [[ "$MACOS2NO" -le 7 ]] ; then
	echo "Error! Exiting…"
	echo "Checksums needs at least OS X 10.8 (Mountain Lion)"
	INFO=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set userChoice to button returned of (display alert "Error! Minimum OS requirement:" & return & "OS X 10.8 (Mountain Lion)" ¬
		as critical ¬
		buttons {"Quit"} ¬
		default button 1 ¬
		giving up after 60)
end tell
EOT)
	exit
fi

# icon & cache dir
ICON64="iVBORw0KGgoAAAANSUhEUgAAAIwAAACMEAYAAAD+UJ19AAACYElEQVR4nOzUsW1T
URxH4fcQSyBGSPWQrDRZIGUq2IAmJWyRMgWRWCCuDAWrGDwAkjsk3F/MBm6OYlnf
19zqSj/9i/N6jKenaRpjunhXV/f30zTPNzePj/N86q9fHx4evi9j/P202/3+WO47
D2++3N4uyzS9/Xp3d319+p3W6+fncfTnqNx3Lpbl3bf/72q1+jHPp99pu91sfr4f
43DY7w+fu33n4tVLDwAul8AAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATIC
A2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEB
MgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZ
gQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzA
ABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERggIzBARmCA
jMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJARGCAjMEBG
YICMwAAZgQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMw
QEZggIzAABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERgg
IzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJAR
GCAjMEBGYICMwAAZgQEy/wIAAP//nmUueblZmDIAAAAASUVORK5CYII="

CACHE_DIR="$HOME/Library/Caches/local.lcars.Checksums"
if [[ ! -e "$CACHE_DIR" ]] ; then
	mkdir -p "$CACHE_DIR"
fi
ICON_LOC="$CACHE_DIR/lcars.png"
if [[ ! -e "$ICON_LOC" ]] ; then
	echo "$ICON64" > "$CACHE_DIR/lcars.base64"
	/usr/bin/base64 -D -i "$CACHE_DIR/lcars.base64" -o "$ICON_LOC" && rm -rf "$CACHE_DIR/lcars.base64"
fi
if [[ -e "$CACHE_DIR/lcars.base64" ]] ; then
	rm -rf "$CACHE_DIR/lcars.base64"
fi

# bin directory for scripted checksum calculations
BIN_DIR="$CACHE_DIR/bin"
if [[ ! -e "$BIN_DIR" ]] ; then
	mkdir -p "$BIN_DIR"
fi

# tmp directory / remove old temp files
if [[ ! -e "$CACHE_DIR/tmp" ]] ; then
	mkdir -p "$CACHE_DIR/tmp"
else
	rm -rf "$CACHE_DIR/tmp/"*
fi

# check if Adler-32 script exists; create & chmod, if necessary
if [[ ! -f "$BIN_DIR/adler32.py" ]] ; then
	ADLERSCRIPT=$(/bin/cat << 'EOT'
#!/usr/bin/env python
'''Calculate Adler-32 checksum for file'''

BLOCKSIZE=256*1024*1024
import sys
from zlib import adler32

for fname in sys.argv[1:]:
	asum = 1
	with open(fname) as f:
		while True:
			data = f.read(BLOCKSIZE)
			if not data:
				break
			asum = adler32(data, asum)
			if asum < 0:
				asum += 2**32

print hex(asum)[2:10].zfill(8).lower(), fname
EOT)
	echo "$ADLERSCRIPT" > "$BIN_DIR/adler32.py" && /bin/chmod +x "$BIN_DIR/adler32.py"
fi

# look for terminal-notifier
TERMNOTE_LOC=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | /usr/bin/awk 'NR==1')
if [[ "$TERMNOTE_LOC" == "" ]] ; then
	NOTESTATUS="osa"
else
	NOTESTATUS="tn"
fi

# check for preferences file


# check if present: rhash, transmission-show, gsutil
RHASH=$(which rhash 2>/dev/null)
if [[ "$RHASH" != "/"*"/rhash" ]] ; then
	RHASH_STATUS="false"
else
	RHASH_STATUS="true"
fi
TRANSM=$(which transmission-show 2>/dev/null)
if [[ "$TRANSM" != "/"*"/transmission-show" ]] ; then
	BENCODE="false"
else
	BENCODE="true"
fi
GSUTIL=$(which gsutil 2>/dev/null)
if [[ "$GSUTIL" != "/"*"/gsutil" ]] ; then
	CASTA="false"
else
	CASTA="true"
fi
if [[ "$RHASH_STATUS" == "false" ]] && [[ "$BENCODE" == "false" ]] && [[ "$CASTA" == "false" ]] ; then
	EXTD="native"
elif [[ "$RHASH_STATUS" == "true" ]] && [[ "$BENCODE" == "false" ]] && [[ "$CASTA" == "false" ]] ; then
	EXTD="rh"
elif [[ "$RHASH_STATUS" == "true" ]] && [[ "$BENCODE" == "true" ]] && [[ "$CASTA" == "false" ]] ; then
	EXTD="rh-bc"
elif [[ "$RHASH_STATUS" == "true" ]] && [[ "$BENCODE" == "false" ]] && [[ "$CASTA" == "true" ]] ; then
	EXTD="rh-ca"
elif [[ "$RHASH_STATUS" == "true" ]] && [[ "$BENCODE" == "true" ]] && [[ "$CASTA" == "true" ]] ; then
	EXTD="rh-bc-ca"
elif [[ "$RHASH_STATUS" == "false" ]] && [[ "$BENCODE" == "true" ]] && [[ "$CASTA" == "false" ]] ; then
	EXTD="bc"
elif [[ "$RHASH_STATUS" == "false" ]] && [[ "$BENCODE" == "true" ]] && [[ "$CASTA" == "true" ]] ; then
	EXTD="bc-ca"
elif [[ "$RHASH_STATUS" == "false" ]] && [[ "$BENCODE" == "false" ]] && [[ "$CASTA" == "true" ]] ; then
	EXTD="ca"
fi

FILEPATH="$1" # ALT: delete for workflow

# ALT: for FILEPATH in "$@"
# ALT: do

FILE=$(/usr/bin/basename "$FILEPATH")
METHOD=""

# verify .sfv digest
if [[ "$FILE" == *".sfv" ]] ; then
	METHOD="digest"
	notify "⚠️ Please wait!" "Verifying checksums in SFV file…"
	PARENT=$(/usr/bin/dirname "$FILEPATH")
	SFV_CONTENT=$(/bin/cat "$FILEPATH")
	ERROR=""
	ERROR_COUNT="0"
	while read -r LINE
	do
		SFV_HASH=$(echo "$LINE" | /usr/bin/rev | /usr/bin/awk '{print $1}' | /usr/bin/rev)
		SFV_NAME=$(echo "$LINE" | /usr/bin/rev | /usr/bin/awk '{print substr($0, index($0,$2))}' | /usr/bin/rev)
		if [[ "$SFV_HASH" == "" ]] || [[ "$SFV_NAME" == "" ]] ; then
			continue
		fi
		if [[ ! -f "$PARENT/$SFV_NAME" ]] ; then
			echo "Missing file: $SFV_NAME"
			ERROR="true"
			((ERROR_COUNT++))
			continue
		else
			SFV_HEX_ALL=$(/usr/bin/cksum -o 3 "$PARENT/$SFV_NAME" 2>/dev/null | while read CK SIZE FILE; do printf "%s %08X\n" "$FILE" "$CK"; done)
			SFV_HEX=$(echo "$SFV_HEX_ALL" | /usr/bin/rev | /usr/bin/awk '{print $1}' | /usr/bin/rev)
			if [[ "$SFV_HEX" != "$SFV_HASH" ]] ; then
				echo "Checksum mismatch: $SFV_NAME"
				ERROR="true"
				((ERROR_COUNT++))
			fi
		fi
	done < <(echo "$SFV_CONTENT") > "$CACHE_DIR/tmp/csDig"
	if [[ "$ERROR" == "true" ]] ; then
		if [[ "$ERROR_COUNT" -gt 1 ]] ; then
			FILE_SIG="files"
		else
			FILE_SIG="file"
		fi
		/usr/bin/sort "$CACHE_DIR/tmp/csDig" -o "$CACHE_DIR/tmp/csDig"
		notify "❌ Failed: SFV" "$ERROR_COUNT $FILE_SIG had errors!"
		echo "Failed (SFV): $ERROR_COUNT $FILE_SIG had errors!"
		/usr/bin/open -a TextEdit "$CACHE_DIR/tmp/csDig"
	else
		notify "✅ Success: SFV" "All checksums match!"
		echo "Success (SFV): all checksums match!"
	fi
	exit # ALT: continue

# verify .md5 digest
elif [[ "$FILE" == *".md5" ]] ; then
	METHOD="digest"
	notify "⚠️ Please wait!" "Verifying checksums in MD5 file…"
	PARENT=$(/usr/bin/dirname "$FILEPATH")
	MD5_CONTENT=$(/bin/cat "$FILEPATH")
	ERROR=""
	ERROR_COUNT="0"
	while read -r LINE
	do
		MD5_HASH=$(echo "$LINE" | /usr/bin/awk '{print $1}')
		MD5_NAME=$(echo "$LINE" | /usr/bin/awk '{print substr($0, index($0,$2))}')
		if [[ "$MD5_NAME" == "" ]] || [[ "$MD5_HASH" == "" ]] ; then
			continue
		fi
		if [[ ! -f "$PARENT/$MD5_NAME" ]] ; then
			echo "Missing file: $MD5_NAME"
			ERROR="true"
			((ERROR_COUNT++))
			continue
		else
			MD5_CALC=$(/sbin/md5 -q "$PARENT/$MD5_NAME")
			if [[ "$MD5_CALC" != "$MD5_HASH" ]] ; then
				echo "Checksum mismatch: $MD5_NAME"
				ERROR="true"
				((ERROR_COUNT++))
			fi
		fi
	done < <(echo "$MD5_CONTENT") > "$CACHE_DIR/tmp/csDig"
	if [[ "$ERROR" == "true" ]] ; then
		if [[ "$ERROR_COUNT" -gt 1 ]] ; then
			FILE_SIG="files"
		else
			FILE_SIG="file"
		fi
		/usr/bin/sort "$CACHE_DIR/tmp/csDig" -o "$CACHE_DIR/tmp/csDig"
		notify "❌ Failed: MD5" "$ERROR_COUNT $FILE_SIG had errors!"
		echo "Failed (MD5): $ERROR_COUNT $FILE_SIG had errors!"
		/usr/bin/open -a TextEdit "$CACHE_DIR/tmp/csDig"
	else
		notify "✅ Success: MD5" "All checksums match!"
		echo "Success (MD5): all checksums match!"
	fi
	exit # ALT: continue

# verify .sha1, .sha256 or .sha512 digest
elif [[ "$FILE" == *".sha1" ]] || [[ "$FILE" == *".sha512" ]] || [[ "$FILE" == *".sha256" ]] ; then
	METHOD="digest"
	EXTENSION="${FILE##*.}"
	SHA_OPTION=$(echo "$EXTENSION" | /usr/bin/awk -F"sha" '{print $2}')
	if [[ "$SHA_OPTION" != "512" ]] && [[ "$SHA_OPTION" != "256" ]] && [[ "$SHA_OPTION" != "1" ]] ; then
		notify "☠️ Internal error" "Something went wrong"
		exit # ALT: continue
	fi
	notify "⚠️ Please wait!" "Verifying checksums in SHA$SHA_OPTION file…"
	PARENT=$(/usr/bin/dirname "$FILEPATH")
	SHA_CONTENT=$(/bin/cat "$FILEPATH")
	ERROR=""
	ERROR_COUNT="0"
	while read -r LINE
	do
		SHA_HASH=$(echo "$LINE" | /usr/bin/awk '{print $1}')
		SHA_NAME=$(echo "$LINE" | /usr/bin/awk '{print substr($0, index($0,$2))}')
		if [[ "$SHA_NAME" == "" ]] || [[ "$SHA_HASH" == "" ]] ; then
			continue
		fi
		if [[ ! -f "$PARENT/$SHA_NAME" ]] ; then
			echo "Missing file: $SHA_NAME"
			ERROR="true"
			((ERROR_COUNT++))
			continue
		else
			SHA_CALC=$(/usr/bin/shasum -a "$SHA_OPTION" "$PARENT/$SHA_NAME" | /usr/bin/awk '{print $1}')
			if [[ "$SHA_CALC" != "$SHA_HASH" ]] ; then
				echo "Checksum mismatch: $SHA_NAME"
				ERROR="true"
				((ERROR_COUNT++))
			fi
		fi
	done < <(echo "$SHA_CONTENT") > "$CACHE_DIR/tmp/csDig"
	if [[ "$ERROR" == "true" ]] ; then
		if [[ "$ERROR_COUNT" -gt 1 ]] ; then
			FILE_SIG="files"
		else
			FILE_SIG="file"
		fi
		/usr/bin/sort "$CACHE_DIR/tmp/csDig" -o "$CACHE_DIR/tmp/csDig"
		notify "❌ Failed: SHA-$SHA_OPTION" "$ERROR_COUNT $FILE_SIG had errors!"
		echo "Failed (SHA-$SHA_OPTION): $ERROR_COUNT $FILE_SIG had errors!"
		/usr/bin/open -a TextEdit "$CACHE_DIR/tmp/csDig"
	else
		notify "✅ Success: SHA-$SHA_OPTION" "All checksums match!"
		echo "Success (SHA-$SHA_OPTION): all checksums match!"
	fi
	exit # ALT: continue

else

	# check if bundle/directory
	if [[ ! -f "$FILEPATH" ]] ; then
		PATH_TYPE=$(/usr/bin/mdls -name kMDItemContentTypeTree "$FILEPATH" | /usr/bin/grep -e "bundle")
		if [[ "$PATH_TYPE" != "" ]] ; then
			notify "💣 Error: target is a bundle" "$FILE"
			exit # ALT: continue
		fi
		if [[ -d "$FILEPATH" ]] ; then
			CONTENT_LIST=$(find "$FILEPATH" -type f -not -path '*/\.*')
			if [[ "$CONTENT_LIST" == "" ]] ; then
				notify "💣 Error: empty directory" "$FILE"
				exit # ALT: continue
			fi
			METHOD="digest"
			# ask for checksums file creation
			SFV_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.Checksums:lcars.png"
	set theButton to button returned of (display dialog "You have selected the directory \"" & "$FILE" & "\". How do you want to proceed?" ¬
		buttons {"Compare Folders", "Calculate Other", "Calculate SFV"} ¬
		default button 3 ¬
		with title "Checksums" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theButton
EOT)
			if [[ "$SFV_CHOICE" == "" ]] || [[ "$SFV_CHOICE" == "false" ]] ; then
				exit # ALT: continue
			fi

			# compare target folder to second one
			if [[ "$SFV_CHOICE" == "Compare Folders" ]] ; then
				CFOLDERPATH=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theStartDirectory to ((path to home folder from user domain) as text) as alias
	set theCFolder to choose folder with prompt "Please select the second folder for comparison…" default location theStartDirectory with invisibles
	set theCFolderPath to (POSIX path of theCFolder)
end tell
theCFolderPath
EOT)
				if [[ "$CFOLDERPATH" == "" ]] || [[ "$CFOLDERPATH" == "false" ]] ; then
					exit # ALT: continue
				fi
				if [[ "$CFOLDERPATH" == "$FILEPATH" ]] ; then
					notify "💣 Error: same directory" "${FILEPATH/$HOME/~}"
					exit # ALT: continue
				fi
				notify "⚠️ Please wait!" "Scanning original directory…"
				cd "$FILEPATH"
				FILES=$(find * -type f -not -path '*/\.DS_Store')
				echo "$FILES" | while read -r LINE
				do
					if [[ "$LINE" == "checksums.crc32" ]] ; then
						continue
					fi
					FCRC=$(/usr/bin/crc32 "$LINE")
					echo "$FCRC $LINE"
				done > "$FILEPATH/checksums.crc32"
				notify "⚠️ Please wait!" "Comparing directories…"
				cd /
				CRCDIG=$(/bin/cat "$FILEPATH/checksums.crc32")
				ERROR=""
				ERROR_COUNT="0"
				while read -r LINE
				do
					COUNTERPART=$(echo "$LINE" | /usr/bin/awk '{print substr($0, index($0,$2))}')
					if [[ ! -f "$CFOLDERPATH/$COUNTERPART" ]] ; then
						ERROR="true"
						((ERROR_COUNT++))
						echo "Missing file: $COUNTERPART"
					else
						ORIGINAL_HASH=$(echo "$LINE" | /usr/bin/awk '{print $1}')
						COUNTERHASH=$(/usr/bin/crc32 "$CFOLDERPATH/$COUNTERPART")
						if [[ "$COUNTERHASH" != "$ORIGINAL_HASH" ]] ; then
							ERROR="true"
							((ERROR_COUNT++))
							echo "Checksum mismatch: $COUNTERPART"
						fi
					fi
				done < <(echo "$CRCDIG") > "$CACHE_DIR/tmp/csDirCompare"
				rm -rf "$FILEPATH/checksums.crc32"
				if [[ "$ERROR" == "true" ]] ; then
					if [[ "$ERROR_COUNT" -gt 1 ]] ; then
						FILE_SIG="files"
					else
						FILE_SIG="file"
					fi
					notify "❌ Failed: CRC-32" "$ERROR_COUNT $FILE_SIG had errors!"
					echo "Failed (CRC-32): $ERROR_COUNT $FILE_SIG had errors!"
					/usr/bin/sort "$CACHE_DIR/tmp/csDirCompare" -o "$CACHE_DIR/tmp/csDirCompare"
					/usr/bin/open -a TextEdit "$CACHE_DIR/tmp/csDirCompare"
				else
					notify "✅ Success" "All checksums match!"
					echo "Success: all checksums match!"
				fi
				exit # ALT: continue

			# create SFV checksums file
			elif [[ "$SFV_CHOICE" == "Calculate SFV" ]] ; then
				notify "⚠️ Please wait!" "Creating SFV checksums file…"
				cd "$FILEPATH"
				FILES=$(find * -type f -not -path '*/\.*')
				echo "$FILES" | while read -r FILE
				do
					if [[ "$FILE" == *".sfv" ]] || [[ "$FILE" == *".md5" ]] || [[ "$FILE" == *".sha1" ]] || [[ "$FILE" == *".sha256" ]] || [[ "$FILE" == *".sha512" ]] || [[ "$FILE" == "checksums.crc32" ]] ; then
						continue
					fi
					/usr/bin/cksum -o 3 "$FILE" 2>/dev/null | while read CK SIZE FILE; do printf "%s %08X\n" "$FILE" "$CK"; done
				done > "$FILEPATH/checksums.sfv"
				cd $HOME
				notify "✅ Done" "checksums.sfv"
				exit # ALT: continue

			# select other digest algorithm
			elif [[ "$SFV_CHOICE" == "Calculate Other" ]] ; then
				DIG_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	set theList to {"MD5","SHA-1","SHA-256","SHA-512"}
	set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
				if [[ "$DIG_CHOICE" == "" ]] || [[ "$DIG_CHOICE" == "false" ]] ; then
					exit # ALT: continue
				fi
				notify "⚠️ Please wait!" "Creating $DIG_CHOICE checksums file…"
				cd "$FILEPATH"
				FILES=$(find * -type f -not -path '*/\.*')
				if [[ "$DIG_CHOICE" == "MD5" ]] ; then
					echo "$FILES" | while read -r FILE
					do
						if [[ "$FILE" == *".sfv" ]] || [[ "$FILE" == *".md5" ]] || [[ "$FILE" == *".sha1" ]] || [[ "$FILE" == *".sha256" ]] || [[ "$FILE" == *".sha512" ]] || [[ "$FILE" == "checksums.crc32" ]] ; then
							continue
						fi
						/sbin/md5 -r "$FILE"
					done > "$FILEPATH/checksums.md5"
					notify "✅ Done" "checksums.md5"
				elif [[ "$DIG_CHOICE" == "SHA-"* ]] ; then
					DIG_SHAOPT=$(echo "$DIG_CHOICE" | /usr/bin/awk -F"-" '{print $2}')
					echo "$FILES" | while read -r FILE
					do
						if [[ "$FILE" == *".sfv" ]] || [[ "$FILE" == *".md5" ]] || [[ "$FILE" == *".sha1" ]] || [[ "$FILE" == *".sha256" ]] || [[ "$FILE" == *".sha512" ]] || [[ "$FILE" == "checksums.crc32" ]] ; then
							continue
						fi
						/usr/bin/shasum -a "$DIG_SHAOPT" "$FILE"
					done > "$FILEPATH/checksums.sha$DIG_SHAOPT"
					notify "✅ Done" "checksums.sha$DIG_SHAOPT"
				fi
				cd $HOME
				exit # ALT: continue
			else
				exit # ALT: continue
			fi
		fi
	fi
fi

if [[ "$METHOD" != "digest" ]] ; then

	CHECKSUM=$(/usr/bin/pbpaste | /usr/bin/xargs 2>/dev/null)
	if [[ "$EXTD" == "native" ]] || [[ "$EXTD" == "bc" ]] || [[ "$EXTD" == "bc-ca" ]] || [[ "$EXTD" == "ca" ]] ; then
		CS_TYPE=$(cscn "$CHECKSUM")
	elif [[ "$EXTD" == "rh" ]] || [[ "$EXTD" == "rh-bc" ]] || [[ "$EXTD" == "rh-bc-ca" ]] || [[ "$EXTD" == "rh-ca" ]] ; then
		CS_TYPE=$(cscx "$CHECKSUM")
	fi

	# calculate file size
	BYTES=$(/usr/bin/stat -f%z "$FILEPATH")
	MEGABYTES=$(bc -l <<< "scale=6; $BYTES/1000000")
	if [[ ($MEGABYTES<1) ]] ; then
		SIZE="0$MEGABYTES"
	else
		SIZE="$MEGABYTES"
	fi
	MIB_RAW=$(/usr/bin/bc -l <<< "scale=6; $BYTES/1048576")
	if [[ ($MIB_RAW<1) ]] ; then
		MIB="0$MIB_RAW"
	else
		MIB="$MIB_RAW"
	fi

	# ask for checksum algorithm, if clipboard is empty
	if [[ "$CS_TYPE" == "false" ]] || [[ "$CS_TYPE" == "" ]] ; then
		METHOD="new"
		CS_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.Checksums:lcars.png"
	set theButton to button returned of (display dialog "You have selected the target \"" & "$FILE" & "\". How do you want to proceed?" ¬
		buttons {"Compare Files", "Calculate Other", "Calculate SHA-256"} ¬
		default button 3 ¬
		with title "Checksums" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theButton
EOT)
		if [[ "$CS_CHOICE" == "" ]] || [[ "$CS_CHOICE" == "false" ]] ; then
			exit # ALT: continue
		fi

		if [[ "$CS_CHOICE" == "Calculate SHA-256" ]] || [[ "$CS_CHOICE" == "Calculate Other" ]] ; then
			METHOD="new"
		elif [[ "$CS_CHOICE" == "Compare Files" ]] ; then
			METHOD="fcompare"
		fi

		# default choice: calculate SHA-256
		if [[ "$CS_CHOICE" == "Calculate SHA-256" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 256 "$FILEPATH" | /usr/bin/awk '{print $1}')
			CS_CHOICE="SHA-256"

		# MD5-compare with a second file
		elif [[ "$CS_CHOICE" == "Compare Files" ]] ; then
			CFILEPATH=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theStartDirectory to ((path to home folder from user domain) as text) as alias
	set theCFile to choose file with prompt "Please select the second file for comparison…" default location theStartDirectory with invisibles
	set theCFilePath to (POSIX path of theCFile)
end tell
theCFilePath
EOT)
			if [[ "$CFILEPATH" == "" ]] || [[ "$CFILEPATH" == "false" ]] ; then
				exit # ALT: continue
			fi
			if [[ "$CFILEPATH" == "$FILEPATH" ]] ; then
				notify "💣 Error: same file" "${FILEPATH/$HOME/~}"
				exit # ALT: continue
			fi
			CPATH_TYPE=$(/usr/bin/mdls -name kMDItemContentTypeTree "$CFILEPATH" | /usr/bin/grep -e "bundle")
			if [[ "$CPATH_TYPE" != "" ]] ; then
				notify "💣 Error: target is a bundle" "$CFILEPATH"
				exit # ALT: continue
			fi
			if [[ -d "$CFILEPATH" ]] ; then
				notify "💣 Error: target is a directory" "$CFILEPATH"
				exit # ALT: continue
			fi
			notify "⚠️ Please wait!" "Comparing files…"
			ALGORITHM="MD5"
			CFILE=$(/usr/bin/basename "$CFILEPATH")
			CBYTES=$(/usr/bin/stat -f%z "$CFILEPATH")
			OHASH=$(/sbin/md5 -q "$FILEPATH")
			CHASH=$(/sbin/md5 -q "$CFILEPATH")
			if [[ "$OHASH" == "$CHASH" ]] ; then
				notify "✅ Success: MD5" "Checksums match"
				STATUS="✅ Success"
			else
				notify "❌ Failed: MD5" "Checksum mismatch"
				STATUS="❌ Failed"
			fi
			HOMEPATH=$(echo $HOME)
			echo "Files:"
			echo "$FILE"
			echo "$CFILE"
			echo "Paths:"
			echo "${FILEPATH/$HOME/~}"
			echo "${CFILEPATH/$HOME/~}"
			echo "Sizes:"
			echo "$BYTES B"
			echo "$CBYTES B"
			echo "Checksums ($ALGORITHM):"
			echo "$OHASH"
			echo "$CHASH"
			echo "Result: $STATUS"
			CPROMPT="■■■ Files ■■■
[1] $FILE
[2] $CFILE

■■■ Paths ■■■
[1] ${FILEPATH/$HOME/~}
[2] ${CFILEPATH/$HOME/~}

■■■ Sizes ■■■
[1] $BYTES B
[2] $CBYTES B

■■■ Verification ■■■
$STATUS

■■■ Checksums [$ALGORITHM] ■■■
[1] $OHASH
[2] $CHASH"
			# create prompt
			CINFO=$(/usr/bin/osascript 2>/dev/null<< EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.Checksums:lcars.png"
	set userChoice to button returned of (display dialog "$CPROMPT" ¬
		buttons {"OK"} ¬
		default button 1 ¬
		with title "Checksums" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
EOT)
			exit # ALT: continue

		# ask for other choice from list
		elif [[ "$CS_CHOICE" == "Calculate Other" ]] ; then
			if [[ "$EXTD" == "native" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	set theList to {"Adler-32","CRC Hashes…","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512"}
	set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			elif [[ "$EXTD" == "rh" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
set theList to {"Adler-32","AICH","BTIH","CRC Hashes…","DC++ TTH","ED2K","EDON-R 256","EDON-R 512","GOST","GOST CryptoPro","HAS-160","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512","SHA3-224","SHA3-256","SHA3-384","SHA3-512","SNEFRU-128","SNEFRU-256","Tiger","Whirlpool"}
set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			elif [[ "$EXTD" == "bc" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	set theList to {"Adler-32","Bencode","CRC (BSD)","CRC Hashes…","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512"}
	set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			elif [[ "$EXTD" == "ca" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	set theList to {"Adler-32","CRC (BSD)","CRC Hashes…","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512"}
	set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			elif [[ "$EXTD" == "rh-bc" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
set theList to {"Adler-32","AICH","Bencode","BTIH","CRC Hashes…","DC++ TTH","ED2K","EDON-R 256","EDON-R 512","GOST","GOST CryptoPro","HAS-160","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512","SHA3-224","SHA3-256","SHA3-384","SHA3-512","SNEFRU-128","SNEFRU-256","Tiger","Whirlpool"}
set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			elif [[ "$EXTD" == "rh-bc-ca" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
set theList to {"Adler-32","AICH","Bencode","BTIH","CRC Hashes…","DC++ TTH","ED2K","EDON-R 256","EDON-R 512","GOST","GOST CryptoPro","HAS-160","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512","SHA3-224","SHA3-256","SHA3-384","SHA3-512","SNEFRU-128","SNEFRU-256","Tiger","Whirlpool"}
set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			elif [[ "$EXTD" == "rh-ca" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
set theList to {"Adler-32","AICH","BTIH","CRC Hashes…","DC++ TTH","ED2K","EDON-R 256","EDON-R 512","GOST","GOST CryptoPro","HAS-160","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512","SHA3-224","SHA3-256","SHA3-384","SHA3-512","SNEFRU-128","SNEFRU-256","Tiger","Whirlpool"}
set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			elif [[ "$EXTD" == "bc-ca" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	set theList to {"Adler-32","Bencode","CRC Hashes…","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512"}
	set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			fi
			if [[ "$HA_CHOICE" == "" ]] || [[ "$HA_CHOICE" == "false" ]] ; then
				exit # ALT: continue
			fi

			if [[ "$HA_CHOICE" == "CRC Hashes…" ]] ; then
				if [[ $(echo "$EXTD" | /usr/bin/grep "ca") != "" ]] ; then
					HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	set theList to {"CRC (BSD)","CRC (System V)","CRC (legacy 32bit)","CRC (ISO/IEC 8802-3)","CRC-32","CRC-32C (Hex)"}
	set theResult to choose from list theList with prompt "Please select the CRC hash." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
				else
					HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	set theList to {"CRC (BSD)","CRC (System V)","CRC (legacy 32bit)","CRC (ISO/IEC 8802-3)","CRC-32"}
	set theResult to choose from list theList with prompt "Please select the CRC hash." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
				fi
				if [[ "$HA_CHOICE" == "" ]] || [[ "$HA_CHOICE" == "false" ]] ; then
					exit # ALT: continue
				fi
			fi

			# calculate checksum based on user choice (native)
			if [[ "$HA_CHOICE" == "SHA-"* ]] && [[ "$HA_CHOICE" != "SHA-0" ]] ; then
				OPTION=$(echo "$HA_CHOICE" | /usr/bin/awk -F"-" '{print $2}')
				FILESUM=$(/usr/bin/shasum -a "$OPTION" "$FILEPATH" | /usr/bin/awk '{print $1}')

			elif [[ "$HA_CHOICE" == "MD5" ]] ; then
				FILESUM=$(/sbin/md5 -q "$FILEPATH")

			elif [[ "$HA_CHOICE" == "MDC-2" ]] ; then
				FILESUM=$(/usr/bin/openssl dgst -mdc2 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')

			elif [[ "$HA_CHOICE" == "RIPEMD-160" ]] ; then
				FILESUM=$(/usr/bin/openssl dgst -ripemd160 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')

			elif [[ "$HA_CHOICE" == "CRC-32" ]] ; then
				FILESUM=$(/usr/bin/crc32 "$FILEPATH")

			elif [[ "$HA_CHOICE" == "Adler-32" ]] ; then
				FILESUM=$(/usr/bin/python "$BIN_DIR/adler32.py" "$FILEPATH" | /usr/bin/awk '{print $1}')

			elif [[ "$HA_CHOICE" == "SHA-0" ]] ; then
				FILESUM=$(/usr/bin/openssl dgst -sha "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')

			elif [[ "$HA_CHOICE" == "MD2" ]] ; then # MD2 option currently not included in osascript list due to openssl bug on macOS
				FILESUM=$(/usr/bin/openssl dgst -md2 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')

			elif [[ "$HA_CHOICE" == "MD4" ]] ; then
				FILESUM=$(/usr/bin/openssl dgst -md4 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')

			elif [[ "$HA_CHOICE" == "CRC (ISO/IEC 8802-3)" ]] ; then
				FILESUM=$(/usr/bin/cksum "$FILEPATH" | /usr/bin/awk '{print $1}')

			elif [[ "$HA_CHOICE" == "CRC (legacy 32bit)" ]] ; then
				FILESUM=$(/usr/bin/cksum -o 3 "$FILEPATH" | /usr/bin/awk '{print $1}')

			elif [[ "$HA_CHOICE" == "CRC (BSD)" ]] ; then
				FILESUM=$(/usr/bin/cksum -o 1 "$FILEPATH" | /usr/bin/awk '{print $1}')

			elif [[ "$HA_CHOICE" == "CRC (System V)" ]] ; then
				FILESUM=$(/usr/bin/cksum -o 2 "$FILEPATH" | /usr/bin/awk '{print $1}')

			fi

			# calculate checksum based on user choice (transmission-show)
			if [[ $(echo "$EXTD" | /usr/bin/grep "bc") != "" ]] ; then
				if [[ "$HA_CHOICE" == "Bencode" ]] ; then
					FILESUM=$("$TRANSM" "$FILEPATH" 2>&1 | /usr/bin/grep "Hash: " | /usr/bin/awk '{print $2}')
					if [[ "$FILESUM" == "Error"* ]] || [[ "$FILESUM" == "" ]] ; then
						notify "💣 Error [Bencode]" "Target possibly not a torrent file"
						exit # ALT: continue
					fi
				fi
			fi

			# calculate checksum based on user choice (gsutil)
			if [[ "$HA_CHOICE" == "CRC-32C (Hex)" ]] ; then
				FILESUM=$("$GSUTIL" hash -c -h "$FILEPATH" 2>&1 | /usr/bin/grep "Hash (crc32c)" | /usr/bin/awk -F: '{print $2}' | /usr/bin/xargs)
				if [[ "$FILESUM" == "CommandException"* ]] || [[ "$FILESUM" == "" ]] ; then
					notify "💣 Error [Bencode]" "Target possibly not a torrent file"
					exit # ALT: continue
				fi
			fi

			# calculate checksum based on user choice (rhash or rhash plus transmission-show)
			if [[ "$EXTD" == "rh" ]] || [[ "$EXTD" == "rh-bc" ]] ; then

				if [[ "$HA_CHOICE" == "SHA3-"* ]] ; then
					OPTION=$(echo "$HA_CHOICE" | /usr/bin/awk -F"-" '{print $2}')
					FILESUM=$("$RHASH" --sha3-$OPTION "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "AICH" ]] ; then
					FILESUM=$("$RHASH" -A "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "BTIH" ]] ; then
					FILESUM=$("$RHASH" --btih "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "DC++ TTH" ]] ; then
					FILESUM=$("$RHASH" -T "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "ED2K" ]] ; then
					FILESUM=$("$RHASH" -E "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "EDON-R 256" ]] ; then
					FILESUM=$("$RHASH" --edonr256 "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "EDON-R 512" ]] ; then
					FILESUM=$("$RHASH" --edonr512 "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "GOST" ]] ; then
					FILESUM=$("$RHASH" -G "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "GOST CryptoPro" ]] ; then
					FILESUM=$("$RHASH" --gost-cryptopro "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "HAS-160" ]] ; then
					FILESUM=$("$RHASH" --has160 "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "SNEFRU-128" ]] ; then
					FILESUM=$("$RHASH" --snefru128 "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "SNEFRU-256" ]] ; then
					FILESUM=$("$RHASH" --snefru256 "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "Tiger" ]] ; then
					FILESUM=$("$RHASH" --tiger "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "Whirlpool" ]] ; then
					FILESUM=$("$RHASH" -W "$FILEPATH" | /usr/bin/awk '{print $1}')

				elif [[ "$HA_CHOICE" == "Bencode" ]] ; then
					FILESUM=$("$TRANSM" "$FILEPATH" 2>&1 | /usr/bin/grep "Hash: " | /usr/bin/awk '{print $2}')
					if [[ "$FILESUM" == "Error"* ]] || [[ "$FILESUM" == "" ]] ; then
						notify "💣 Error [Bencode]" "Target possibly not a torrent file"
						exit # ALT: continue
					fi
				fi
			fi

			CS_CHOICE="$HA_CHOICE"
		fi

		# output for new calculation
		echo "File: $FILE"
		echo "Size: $BYTES B [$SIZE MB] [$MIB MiB]"
		echo "Checksum [$CS_CHOICE]: $FILESUM"
		OSA_PROMPT="■■■ File ■■■
$FILE

■■■ Size ■■■
$BYTES B
$SIZE MB
$MIB MiB

■■■ Checksum [$CS_CHOICE] ■■■
$FILESUM

The information has also been copied to your clipboard."

		# set copy info for clipboard & copy
		COPY_INFO="Name: $FILE
Size: $BYTES B [$SIZE MB] [$MIB MiB]
Checksum [$CS_CHOICE]: $FILESUM"
		echo "$COPY_INFO" | /usr/bin/pbcopy
	else
		METHOD="compare"
	fi

	if [[ "$METHOD" == "compare" ]] ; then

		# clipboard has an apparent checksum

		# calculate BSD/Unix & legacy CRC checksums
		if [[ "$CS_TYPE" == "cksum-unix" ]] ; then
			FILESUM=$(/usr/bin/cksum -o 1 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
				ALGORITHM="CRC (BSD)"
			else
				FILESUM=$(/usr/bin/cksum -o 2 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="CRC (System V)"
				else
					STATUS="❌ Failed"
					ALGORITHM="Legacy Unix CRC class"
					FILESUM="💣 n/a"
				fi
			fi
		elif [[ "$CS_TYPE" == "cksum3" ]] ; then
			ALGORITHM="CRC (legacy 32bit)"
			FILESUM=$(/usr/bin/cksum -o 3 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
			else
				STATUS="❌ Failed"
				FILESUM="💣 n/a"
			fi
		elif [[ "$CS_TYPE" == "cksum-modern" ]] ; then
			ALGORITHM="CRC (ISO/IEC 8802-3)"
			FILESUM=$(/usr/bin/cksum "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
			else
				STATUS="❌ Failed"
				FILESUM="💣 n/a"
			fi

		# calculate CRC-32 & Adler-32
		elif [[ "$CS_TYPE" == "crc" ]] ; then
			FILESUM=$(/usr/bin/crc32 "$FILEPATH")
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="CRC-32"
				STATUS="✅ Success"
			else
				FILESUM=$(/usr/bin/python "$BIN_DIR/adler32.py" "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					ALGORITHM="Adler-32"
					STATUS="✅ Success"
				else
					if [[ $(echo "$EXTD" | /usr/bin/grep "ca") != "" ]] ; then
						FILESUM=$("$GSUTIL" hash -c -h "$FILEPATH" 2>&1 | /usr/bin/grep "Hash (crc32c)" | /usr/bin/awk -F: '{print $2}' | /usr/bin/xargs)
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							ALGORITHM="CRC-32C (Hex)"
							STATUS="✅ Success"
						else
							ALGORITHM="CRC/Adler-32"
							STATUS="❌ Failed"
							FILESUM="💣 n/a"
						fi
					else
						ALGORITHM="CRC/Adler-32"
						STATUS="❌ Failed"
						FILESUM="💣 n/a"
					fi
				fi
			fi

		# calculate MD-class: MD5, MDC-2, MD4
		elif [[ "$CS_TYPE" == "md" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/sbin/md5 -q "$FILEPATH")
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
				ALGORITHM="MD5"
			else
				FILESUM=$(/usr/bin/openssl dgst -mdc2 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="MDC-2"
				else
					FILESUM=$(/usr/bin/openssl dgst -md4 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="✅ Success"
						ALGORITHM="MD4"
					else
						STATUS="❌ Failed"
						ALGORITHM="MD-length"
						FILESUM="💣 n/a"
					fi
				fi
			fi
		elif [[ "$CS_TYPE" == "md" ]] && [[ "$EXTD" == "rh"* ]] ; then
			FILESUM=$(/sbin/md5 -q "$FILEPATH")
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
				ALGORITHM="MD5"
			else
				FILESUM=$(/usr/bin/openssl dgst -mdc2 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="MDC-2"
				else
					FILESUM=$(/usr/bin/openssl dgst -md4 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="✅ Success"
						ALGORITHM="MD4"
					else
						FILESUM=$("$RHASH" --snefru128 "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="✅ Success"
							ALGORITHM="SNEFRU-128"
						else
							FILESUM=$("$RHASH" -E "$FILEPATH" | /usr/bin/awk '{print $1}')
							if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
								STATUS="✅ Success"
								ALGORITHM="ED2K"
							else
								STATUS="❌ Failed"
								ALGORITHM="MD-length"
								FILESUM="💣 n/a"
							fi
						fi
					fi
				fi
			fi

		# calculate SHA-class: SHA-1, RIPEMD-160, SHA-0
		elif [[ "$CS_TYPE" == "sha" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 1 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
				ALGORITHM="SHA-1"
			else
				FILESUM=$(/usr/bin/openssl dgst -ripemd160 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="RIPEMD-160"
				else
					FILESUM=$(/usr/bin/openssl dgst -sha "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="✅ Success"
						ALGORITHM="SHA-0"
					else
						STATUS="❌ Failed"
						ALGORITHM="SHA-length"
						FILESUM="💣 n/a"
					fi
				fi
			fi
		elif [[ "$CS_TYPE" == "sha" ]] && [[ "$EXTD" == "rh" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 1 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
				ALGORITHM="SHA-1"
			else
				FILESUM=$(/usr/bin/openssl dgst -ripemd160 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="RIPEMD-160"
				else
					FILESUM=$(/usr/bin/openssl dgst -sha "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="✅ Success"
						ALGORITHM="SHA-0"
					else
						FILESUM=$("$RHASH" --has160 "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="✅ Success"
							ALGORITHM="HAS-160"
						else
							FILESUM=$("$RHASH" --btih "$FILEPATH" | /usr/bin/awk '{print $1}')
							if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
								STATUS="✅ Success"
								ALGORITHM="BTIH"
							else
								STATUS="❌ Failed"
								ALGORITHM="SHA-length"
								FILESUM="💣 n/a"
							fi
						fi
					fi
				fi
			fi
		elif [[ "$CS_TYPE" == "sha" ]] && [[ "$EXTD" == "bc" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 1 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
				ALGORITHM="SHA-1"
			else
				FILESUM=$(/usr/bin/openssl dgst -ripemd160 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="RIPEMD-160"
				else
					FILESUM=$(/usr/bin/openssl dgst -sha "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="✅ Success"
						ALGORITHM="SHA-0"
					else
						FILESUM=$("$TRANSM" "$FILEPATH" 2>&1 | /usr/bin/grep "Hash: " | /usr/bin/awk '{print $2}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="✅ Success"
							ALGORITHM="Bencode"
						else
							STATUS="❌ Failed"
							ALGORITHM="SHA-length"
							FILESUM="💣 n/a"
						fi
					fi
				fi
			fi
		elif [[ "$CS_TYPE" == "sha" ]] && [[ "$EXTD" == "rh-bc" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 1 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
				ALGORITHM="SHA-1"
			else
				FILESUM=$(/usr/bin/openssl dgst -ripemd160 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="RIPEMD-160"
				else
					FILESUM=$(/usr/bin/openssl dgst -sha "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="✅ Success"
						ALGORITHM="SHA-0"
					else
						FILESUM=$("$RHASH" --has160 "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="✅ Success"
							ALGORITHM="HAS-160"
						else
							FILESUM=$("$RHASH" --btih "$FILEPATH" | /usr/bin/awk '{print $1}')
							if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
								STATUS="✅ Success"
								ALGORITHM="BTIH"
							else
								FILESUM=$("$TRANSM" "$FILEPATH" 2>&1 | /usr/bin/grep "Hash: " | /usr/bin/awk '{print $2}')
								if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
									STATUS="✅ Success"
									ALGORITHM="Bencode"
								else
									STATUS="❌ Failed"
									ALGORITHM="SHA-length"
									FILESUM="💣 n/a"
								fi
							fi
						fi
					fi
				fi
			fi

		# calculate Tiger
		elif [[ "$CS_TYPE" == "tiger" ]] ; then
			FILESUM=$("$RHASH" --tiger "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="✅ Success"
				ALGORITHM="Tiger"
			else
				STATUS="❌ Failed"
				ALGORITHM="Tiger"
				FILESUM="💣 n/a"
			fi

		# calculate SHA2-length 224
		elif [[ "$CS_TYPE" == "224" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 224 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-224"
				STATUS="✅ Success"
			else
				STATUS="❌ Failed"
				ALGORITHM="SHA-224"
				FILESUM="💣 n/a"
			fi
		elif [[ "$CS_TYPE" == "224" ]] && [[ "$EXTD" == "rh"* ]] ; then
			FILESUM=$(/usr/bin/shasum -a 224 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-224"
				STATUS="✅ Success"
			else
				FILESUM=$("$RHASH" --sha3-224 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="SHA3-224"
				else
					ALGORITHM="SHA224-length"
					STATUS="❌ Failed"
					FILESUM="💣 n/a"
				fi
			fi

		# calculate SHA2-length 256
		elif [[ "$CS_TYPE" == "256" ]] && [[ "$EXTD" == "native" ]] ; then
		FILESUM=$(/usr/bin/shasum -a 256 "$FILEPATH" | /usr/bin/awk '{print $1}')
		if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
			ALGORITHM="SHA-256"
			STATUS="✅ Success"
		else
			ALGORITHM="SHA256"
			STATUS="❌ Failed"
			FILESUM="💣 n/a"
		fi
		elif [[ "$CS_TYPE" == "256" ]] && [[ "$EXTD" == "rh"* ]] ; then
			FILESUM=$(/usr/bin/shasum -a 256 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-256"
				STATUS="✅ Success"
			else
				FILESUM=$("$RHASH" --sha3-256 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="SHA3-256"
				else
					FILESUM=$("$RHASH" -G "$FILEPATH" | /usr/bin/awk '{print $1}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="✅ Success"
						ALGORITHM="GOST"
					else
						FILESUM=$("$RHASH" --gost-cryptopro "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="✅ Success"
							ALGORITHM="GOST CryptoPro"
						else
							FILESUM=$("$RHASH" --snefru256 "$FILEPATH" | /usr/bin/awk '{print $1}')
							if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
								STATUS="✅ Success"
								ALGORITHM="SNEFRU-256"
							else
								FILESUM=$("$RHASH" --edonr256 "$FILEPATH" | /usr/bin/awk '{print $1}')
								if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
									STATUS="✅ Success"
									ALGORITHM="EDON-R 256"
								else
									ALGORITHM="SHA256-length"
									STATUS="❌ Failed"
									FILESUM="💣 n/a"
								fi
							fi
						fi
					fi
				fi
			fi

		# calculate SHA2-length 384
		elif [[ "$CS_TYPE" == "384" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 384 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-384"
				STATUS="✅ Success"
			else
				ALGORITHM="SHA-384"
				STATUS="❌ Failed"
				FILESUM="💣 n/a"
			fi
		elif [[ "$CS_TYPE" == "384" ]] && [[ "$EXTD" == "rh"* ]] ; then
			FILESUM=$(/usr/bin/shasum -a 384 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-384"
				STATUS="✅ Success"
			else
				FILESUM=$("$RHASH" --sha3-384 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="SHA3-384"
				else
					ALGORITHM="SHA384-length"
					STATUS="❌ Failed"
					FILESUM="💣 n/a"
				fi
			fi

		# calculate SHA2-length 512
		elif [[ "$CS_TYPE" == "512" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 512 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-512"
				STATUS="✅ Success"
			else
				ALGORITHM="SHA-512"
				STATUS="❌ Failed"
				FILESUM="💣 n/a"
			fi
		elif [[ "$CS_TYPE" == "512" ]] && [[ "$EXTD" == "rh"* ]] ; then
			FILESUM=$(/usr/bin/shasum -a 512 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-512"
				STATUS="✅ Success"
			else
				FILESUM=$("$RHASH" --sha3-512 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="✅ Success"
					ALGORITHM="SHA3-512"
				else
					FILESUM=$("$RHASH" -W "$FILEPATH" | /usr/bin/awk '{print $1}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="✅ Success"
						ALGORITHM="Whirlpool"
					else
						FILESUM=$("$RHASH" --edonr512 "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="✅ Success"
							ALGORITHM="EDON-R 512"
						else
							STATUS="❌ Failed"
							ALGORITHM="SHA512-length"
							FILESUM="💣 n/a"
						fi
					fi
				fi
			fi
		fi

		# output for checksum comparison
		notify "$STATUS [$ALGORITHM]" "$FILE"
		echo "File: $FILE"
		echo "Size: $BYTES B [$SIZE MB] [$MIB MiB]"
		echo "Verification [$ALGORITHM]: $STATUS"
		echo "$FILESUM [calculated]"
		echo "$CHECKSUM [clipboard]"
		OSA_PROMPT="■■■ File ■■■
$FILE

■■■ Size ■■■
$BYTES B
$SIZE MB
$MIB MiB

■■■ Verification ■■■
$STATUS [$ALGORITHM]

■■■ Checksums ■■■
➤ Clipboard checksum
$CHECKSUM

➤ Calculated checksum
$FILESUM"

	fi

	# create prompt
	INFO=$(/usr/bin/osascript 2>/dev/null<< EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.Checksums:lcars.png"
	set userChoice to button returned of (display dialog "$OSA_PROMPT" ¬
		buttons {"OK"} ¬
		default button 1 ¬
		with title "Checksums" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
EOT)

fi

# ALT: done

updater
