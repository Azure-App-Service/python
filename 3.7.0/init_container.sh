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
chmod 755 /opt/startup/startupCommand


#echo "Running python /usr/local/bin/entrypoint.py"
#eval "exec python -u /usr/local/bin/entrypoint.py"

#oryx startup script generator

if [ -d /home/site/wwwroot/antenv -a ! -d /home/site/wwwroot/__oryx_packages__ ]; then
    echo 'Virtual Environment present:'
    echo "Running python /usr/local/bin/entrypoint.py"
    eval "exec python -u /usr/local/bin/entrypoint.py"
else
    echo 'Virtual Environment not detected, running oryx startup:'
    oryxArgs='-appPath /home/site/wwwroot -output /opt/startup/startup.sh -virtualEnvName antenv -defaultApp /opt/defaultsite'
    if [ $# -eq 0 ]; then
        echo 'App Command Line not configured, will attempt auto-detect'
    else
        echo "Site's appCommandLine: $@" 
        if [ $# -eq 1 ]; then
            echo "Checking of $1 is a file"
            if [ -f $1 ]; then
                echo "$1 file exists on disk, reading its contents to run as startup arguments"
                fileContents=$(head -1 $1)
                echo "Contents of startupScript: $fileContents"

                oryxArgs+=" -userStartupCommand '$fileContents'"
            else
                oryxArgs+=" -userStartupCommand '$1'"
            fi
        else
           oryxArgs+=" -userStartupCommand '$@'"
        fi
    fi

    echo "Launching oryx with: $oryxArgs"
    #invoke oryx to generate startup script
    eval "oryx $oryxArgs"
    chmod +x /opt/startup/startup.sh
    #launch startup script
    /opt/startup/startup.sh 
fi


