Use https://github.com/RattyDAVE/docker-jupyterhub/issues to send feedback, issues, comments and general chat.

#JupyterHub.

Contents

- Base is Ubuntu 19.04
-

```
docker run -d  --restart unless-stopped \
    --name jupyterhub \
    --log-opt max-size=50m \
    --memory=$(($(head -n 1 /proc/meminfo | awk '{print $2}') * 4 / 5))k \
    --cpus=$(($(nproc) - 1)) \
    -v %LOCAL_PATH_TO_CREATEUSERS.TXT_FILE%:/root/createusers.txt \
    -v %LOCAL_PATH_TO_STARTUP.SH_FILE%:/root/startup.sh \
    -p 8000:8000 \
    -v $(pwd):/workdir \
    rattydave/jupyterhub
```

Replace ```%LOCAL_PATH_TO_CREATEUSERS.TXT_FILE%``` with the local filename of the createusers file.

This file contains 3 fields (username:password:is_sudo). Where username is the login id. Password is the password. is_sudo does the user have sudo access(only Y is recognised). It also needs a "newline" at the end of the line.

Example

```
mickey:mouse:N
daisy:duke:Y
dog:flash:n
morty:rick:wubba
```

In this example 4 users will be created and only daisy will have sudo rights.

At every reboot it will check this file and ADD any new users.

Replace ```%LOCAL_PATH_TO_STARTUP.SH_FILE%``` with the local filename of the startup.sh script. This is run after the user creation and before the service start.
