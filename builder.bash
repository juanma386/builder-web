#!/usr/bin/env bash
# shellcheck disable=SC2034 # https://github.com/koalaman/shellcheck/wiki/SC2034

# Load in the functions and animations
source ./bash_loading_animations.sh
# Run BLA::stop_loading_animation if the script is interrupted
trap BLA::stop_loading_animation SIGINT

demo_loading_animation() {
  BLA_active_loading_animation=( "${@}" )
  # Extract the delay between each frame from the active_loading_animation array
  BLA_loading_animation_frame_interval="${BLA_active_loading_animation[0]}"
  # Sleep long enough that all frames are showed

  ## BC installing
	if [ $(echo 25/5 | bc) == "5" ]; then echo "Let's Go!"; else apt install -y bc; fi


  # substract 1 to the number of frames to account for index [0]
  demo_duration=$( echo "${BLA_active_loading_animation[0]} * ( ${#BLA_active_loading_animation[@]} - 1 )" | bc )
  # Make sure each animation is shown for at least 3 seconds
  if [[ $( echo "if (${demo_duration} < 3) 0 else 1" | bc ) -eq 0 ]] ; then
    demo_duration=3
  fi
  unset "BLA_active_loading_animation[0]"
  echo
  BLA::play_loading_animation_loop &
  BLA_loading_animation_pid="${!}"
  sleep "${demo_duration}"
  kill "${BLA_loading_animation_pid}" &> /dev/null 
	clear
 # echo "Progress is " $'\e[1;33m' [ OK ] $'\e[0m'
 # clear
}

tput civis # Hide the terminal cursor
# clear

