# Please Note:

This is 95% tested. It is undergoing quite a few changes recently and will settle down over the next week or two. (from 15/Dec/2019). 

I have put some examples in ```/examples``` and will proceeed with some testing.

Current state - 
- C++ - Tested and working.
- Bash - Tested and working.
- Python3 - Tested and working.
- Python3 with Tensorflow. - Tested and *NOT* working.
- Diagram - Tested and Working. (Small issue with tool-tips. This is a know issue.)

Use https://github.com/RattyDAVE/docker-jupyterhub/issues to send feedback, issues, comments and general chat.

# JupyterHub.

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

##Minimal config

Use the following for a "quick start". This will create a user called ```user1``` and password ```pass```. Then point your browser to ```http://127.0.0.1:8000```.

```bash
echo "user1:pass:n" > createusers.txt
docker run -d -v createusers.txt:/root/createusers.txt -p 8000:8000 rattydave/jupyterhub
```


# TO ADD SSL

To add SSL authentication you need to open port 80 and 443 to the internet.

```
docker run --detach \
    --name nginx-proxy \
    --publish 80:80 \
    --publish 443:443 \
    --volume /etc/nginx/certs \
    --volume /etc/nginx/vhost.d \
    --volume /usr/share/nginx/html \
    --volume /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy
```

```
docker run --detach \
    --name nginx-proxy-letsencrypt \
    --volumes-from nginx-proxy \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --env "DEFAULT_EMAIL=you_mail@yourdomain.tld" \
    jrcs/letsencrypt-nginx-proxy-companion
```

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
    --env "VIRTUAL_HOST=othersubdomain.yourdomain.tld" \
    --env "VIRTUAL_PORT=8000" \
    --env "LETSENCRYPT_HOST=othersubdomain.yourdomain.tld" \
    --env "LETSENCRYPT_EMAIL=you_mail@yourdomain.tld" \
    rattydave/jupyterhub
```
