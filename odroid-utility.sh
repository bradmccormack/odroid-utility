#!/bin/bash

# ODROID Utility v2

# For debug uncomment
# set -x

# Global defines
_B="/usr/local/bin"
_CUR_VER="1.4"


# Allow overriding of updates
BOOTSTRAP="${BOOTSTRAP:=1}"
INTERNALS="${INTERNALS:=1}"

initialization() {

		if [ `whoami` != "root" ]; then
			echo "You must run the app as root."
			echo "sudo $0"
			exit 0
		fi

        # check what distro we are runnig.
        _R=`lsb_release -i -s`

        case "$_R" in
                "Ubuntu")
                        export DISTRO="ubuntu"
                        ;;
                "Debian")
			export DISTRO="debian"
			;;
                *)
                        echo "I couldn't identify your distribution."
                        echo "Please report this error on the forums"
                        echo "http://forum.odroid.com"
                        echo "debug info: "
                        lsb_release -a
                        exit 0
                        ;;
                esac

        # now that we know what we are running, lets grab all the OS Packages that we need.
	if [ $BOOTSTRAP -eq 1 ]; then
		install_bootstrap_packages
     		fi

	if [ $INTERNALS -eq 1 ]; then
		update_internals
	fi

	#Update version information	

	SOURCE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
		
	GITHUB_REV=`curl -s https://api.github.com/repos/mdrjr/odroid-utility/git/refs/heads/master | awk '{ if ($1 == "\"sha\":") { print substr($2, 2, 40) } }'`
		
	#if they are running it from expected location and its not a sym link then just use github rev
	if [ $SOURCE_DIR == "/usr/local/bin" ] && ! [ -L $BASH_SOURCE ]; then
		APP_REV=$GITHUB_REV
	else
		if hash git 2>/dev/null; then
			APP_REV=$(git rev-parse --verify HEAD)
			if [ $APP_REV != $GITHUB_REV ]; then
				APP_REV="$APP_REV (Developer)"
			fi
		else
			#Shouldn't happen - git wasn't installed 
			APP_REV="<Uknown Version>"
		fi
	fi


	export _REV="$_CUR_VER GitRev: $APP_REV"

	if [ -f $_B/config.sh ]; then
		source $_B/config.sh
	else
		echo "Error. Couldn't start"
		exit 0
	fi
}

install_bootstrap_packages() {

        case "$DISTRO" in
                "ubuntu")
						apt-get update
                        apt-get -y install axel build-essential git xz-utils whiptail unzip wget curl
                        ;;
                 "debian")
						apt-get update
						apt-get -y install axel wget curl unzip whiptail
						;;
				*)
				echo "Shouldn't reach here! Please report this on the forums."
				exit 0
				;;
		esac
}

update_internals() {
	echo "Performing scripts updates"
	baseurl="https://raw.githubusercontent.com/mdrjr/odroid-utility/master"

	FILES=`curl -s $baseurl/files.txt`

	for fu in $FILES; do
		echo "Updating: $fu"
		rm -fr $_B/$fu
		curl -s $baseurl/$fu > $_B/$fu
	done

	chmod +x $_B/odroid-utility.sh
}

# Start the script
initialization