checkStr() {
   [[ $1 != *[a-zA-Z0-9]* ]]
}
isString() {
 [[ "string" != ${1#????????} ]]
}

function filter() {
 INPUT_STRING=$1;
 OUTPUT_STRING=$(echo $INPUT_STRING | sed 's/[^a-zA-Z0-9]//g');
	local retval=$OUTPUT_STRING;
	echo "$retval"
}

service_() { 
#website="${1}" # $1 represent first argument
website=$(filter "${1}") # $1 represent first argument

echo "Try create config file on ${website}.hexome.cloud"  $'\e[0;32m' [ START ] $'\e[0m';
sleep 0.5
webconfFile=/etc/apache2/sites-available/000-${website}.hexome.cloud.conf
if [ ! -e  webconfFile ]; then
if  echo $(apachectl configtest) === "Syntax OK" &> /dev/null; then 
echo "Try Create your website" $'\e[0;33m' [ TRY ] $'\e[0m'; 
else 
echo "Please check Server Apache Error"$'\e[1;33m' [ ERROR ] $'\e[0m'; 
fi
sleep 1.0
echo '# UseCanonicalName On

<VirtualHost *:80>
ServerName '${website}'.hexome.cloud
DocumentRoot /var/www/'${website}'.hexome.cloud/html

ErrorLog /var/www/'${website}'.hexome.cloud/log/error.log
CustomLog /var/www/'${website}'.hexome.cloud/log/requests.log combined

    <Directory "/var/www/'${website}'.hexome.cloud/html">
        Options Indexes FollowSymLinks Includes ExecCGI MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
' > /etc/apache2/sites-available/000-${website}.hexome.cloud.conf;
create_  "${website}"
fi
}

create_() {
website=$(filter "${1}") # $1 represent first argument
# website=${1} # $1 represent first argument
if [ ! -d /var/www/${website}.hexome.cloud/html ]; then 
echo "Try create folder /var/www/${website}.hexome.cloud/html" $'\e[1;33m' [ TRY ] $'\e[0m'
sleep 1
sudo -u www-data -s mkdir -p /var/www/${website}.hexome.cloud/html /var/www/${website}.hexome.cloud/log;      
if [ ! -d /var/www/${website}.hexome.cloud/html ]; then 
echo "Error Creating Folder please check log details to more info" $'\e[1;31m' [ ERROR ] $'\e[0m'
else
echo "Created Succces File to ${website}.hexome.cloud" $'\e[1;33m' [ OK ] $'\e[0m'
enable_  ${website}
fi
else
echo "Is Succces Present File of ${website}.hexome.cloud" $'\e[1;32m' [ READY ] $'\e[0m'
enable_  ${website}
fi
}

enable_(){
website_enable=${1} # $1 represent first argument
echo "Try Activate new server to ${website_enable}.hexome.cloud" $'\e[0;32m' [ PROCCESSING ] $'\e[0m'
base=/etc/apache2/sites-enabled/000-${website_enable}.hexome.cloud.conf
if [[ -L base ]]; then
        if [[ -e base ]]; then
        sudo ln -s /etc/apache2/sites-available/000-${website_enable}.hexome.cloud.conf  ${base}
                # echo "Error Linking File to work on system, please check error on system"$'\e[0;31m' [ ERROR ] $'\e[0m'
                echo "Success File is created to system" $'\e[0;32m' [ OK ] $'\e[0m'
        else
                echo "Clean file and reload" $'\e[0;33m' [ TRY ] $'\e[0m'
                rm base
                sudo ln -s /etc/apache2/sites-available/000-${website_enable}.hexome.cloud.conf  base
                    echo "Error Linking File to work on system, please check error on system"$'\e[0;31m' [ ERROR ] $'\e[0m'
        fi
else
    echo "Please check error on system configuration"$'\e[0;31m' [ ERROR ] $'\e[0m'
fi
sleep 1.0
                        if [[ -L base ]]; then
                          if [[ -e base ]]; then
                                        echo "Success File is created to system" $'\e[0;32m' [ OK ] $'\e[0m'
                                        restart
                           else
                                echo "Error Linking File to work on system, please check error on system"$'\e[0;31m' [ ERROR ] $'\e[0m'
				try
                          fi
			fi
restart_
}

restart_() {
website=filter "${1}" # $1 represent first argument
#website="${1}" # $1 represent first argument
echo "Try apply Configuration on System to ${website}.hexome.cloud"
sleep 1.0
if  echo $(apachectl configtest) === "Syntax OK" &> /dev/null; then systemctl restart apache2 &> /dev/null;
echo "Congratulation try your server configuration"  $'\e[1;32m' [ SUCCESS ] $'\e[0m'
else
echo "Check Errors building Website" $'\e[1;31m' [ ERROR ] $'\e[0m'
fi
sleep 0.3
}

#website="${1}" # $1 represent first argument
website=$(filter $1);

if [ "$(whoami)" != root ]; then # Check if root user
  echo "Only user root can run this script." $'\e[1;31m' [ ERROR ] $'\e[0m'
  exit 1
  else
    if [ -z "$1" ]; then
     echo "Need Input data option" $'\e[1;33m' [ WARNING ] $'\e[0m'
	exit 2
	else
		(
		  echo "Program checking" $'\e[1;33m' [ START ] $'\e[0m'
		  sleep 1.5
		  if checkStr "${1}";then
		    exit 3  # <-- this is our simulated bailing out
		  fi
		 if [ $? = 3 ]
                	then
	                  echo "Error Syntax Service" $'\e[1;31m' [ ERROR ] $'\e[0m'
                fi
		 echo "this is proccessing ${website}.hexome.cloud"
		sleep 0.1
		  echo "Do yet another thing"
		  echo "And do a last thing"
		  	demo_loading_animation "${BLA_clock[@]}"
		  echo "Progress is"$'\e[1;33m' [ NEXT ]$'\e[0m'
			sleep 0.4
		  	 if service_ $1; then
		  echo "Progress is " $'\e[1;33m' [ OK ] $'\e[0m'
		  fi
		)   # <-- here we arrive after the simulated bailing out, and $? will be 3 (exit code)
		if [ $? = 3 ]
		then
		  echo "Error Syntax Service" $'\e[1;31m' [ ERROR ] $'\e[0m'
		fi
   fi # Check if exist field option
  fi # Final Service
