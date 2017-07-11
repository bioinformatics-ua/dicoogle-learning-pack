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
  </p>
</div>

Before building, please make sure that your system contains the following tools:

 - Java JDK, either Oracle or OpenJDK (at least version 7; JDK 8 is recommended)
 - [Maven](https://maven.apache.org/) 3
 - [Node.js](https://nodejs.org/en/download/) (at least version 4; LTS or Stable versions are recommended) and npm (at least version 2)
 - Git, to retrieve the source code from the official repository.

 1. Retrieve the full source code from this repository: `git clone https://github.com/bioinformatics-ua/dicoogle.git`
 2. Navigate to the project's base directory, and build the parent Maven project by calling `mvn install`.
    - You can build Dicoogle without the web application by skipping the npm process: `mvn install -Dskip.npm`
 3. The resulting jar file can be found in "./dicoogle/target". Plugins are provided separately, and must be compatible with the built version of Dicoogle.

### Building and debugging the web application

The web app is located in _"dicoogle/src/main/resources/webapp"_. It is possible to work on the web application as a separate project, and configure it to use a Dicoogle instance on a different location.

`npm` version 2 or earlier is required. To build everything for production (ready to be bundled for when creating dicoogle.jar):

```sh
npm install
```

To build all js and html resources:

```sh
npm run debug        # for development
npm run build        # for production
```

To build just the css files:

```sh
npm run css
```

To watch for changes in JavaScript resources (good for building while developing):

```sh
npm run js:watch
```

To watch for changes in the SASS resources (thus building css):

```sh
npm run css:watch
```

Everything is build for production (js, html and css) in the prepublish script (this is also run automatically for `npm install`):

```sh
npm run-script prepublish
```

All of these npm scripts map directly to gulp tasks:

```sh
$ gulp --tasks

 ├── lint
 ├─┬ js
 │ └── lint
 ├─┬ js-debug
 │ └── lint
 ├── js:watch
 ├── html
 ├── html-debug
 ├── css
 ├── css-debug
 ├── css:watch
 ├─┬ production
 │ ├── js
 │ ├── html
 │ └── css
 ├─┬ development
 │ ├── js-debug
 │ ├── html-debug
 │ └── css
 ├── clean
 └─┬ default
   └── production
```

#### Running as a standalone server

We have included a script for running a static server containing the standalone webapp. If you already have Python installed, simply execute:

```sh
./run_server
```

Otherwise, many static server applications are available, such as the `static-http` package:

```sh
npm install -g static-http
static-http -p 9000
```

#### Debugging the webapp

The web application can be tested separately without having it embedded in a jar file. The steps are fairly simple:

1. Start Dicoogle, locally or on a server: `java -jar dicoogle.jar -s`. The jar file does not need to contain the web application in this case. You may also need to change your configuration in the config.xml file, so as to enable cross-origin requests:

```xml
<server enable="true" port="8080" allowedOrigins="*" />
```

2. Navigate to the webapp's source code. Define the URL to Dicoogle's base endpoint using the `DICOOGLE_BASE_URL` environment variable, and bundle the source code: `DICOOGLE_BASE_URL=http://localhost:8080 npm run debug`. See the **Building** section above for more scripts.

3. Start a static server on the web application's base folder. If you have Python, the `run_server` script will do.

4. Open your browser and navigate to the static server: http://localhost:9000
