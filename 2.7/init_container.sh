#!/usr/bin/env bash

cat >/etc/motd <<EOL 

  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \\___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 

A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux

EOL
cat /etc/motd

service ssh start


# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)

echo "$@" > /opt/startup/startupCommand

STARTUPCOMMAND="$(cat /opt/startup/startupCommand)"

FILE="$@"
if [ -f $FILE ]; then
    STARTUPCOMMAND=$(head -1 $FILE)
elif
    STARTUPCOMMAND=''
fi

#invoke oryx to generate startup script
oryx -appPath /home/site/wwwroot -userStartupCommand $STARTUPCOMMAND -output /opt/startup/startup.sh -virtualEnvName antenv2.7 -defaultApp /opt/defaultSite
chmod 777 /opt/startup/startup.sh

#launch startup script
/opt/startup/startup.sh