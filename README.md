Use https://github.com/RattyDAVE/docker-jupyterhub/issues to send feedback, issues, comments and general chat.

# JupyterHub

JupyterHub brings the power of notebooks to groups of users. It gives users access to computational environments and resources without burdening the users with installation and maintenance tasks. Users - including students, researchers, and data scientists - can get their work done in their own workspaces on shared resources which can be managed efficiently by system administrators.

JupyterHub makes it possible to serve a pre-configured data science environment to any user in the world. It is customizable and scalable, and is suitable for small and large teams, academic courses, and large-scale infrastructure.

JupyterLab is a web-based interactive development environment for Jupyter notebooks, code, and data. JupyterLab is flexible: configure and arrange the user interface to support a wide range of workflows in data science, scientific computing, and machine learning. JupyterLab is extensible and modular: write plugins that add new components and integrate with existing ones.

The Jupyter Notebook is an open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text. Uses include: data cleaning and transformation, numerical simulation, statistical modeling, data visualization, machine learning, and much more.

## Contents

- Base is Ubuntu 20.04
- xeus-cling (provides interactive C++)
- BeakerX 1.4.1 (provides Groovy, Scala, Clojure, Kotlin, Java, and SQL)
- Julia 1.0.4
- NodeJS
- Python3
  - Tensorflow 
  - Torch
  
## Install  

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

### Example

```
mickey:mouse:N
daisy:duke:Y
dog:flash:n
morty:rick:wubba
```

In this example 4 users will be created and only daisy will have sudo rights.

At every reboot it will check this file and ADD any new users.

Replace ```%LOCAL_PATH_TO_STARTUP.SH_FILE%``` with the local filename of the startup.sh script. This is run after the user creation and before the service start.

### Minimal config

Use the following for a "quick start". This will create a user called ```user1``` and password ```pass```. Then point your browser to ```http://127.0.0.1:8000```.

```bash
echo "user1:pass:n" > createusers.txt
docker run -d -v $(pwd)/createusers.txt:/root/createusers.txt -p 8000:8000 rattydave/jupyterhub
```

## Auto Update

To automatically update I recomend using watchtower.

```
docker run -d \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower
```

## To add SSL

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
    --env "DEFAULT_EMAIL=your_mail@yourdomain.tld" \
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
    --env "LETSENCRYPT_EMAIL=your_mail@yourdomain.tld" \
    rattydave/jupyterhub
