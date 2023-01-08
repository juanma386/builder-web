#!/usr/bin/env bash
# shellcheck disable=SC2034 # https://github.com/koalaman/shellcheck/wiki/SC2034




# Load in the functions and animations
source ./bash_loading_animations.sh
# Run BLA::stop_loading_animation if the script is interrupted
trap BLA::stop_loading_animation SIGINT

domain=vpx.ar
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

echo "Try create config file on ${website}.${domain}"  $'\e[0;32m' [ START ] $'\e[0m';
sleep 0.5
webconfFile=/etc/apache2/sites-available/000-${website}.${domain}.conf
if [ ! -e  webconfFile ]; then
if  echo $(apachectl configtest) === "Syntax OK" &> /dev/null; then 
echo "Try Create your website" $'\e[0;33m' [ TRY ] $'\e[0m'; 
else 
echo "Please check Server Apache Error"$'\e[1;33m' [ ERROR ] $'\e[0m'; 
fi
sleep 1.0
echo '# UseCanonicalName On

<VirtualHost *:80>
ServerName '${website}'.'${domain}'
DocumentRoot /var/www/'${website}'.'${domain}'/html

ErrorLog /var/www/'${website}'.'${domain}'/log/error.log
CustomLog /var/www/'${website}'.'${domain}'/log/requests.log combined

    <Directory "/var/www/'${website}'.'${domain}'/html">
        Options Indexes FollowSymLinks Includes ExecCGI MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
' > /etc/apache2/sites-available/000-${website}.${domain}.conf;
create_  "${website}"
fi
}

create_() {
website=$(filter "${1}") # $1 represent first argument
# website=${1} # $1 represent first argument
if [ ! -d /var/www/${website}.${domain}/html ]; then 
echo "Try create folder /var/www/${website}.${domain}/html" $'\e[1;33m' [ TRY ] $'\e[0m'
sleep 1
sudo -u root -s mkdir -p /var/www/${website}.${domain}/html /var/www/${website}.${domain}/log;      
sudo -u root -s chown www-data:www-data /var/www
sudo -u root -s chown -R www-data:www-data /var/www/${website}.${domain}/


if [ ! -d /var/www/${website}.${domain}/html ]; then 
echo "Error Creating Folder please check log details to more info" $'\e[1;31m' [ ERROR ] $'\e[0m'
else
echo "Created Succces File to ${website}.${domain}" $'\e[1;33m' [ OK ] $'\e[0m'
enable_  ${website}.${domain}
fi
else
echo "Is Succces Present File of ${website}.${domain}" $'\e[1;32m' [ READY ] $'\e[0m'
enable_  ${website}.${domain}
fi
}

enable_(){
website_enable=${1} # $1 represent first argument
echo "Try Activate new server to ${website_enable}.${domain}" $'\e[0;32m' [ PROCCESSING ] $'\e[0m'
base=/etc/apache2/sites-enabled/000-${website_enable}.conf
if [[ -L ${base} ]]; then
        if [[ -e ${base} ]]; then
        sudo ln -s /etc/apache2/sites-available/000-${website_enable}.conf  ${base}
                # echo "Error Linking File to work on system, please check error on system"$'\e[0;31m' [ ERROR ] $'\e[0m'
                echo "Success File is created to system" $'\e[0;32m' [ OK ] $'\e[0m'
        else
                echo "Clean file and reload" $'\e[0;33m' [ TRY ] $'\e[0m'
                rm base
                sudo ln -s /etc/apache2/sites-available/000-${website_enable}.conf  base
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
echo "Try apply Configuration on System to ${website}.${domain}"
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


[ -f /etc/samba/smb.conf ] && echo "$FILE exist." || sudo apt install samba -y



create_conf_()
{
	echo "

[${website} of ${domain}]
        writable=yes
        force user=www-data
        public=yes
        path=/var/www/${website}.${domain}/html
        guest account=www-data
        create mode=644

	"  >> $CONF_SAMBA && echo 'Config is loaded success [ 201 ]' || echo 'Error loading Samba Service [ 500 ]';
	sudo systemctl restart smbd && echo "Service Samba is restart ACCEPTED [ 202 ]" || echo "Restart Service Samba is ERRORSERVER [ 500 ]";
}

CONF_SAMBA=/etc/samba/smb.conf.shares
if test -f "$CONF_SAMBA"; then
    echo "$CONF_SAMBA exists.";
else
  echo "" > $CONF_SAMBA;
  echo "Configuration Samba is inicializate";
fi

ls $CONF_SAMBA|xargs grep -r "${website} of ${domain}" || create_conf_;

SMB_CONF=/etc/samba/smb.conf;
ls $SMB_CONF|xargs grep -r "include = /etc/samba/smb.conf.shares" && echo "Configuration is ACCEPTED [ 202 ]"|| echo "include = /etc/samba/smb.conf.shares" >> $SMB_CONF;

ls /etc/apache2/sites-available|grep $1 && echo "Configuration is SUCCESS "$'\e[1;33m' [ 200 ] $'\e[0m'|| echo "Configuration is Not Found [ 404 ]"
ls /etc/apache2/sites-enabled|grep $1 && echo "Configuration Enabled is SUCCESS "$'\e[1;33m' [ 202 ] $'\e[0m'|| echo "Configuration is Not Found [ 404 ]"

enabled_() {
demo_loading_animation "${BLA_clock[@]}";
sudo -u root -s ln -s /etc/apache2/sites-available/000-${website_enabled}.conf /etc/apache2/sites-enabled/000-${website_enabled}.conf && echo "Activate WebSite is Success "$'\e[1;33m' [ 201 ] $'\e[0m'|| echo "Error on activate WebSite" $'\e[1;31m' [ 500 ] $'\e[0m';
sudo -u root -s apachectl configtest && systemctl restart apache2 || echo "Error Config Test";
}
website_enabled=${website}.${domain};

ls /etc/apache2/sites-enabled|grep $1 || enabled_
