#!/usr/bin/env bash

#Set Timezone
if [[ -z "${TZ}" ]]; then
   ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
else
   ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
fi

echo 'Configuring shared folder…'
groupadd jupyterhub-users

mkdir -p /srv/scratch
chown -R root:jupyterhub-users /srv/scratch
chmod 777 /srv/scratch
chmod g+s /srv/scratch

#CREATE USERS.
# username:passsword:Y
# username2:password2:Y

file="/root/createusers.txt"
cat $file

if [ -f $file ]
  then
    while IFS=: read -r username password is_sudo
        do
            echo "Username: $username, Password: $password , Sudo: $is_sudo"

            if getent passwd $username > /dev/null 2>&1
              then
                echo "User Exists"
              else
                useradd -ms /bin/bash $username
                usermod -aG audio $username
                usermod -aG video $username
                mkdir -p /run/user/$(id -u $username)/dbus-1/
                chmod -R 700 /run/user/$(id -u $username)/
                chown -R "$username" /run/user/$(id -u $username)/
                echo "$username:$password" | chpasswd
                
                usermod -aG jupyterhub-users $username
                ln -s /srv/scratch /home/$username/shared
                
                if [ "$is_sudo" = "Y" ]
                  then
                    usermod -aG sudo $username
                fi
            fi
    done <"$file"
fi

startfile="/root/startup.sh"
if [ -f $startfile ]
  then
    sh $startfile
fi

#export M2_HOME=/usr/share/maven
#export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
#export PATH=$PATH:$JAVA_HOME/bin

export JUPYTER_ALLOW_INSECURE_WRITES=1


mkdir -p ~/.jupyter
mkdir -p ~/.local/share/jupyter/runtime

cd /root

if [ -f /etc/jupyterhub/jupyterhub_config.py ]
  then
    #jupyterhub -f /etc/jupyterhub/jupyterhub_config.py --debug
    jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
  else
    #jupyterhub --debug
    jupyterhub 
fi
