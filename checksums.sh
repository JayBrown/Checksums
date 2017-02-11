#!/bin/bash

# Checksums v1.2.1
# Checksums (shell script version)

# minimum compatibility: native macOS checksum algorithms
# for the extended algorithms, e.g. SHA-3, please install the rhash program

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
ACCOUNT=$(/usr/bin/id -un)
CURRENT_VERSION="1.21"

# clipboard checksum parsing
cscn () {
	case $1 in
		( *[!0-9A-Fa-f]* | "" ) echo "false" ;;
		( * )
			case ${#1} in
				( 8 ) echo "crc" ;;
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
				( 8 ) echo "crc" ;;
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

# look for terminal-notifier
TERMNOTE_LOC=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | /usr/bin/awk 'NR==1')
if [[ "$TERMNOTE_LOC" == "" ]] ; then
	NOTESTATUS="osa"
else
	NOTESTATUS="tn"
fi

# check if rhash is present
RHASH=$(which rhash 2>/dev/null)
if [[ "$RHASH" != "/"*"/rhash" ]] ; then
	RHASH_STATUS="false"
else
	RHASH_STATUS="true"
fi
if [[ "$RHASH_STATUS" == "true" ]] ; then
	EXTD="rh"
else
	EXTD="native"
fi

FILEPATH="$1" # ALT: delete for workflow

# ALT: for FILEPATH in "$@"
# ALT: do

	FILE=$(/usr/bin/basename "$FILEPATH")
	METHOD=""

	# check if bundle/directory
	if [[ ! -f "$FILEPATH" ]] ; then
		PATH_TYPE=$(/usr/bin/mdls -name kMDItemContentTypeTree "$FILEPATH" | /usr/bin/grep -e "bundle")
		if [[ "$PATH_TYPE" != "" ]] ; then
			notify "Error: target is a bundle" "$FILE"
			exit # ALT: continue
		fi
		if [[ -d "$FILEPATH" ]] ; then
			notify "Error: target is a directory" "$FILE"
			exit # ALT: continue
		fi
	fi

	CHECKSUM=$(/usr/bin/pbpaste | /usr/bin/xargs)
	if [[ "$EXTD" == "native" ]] ; then
		CS_TYPE=$(cscn "$CHECKSUM")
	elif [[ "$EXTD" == "rh" ]] ; then
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

	# ask for checksum algorithm, if clipboard is empty
	if [[ "$CS_TYPE" == "false" ]] || [[ "$CS_TYPE" == "" ]] ; then
		METHOD="new"
		CS_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.Checksums:lcars.png"
	set theButton to button returned of (display dialog "You are about to calculate the checksum for \"" & "$FILE" & "\". Please select the algorithm." ¬
		buttons {"Cancel", "Other", "SHA-256"} ¬
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

		# default choice: calculate SHA-256
		if [[ "$CS_CHOICE" == "SHA-256" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 256 "$FILEPATH" | /usr/bin/awk '{print $1}')
		else
			# ask for other choice from list
			if [[ "$EXTD" == "native" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	set theList to {"CRC-32","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512"}
	set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			elif [[ "$EXTD" == "rh" ]] ; then
				HA_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
set theList to {"AICH","BTIH","CRC-32","DC++ TTH","ED2K","EDON-R 256","EDON-R 512","GOST","GOST CryptoPro","HAS-160","MD4","MD5","MDC-2","RIPEMD-160","SHA-0","SHA-1","SHA-224","SHA-256","SHA-384","SHA-512","SHA3-224","SHA3-256","SHA3-384","SHA3-512","SNEFRU-128","SNEFRU-256","Tiger","Whirlpool"}
set theResult to choose from list theList with prompt "Please select the algorithm." with title "Checksums" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
end tell
theResult
EOT)
			fi
			if [[ "$HA_CHOICE" == "" ]] || [[ "$HA_CHOICE" == "false" ]] ; then
				exit # ALT: continue
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

			elif [[ "$HA_CHOICE" == "SHA-0" ]] ; then
				FILESUM=$(/usr/bin/openssl dgst -sha "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')

			elif [[ "$HA_CHOICE" == "MD2" ]] ; then # MD2 option currently not included in osascript list due to openssl bug on macOS
				FILESUM=$(/usr/bin/openssl dgst -md2 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')

			elif [[ "$HA_CHOICE" == "MD4" ]] ; then
				FILESUM=$(/usr/bin/openssl dgst -md4 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')

			fi

			# calculate checksum based on user choice (rhash)
			if [[ "$EXTD" == "rh" ]] ; then

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

				fi
			fi

			CS_CHOICE="$HA_CHOICE"
		fi

		# output for new calculation
		echo "File: $FILE"
		echo "Size: $SIZE MB"
		echo "Checksum [$CS_CHOICE]: $FILESUM"
		OSA_PROMPT="■■■ File ■■■
$FILE

■■■ Size ■■■
$SIZE MB

■■■ Checksum [$CS_CHOICE] ■■■
$FILESUM

The information has also been copied to your clipboard."

		# set copy info for clipboard & copy
		COPY_INFO="Name: $FILE
Size: $SIZE MB
Checksum [$CS_CHOICE]: $FILESUM"
		echo "$COPY_INFO" | /usr/bin/pbcopy
	else
		METHOD="compare"
	fi

	if [[ "$METHOD" == "compare" ]] ; then

		# clipboard has an apparent checksum

		# calculate CRC-32
		if [[ "$CS_TYPE" == "crc" ]] ; then
			ALGORITHM="CRC-32"
			FILESUM=$(/usr/bin/crc32 "$FILEPATH")
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="success"
			else
				STATUS="failed"
			fi

		# calculate MD-class: MD5, MDC-2, MD4
		elif [[ "$CS_TYPE" == "md" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/sbin/md5 -q "$FILEPATH")
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="success"
				ALGORITHM="MD5"
			else
				FILESUM=$(/usr/bin/openssl dgst -mdc2 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="success"
					ALGORITHM="MDC-2"
				else
					FILESUM=$(/usr/bin/openssl dgst -md4 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="success"
						ALGORITHM="MD4"
					else
						STATUS="failed"
						ALGORITHM="MD-length"
						FILESUM="n/a"
					fi
				fi
			fi
		elif [[ "$CS_TYPE" == "md" ]] && [[ "$EXTD" == "rh" ]] ; then
			FILESUM=$(/sbin/md5 -q "$FILEPATH")
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="success"
				ALGORITHM="MD5"
			else
				FILESUM=$(/usr/bin/openssl dgst -mdc2 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="success"
					ALGORITHM="MDC-2"
				else
					FILESUM=$(/usr/bin/openssl dgst -md4 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="success"
						ALGORITHM="MD4"
					else
						FILESUM=$("$RHASH" --snefru128 "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="success"
							ALGORITHM="SNEFRU-128"
						else
							FILESUM=$("$RHASH" -E "$FILEPATH" | /usr/bin/awk '{print $1}')
							if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
								STATUS="success"
								ALGORITHM="ED2K"
							else
								STATUS="failed"
								ALGORITHM="MD-length"
								FILESUM="n/a"
							fi
						fi
					fi
				fi
			fi

		# calculate SHA-class: SHA-1, RIPEMD-160, SHA-0
		elif [[ "$CS_TYPE" == "sha" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 1 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="success"
				ALGORITHM="SHA-1"
			else
				FILESUM=$(/usr/bin/openssl dgst -ripemd160 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="success"
					ALGORITHM="RIPEMD-160"
				else
					FILESUM=$(/usr/bin/openssl dgst -sha "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="success"
						ALGORITHM="SHA-0"
					else
						STATUS="failed"
						ALGORITHM="SHA-length"
						FILESUM="n/a"
					fi
				fi
			fi
		elif [[ "$CS_TYPE" == "sha" ]] && [[ "$EXTD" == "rh" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 1 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="success"
				ALGORITHM="SHA-1"
			else
				FILESUM=$(/usr/bin/openssl dgst -ripemd160 "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="success"
					ALGORITHM="RIPEMD-160"
				else
					FILESUM=$(/usr/bin/openssl dgst -sha "$FILEPATH" | /usr/bin/awk -F"= " '{print $2}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="success"
						ALGORITHM="SHA-0"
					else
						FILESUM=$("$RHASH" --has160 "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="success"
							ALGORITHM="HAS-160"
						else
							FILESUM=$("$RHASH" --btih "$FILEPATH" | /usr/bin/awk '{print $1}')
							if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
								STATUS="success"
								ALGORITHM="BTIH"
							else
								STATUS="failed"
								ALGORITHM="SHA-length"
								FILESUM="n/a"
							fi
						fi
					fi
				fi
			fi

		# calculate Tiger
		elif [[ "$CS_TYPE" == "tiger" ]] ; then
			FILESUM=$("$RHASH" --tiger "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				STATUS="success"
				ALGORITHM="Tiger"
			else
				STATUS="failed"
				ALGORITHM="Tiger"
				FILESUM="n/a"
			fi

		# calculate SHA2-length 224
		elif [[ "$CS_TYPE" == "224" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 224 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-224"
				STATUS="success"
			else
				STATUS="failed"
				ALGORITHM="SHA-224"
				FILESUM="n/a"
			fi
		elif [[ "$CS_TYPE" == "224" ]] && [[ "$EXTD" == "rh" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 224 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-224"
				STATUS="success"
			else
				FILESUM=$("$RHASH" --sha3-224 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="success"
					ALGORITHM="SHA3-224"
				else
					ALGORITHM="SHA224-length"
					STATUS="failed"
					FILESUM="n/a"
				fi
			fi

		# calculate SHA2-length 256
		elif [[ "$CS_TYPE" == "256" ]] && [[ "$EXTD" == "native" ]] ; then
		FILESUM=$(/usr/bin/shasum -a 256 "$FILEPATH" | /usr/bin/awk '{print $1}')
		if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
			ALGORITHM="SHA-256"
			STATUS="success"
		else
			ALGORITHM="SHA256"
			STATUS="failed"
			FILESUM="n/a"
		fi
		elif [[ "$CS_TYPE" == "256" ]] && [[ "$EXTD" == "rh" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 256 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-256"
				STATUS="success"
			else
				FILESUM=$("$RHASH" --sha3-256 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="success"
					ALGORITHM="SHA3-256"
				else
					FILESUM=$("$RHASH" -G "$FILEPATH" | /usr/bin/awk '{print $1}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="success"
						ALGORITHM="GOST"
					else
						FILESUM=$("$RHASH" --gost-cryptopro "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="success"
							ALGORITHM="GOST CryptoPro"
						else
							FILESUM=$("$RHASH" --snefru256 "$FILEPATH" | /usr/bin/awk '{print $1}')
							if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
								STATUS="success"
								ALGORITHM="SNEFRU-256"
							else
								FILESUM=$("$RHASH" --edonr256 "$FILEPATH" | /usr/bin/awk '{print $1}')
								if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
									STATUS="success"
									ALGORITHM="EDON-R 256"
								else
									ALGORITHM="SHA256-length"
									STATUS="failed"
									FILESUM="n/a"
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
				STATUS="success"
			else
				ALGORITHM="SHA-384"
				STATUS="failed"
				FILESUM="n/a"
			fi
		elif [[ "$CS_TYPE" == "384" ]] && [[ "$EXTD" == "rh" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 384 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-384"
				STATUS="success"
			else
				FILESUM=$("$RHASH" --sha3-384 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="success"
					ALGORITHM="SHA3-384"
				else
					ALGORITHM="SHA384-length"
					STATUS="failed"
					FILESUM="n/a"
				fi
			fi

		# calculate SHA2-length 512
		elif [[ "$CS_TYPE" == "512" ]] && [[ "$EXTD" == "native" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 512 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-512"
				STATUS="success"
			else
				ALGORITHM="SHA-512"
				STATUS="failed"
				FILESUM="n/a"
			fi
		elif [[ "$CS_TYPE" == "512" ]] && [[ "$EXTD" == "rh" ]] ; then
			FILESUM=$(/usr/bin/shasum -a 512 "$FILEPATH" | /usr/bin/awk '{print $1}')
			if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
				ALGORITHM="SHA-512"
				STATUS="success"
			else
				FILESUM=$("$RHASH" --sha3-512 "$FILEPATH" | /usr/bin/awk '{print $1}')
				if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
					STATUS="success"
					ALGORITHM="SHA3-512"
				else
					FILESUM=$("$RHASH" -W "$FILEPATH" | /usr/bin/awk '{print $1}')
					if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
						STATUS="success"
						ALGORITHM="Whirlpool"
					else
						FILESUM=$("$RHASH" --edonr512 "$FILEPATH" | /usr/bin/awk '{print $1}')
						if [[ "$FILESUM" == "$CHECKSUM" ]] ; then
							STATUS="success"
							ALGORITHM="EDON-R 512"
						else
							STATUS="failed"
							ALGORITHM="SHA512-length"
							FILESUM="n/a"
						fi
					fi
				fi
			fi
		fi

		# output for checksum comparison
		notify "$ALGORITHM: $STATUS" "$FILE"
		echo "File: $FILE"
		echo "Size: $SIZE MB"
		echo "Verification [$ALGORITHM]: $STATUS"
		echo "$FILESUM [calculated]"
		echo "$CHECKSUM [clipboard]"
		OSA_PROMPT="■■■ File ■■■
$FILE

■■■ Size ■■■
$SIZE MB

■■■ Verification ■■■
$ALGORITHM: $STATUS

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

# ALT: done

# check for update
NEWEST_VERSION=$(/usr/bin/curl --silent https://api.github.com/repos/JayBrown/Checksums/releases/latest | /usr/bin/awk '/tag_name/ {print $2}' | xargs)
if [[ "$NEWEST_VERSION" == "" ]] ; then
	NEWEST_VERSION="0"
fi
NEWEST_VERSION=${NEWEST_VERSION//,}
if (( $(echo "$NEWEST_VERSION > $CURRENT_VERSION" | /usr/bin/bc -l) )) ; then
	notify "Update available" "Checksums v$NEWEST_VERSION"
	/usr/bin/open "https://github.com/JayBrown/Checksums/releases/latest"
fi
