---
title: Building Dicoogle
permalink: /docs/building/
---

Dicoogle is an open-source project. The official sources are hosted on GitHub [here](https://github.com/bioinformatics-ua/dicoogle.git). This page provides instructions on building Dicoogle from the official sources.

<div class="note info">
  <h5>Dicoogle is licensed under the GNU General Public License v3.0</h5>
  <p>According to this license, you are free to use, modify, and distribute Dicoogle, including modified versions. Nevertheless, certain conditions must be met to preserve this freedom:
    <ul>
      <li>Permissions of this strong copyleft license are conditioned on making available complete source code of licensed works and modifications, which include larger works using a licensed work, under the same license.</li>
      <li>Copyright and license notices must be preserved.</li>
      <li>Contributors provide an express grant of patent rights.</li>
    </ul>
    <p>When in doubt, please consult the official <a href="https://www.gnu.org/licenses/gpl-3.0.en.html">GNU General Public License v3.0</a> website.</p>
  </p>
</div>

Before building, please make sure that your system contains the following tools:

 - Java JDK, either Oracle or OpenJDK (version 8 is recommended; JDK 11 is also supported). This package contains the necessary parts for building Java programs.
 - [Maven](https://maven.apache.org/) 3. We use Maven to retrieve dependencies and execute scripts for building, checking and testing projects.
 - Git, to retrieve the source code from the official repository.

 1. Retrieve the full source code from the official repository:
```sh
git clone https://github.com/bioinformatics-ua/dicoogle.git
```
 2. Navigate to the project's base directory and enter the branch of choice.
    1. `dev` is the development branch with all upstream changes
    2. `release/2.X` refers to the development line of the legacy version, Dicoogle 2 (note that the building requirements of this version are different)
 3. Build the parent Maven project:
``` sh
mvn install
```
   It is possible to build Dicoogle without the web application by skipping the npm step:
```sh
mvn install -Dskip.installnodenpm -Dskip.npm
```
 4. The resulting jar file can be found in "./dicoogle/target". Plugins are provided separately, and must be compatible with the built version of Dicoogle.

### Building and debugging the web application

The web app is located in _"dicoogle/src/main/resources/webapp"_. It is possible to work on the web application as a separate project, and configure it to use a Dicoogle instance on a different location.

First of all, make sure that [Node.js](https://nodejs.org/en/download/) (LTS or Stable) is installed.
We'll be using npm to automatically retrieve all of the webapp's dependencies and build the resulting parts.
Then, you need to call `npm install`:

```sh
npm install
```

This will populate the project with the necessary modules
for building and serving the application.

The building process is orchestrated by [webpack](https://webpack.js.org/).
To build all resources for production:

```sh
npm run build
```

To enter development mode:

```sh
npm start
```

This will build in debug mode and serve the webapp locally at a free TCP port.
See the next section for more information.

#### Debugging the webapp

The web application can be tested separately without having it embedded in a jar file. The steps are fairly simple:

1. Start Dicoogle, locally or on a server: `java -jar dicoogle.jar -s`. The jar file does not need to contain the web application in this case. You may also need to change your configuration in the config.xml file, so as to enable cross-origin requests:

```xml
<config>
    <web-server autostart="true" port="8080">
      <allowed-origins>*</allowed-origins>
    </web-server>
...
</config>
```

2. Navigate to the webapp's source code. Define the URL to Dicoogle's base endpoint using the `DICOOGLE_BASE_URL` environment variable, and bundle the source code: 

```sh
DICOOGLE_BASE_URL=http://localhost:8080 npm start
```

When the environment variable `DICOOGLE_BASE_URL` is set, we are instructing our build scripts to use a custom base URL to the server. 
An update to the web application different server only requires a rebuild of the webapp (and a page refresh in your browser). The server itself does not have to be restarted. See the section above on [building scripts]({{ site.baseurl }}/docs/building/#building-and-debugging-the-web-application) section above for more scripts.

The difference here is that,
while the running Dicoogle instance is hosted at http://localhost:8080,
the web application is actually served by webpack.
REST operations to the server will be properly directed.
