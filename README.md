Use https://github.com/RattyDAVE/docker-jupyterhub/issues to send feedback, issues, comments and general chat.

# JupyterHub.

Contents

- Base is Ubuntu 19.10
- Cling (provides interactive C++)
- OpenJDK 8 (Required for Kotlin)
- BeakerX 1.4.1 (provides Groovy, Scala, Clojure, Kotlin, Java, and SQL)
- Julia 1.0.4
- Python3
  - Tensorflow 
  - Torch

```
docker run -d  --restart unless-stopped \
    --name jupyterhub \
    --log-opt max-size=50m \
    --memory=$(($(head -n 1 /proc/meminfo | awk '{print $2}') * 4 / 5))k \
    --cpus=$(($(nproc) - 1)) \
    -v %LOCAL_PATH_TO_HOMES%:/home \
    -v %LOCAL_PATH_TO_CREATEUSERS.TXT_FILE%:/root/createusers.txt \
    -v %LOCAL_PATH_TO_STARTUP.SH_FILE%:/root/startup.sh \
    -p 8000:8000 \
    rattydave/jupyterhub
```


Replace ```%LOCAL_PATH_TO_HOMES%``` with the path to the home directory on the host file system.

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

## Minimal config

Use the following for a "quick start". This will create a user called ```user1``` and password ```pass```. Then point your browser to ```http://127.0.0.1:8000```.

```bash
echo "user1:pass:n" > createusers.txt
docker run -d -v $(pwd)/createusers.txt:/root/createusers.txt -p 8000:8000 rattydave/jupyterhub
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
    -v %LOCAL_PATH_TO_HOMES%:/home \
    -v %LOCAL_PATH_TO_CREATEUSERS.TXT_FILE%:/root/createusers.txt \
    -v %LOCAL_PATH_TO_STARTUP.SH_FILE%:/root/startup.sh \
    -p 8000:8000 \
    --env "VIRTUAL_HOST=othersubdomain.yourdomain.tld" \
    --env "VIRTUAL_PORT=8000" \
    --env "LETSENCRYPT_HOST=othersubdomain.yourdomain.tld" \
    --env "LETSENCRYPT_EMAIL=you_mail@yourdomain.tld" \
    rattydave/jupyterhub
```


# Languages

C++ kernel with [Cling](https://cern.ch/cling) is an interpreter for C++.

[Clojure](http://clojure.org/) is a dialect of Lisp that runs in the JVM.
It shares with Lisp the code-as-data philosophy and a powerful macro system.
Clojure is predominantly a functional programming language, and features a rich set of immutable, persistent data structures.
It has strong support for reliable multithreading and concurrency.

[Apache Groovy](http://groovy-lang.org/) is the language that should have been called JavaScript because it is a scripting version of Java.

Java is the mother of all JVM languages, first released in 1995 after years of development by Sun Microsystems.  BeakerX uses [OpenJDK](http://openjdk.java.net/) for Java and all the kernels.

[Kotlin](https://kotlinlang.org/) is a relative newcomer from [JetBrains](https://www.jetbrains.com/) and [Android](https://developer.android.com/kotlin/get-started.html).  It's intended to be an improved version of Java, including [Null Safety](https://kotlinlang.org/docs/reference/null-safety.html).

[Scala](https://www.scala-lang.org/) combines the functional/type-inference paradigm and the object-oriented paradigm, and is also meant to be an improved version of Java.  Scala is the native language of [Apache Spark](Spark.ipynb).

SQL (Structured Query Language) is one of the oldest and most popular languages for database access.
BeakerX has first-class support for SQL, including syntax highlighting, autocompletion, and autotranslation to JavaScript (and more languages [coming](https://github.com/twosigma/beakerx/issues/5039)).

TensorFlow is a free and open-source software library for dataflow and differentiable programming across a range of tasks. It is a symbolic math library, and is also used for machine learning applications such as neural networks. It is used for both research and production at Google.

PyTorch is an open source machine learning library based on the Torch library, used for applications such as computer vision and natural language processing. It is primarily developed by Facebook's AI Research lab (FAIR).