```


## Languages

### C++
[Xeus-cling](https://github.com/jupyter-xeus/xeus-cling) is a Jupyter kernel for C++ based on the C++ interpreter cling and the native implementation of the Jupyter protocol xeus.
xeus cling is a replacement for the C++ kernel with [Cling](https://cern.ch/cling).

C++ is a general-purpose programming language created by Bjarne Stroustrup as an extension of the C programming language, or "C with Classes". The language has expanded significantly over time, and modern C++ has object-oriented, generic, and functional features in addition to facilities for low-level memory manipulation. It is almost always implemented as a compiled language, and many vendors provide C++ compilers, including the Free Software Foundation, LLVM, Microsoft, Intel, Oracle, and IBM, so it is available on many platforms.

C++ was designed with a bias toward system programming and embedded, resource-constrained software and large systems, with performance, efficiency, and flexibility of use as its design highlights. C++ has also been found useful in many other contexts, with key strengths being software infrastructure and resource-constrained applications, including desktop applications, servers (e.g. e-commerce, Web search, or SQL servers), and performance-critical applications (e.g. telephone switches or space probes).

Included is a C++ full course from Derek Banas's video [tutorials](https://www.youtube.com/playlist?list=PLGLfVvz_LVvQ9S8YSV0iDsuEU8v11yP9M).

### Node.JS
[Node.JS](https://nodejs.org/en/) is an Open-source software|open-source, cross-platform, JavaScript runtime environment that executes JavaScript code outside of a browser. Node.js lets developers use JavaScript to write command line tools and for server-side scripting—running scripts server-side to produce dynamic web page content before the page is sent to the user's web browser. Consequently, Node.js represents a "JavaScript everywhere" paradigm, unifying web application development around a single programming language, rather than different languages for server- and client-side scripts.

Though <code>.js</code> is the standard filename extension for JavaScript code, the name "Node.js" doesn't refer to a particular file in this context and is merely the name of the product. Node.js has an event-driven architecture capable of asynchronous I/O. These design choices aim to optimize throughput and scalability in web applications with many input/output operations, as well as for real-time Web applications (e.g., real-time communication programs and browser games).

The Node.js distributed development project, governed by the Node.js Foundation.

### Clojure
[Clojure](http://clojure.org/) is a dialect of Lisp that runs in the JVM.
It shares with Lisp the code-as-data philosophy and a powerful macro system.
Clojure is predominantly a functional programming language, and features a rich set of immutable, persistent data structures.
It has strong support for reliable multithreading and concurrency.

### Groovy
[Apache Groovy](http://groovy-lang.org/) is the language that should have been called JavaScript because it is a scripting version of Java.

### Java
Java is the mother of all JVM languages, first released in 1995 after years of development by Sun Microsystems.  BeakerX uses [OpenJDK](http://openjdk.java.net/) for Java and all the kernels.

### Kotlin
[Kotlin](https://kotlinlang.org/) is a relative newcomer from [JetBrains](https://www.jetbrains.com/) and [Android](https://developer.android.com/kotlin/get-started.html).  It's intended to be an improved version of Java, including [Null Safety](https://kotlinlang.org/docs/reference/null-safety.html).

### Scala
[Scala](https://www.scala-lang.org/) combines the functional/type-inference paradigm and the object-oriented paradigm, and is also meant to be an improved version of Java.  Scala is the native language of Apache Spark.

### SQL
SQL (Structured Query Language) is one of the oldest and most popular languages for database access.
BeakerX has first-class support for SQL, including syntax highlighting, autocompletion, and autotranslation to JavaScript (and more languages [coming](https://github.com/twosigma/beakerx/issues/5039)).

### Tensorflow
TensorFlow is a free and open-source software library for dataflow and differentiable programming across a range of tasks. It is a symbolic math library, and is also used for machine learning applications such as neural networks. It is used for both research and production at Google.

### Torch
PyTorch is an open source machine learning library based on the Torch library, used for applications such as computer vision and natural language processing. It is primarily developed by Facebook's AI Research lab (FAIR).

## IJavascript
IJavascript is a Javascript kernel for the [Jupyter notebook](http://jupyter.org/).

The IJavascript kernel executes Javascript code inside a [Node.js](https://nodejs.org/) session. And thus, it behaves as the Node.js REPL does, providing access to the Node.js standard library and to any installed [npm](https://www.npmjs.com/) modules.

## Tutorials and Examples

Included in this container is Examples and Tutorials.

### BeakerX

Jupyter and BeakerX are based on the idea of the lab notebook, brought to life in your web browser. Each notebook is a place for recording the written ideas, data, images, spreadsheets, diagrams, equations, and especially code, that one produces in the course of research. You can analyze, visualize, and document data and science, using multiple programming languages. BeakerX is an extension of Jupyter, including kernels for the JVM langauges, autotranslation between languages (prototype), interactive plots, tables, Spark, and more.

The Jupyter documentation covers interacting with code cells, markdown, and notebooks. The tutorials below show the features of the BeakerX extension.

BeakerX's plots and tables also feature an innovative approach to the scroll wheel and zoom gestures.

#### Languages
Groovy, Java, Scala, Clojure, SQL, Kotlin.

#### Magics
Timing, Classpath and Imports, Polyglot Magics, Defining New Magics.

#### Options Panels
Properties, Heap Size, and other JVM Options, UI Options.

#### Autotranslation
Python to JS and D3, Groovy to JS and D3, General Autotranslation.

#### Groovy Plotting and Charting
Example and Interaction, Time Series and General APIs and Features, Category Plots and Bar Charts, Levels of Detail, Histograms, Heatmaps, Treemaps, Plot Actions, Plot Seamless Updates, 3D Visualization and Maps.

#### Table Display
Groovy API including Actions, 64-Bit Integers and BigNums, Automatic Display of Simple Data Structures, Handling of Large Tables.

#### BeakerX Plotting in Other Languages
JavaScript, Python, Scala.

#### Python
Tables including pandas integration, Time Series, Plot Actions, Heatmaps, Category Plots, Treemaps, Histograms, EasyForm, Output Containers, Magics to access the JVM.

#### Scala
Tables, Plotting, EasyForm.

#### Rich Outputs and Displayer Customization
Media and MIME Outputs, General Display, Display of Null, Custom Displayers and jvm-repr.

#### Forms, Widgets, and Interaction
EasyForm, Output Widget, Output Containers and Layout Managers, Groovy interface to Jupyter JS Widgets, Styling Widgets, Interactive recomputation.

#### Automation
Progress Reporting API, Initialization Cells, Get Code, Run Another Cell.

#### Tablesaw
Tablesaw Pandas for the JVM.

#### Spark
Plain Spark cluster computing using on Scala, Spark Magic for deeper integration, and the Flint time series library.

#### More Integrations
DataVec (DeepLearning4j), STIL (Starlink Tables Infrastructure Library).

### Torch
A FULL course from beginner to advanced.

### Tensorflow
All examples are included.




