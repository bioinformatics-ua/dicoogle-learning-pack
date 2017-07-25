---
title: Web UI Plugins
permalink: /docs/webplugins/
layout: docs
---

Dicoogle web user interface plugins, or just web plugins, are frontend-oriented pluggable components that live in the web application. This page is a tutorial that will guide you into making your first Dicoogle web plugin: a settings component for reading and modifying the DICOM server's AE title.

### Setting up a project

We will start by creating a Dicoogle web plugin project. Before we start, we must fulfill the following requirements:

- Node.js (LTS or Stable) ─ required for executing the building tools. 
- npm (at least version 2 required, 3 is recommended) ─ the JavaScript package manager.

Now, we will install two packages globally, using the following command:

```sh
npm install -g yo generator-dicoogle-webplugin
```

<div class="note info">
<h5>Installing packages globally might not work immediately.</h5>
<p>On Unix systems, you may need to fix the <a href="https://docs.npmjs.com/getting-started/installing-npm-packages-globally">npm permissions</a>. Although it is not recommended, you can also execute the command as super user (with <code>sudo</code>).</p>
</div>

This will install the packages `yo` and `generator-dicoogle-webplugin`. The first one is the executable for [Yeoman](http://yeoman.io), a project scaffolding application with a generator ecosystem. The second one is a Dicoogle web plugin project generator, developed specifically to facilitate the development of this kind of plugins.

While still on a command line, execute the following commands:

```sh
mkdir webplugin-aetitle
cd webplugin-aetitle
yo dicoogle-webplugin
```

The application will now be asking you a series of questions about the project.

- The **project name** will be the name of the npm project, and also the unique name of the plugin. We can leave the default by pressing Enter.
- The **description** is just a small text about the plugin, and is completely optional.
- Next you will be asked about the **type** of web plugin. For this example, we will select the **settings** type.
- Afterwards, you may select whether you want a JavaScript or a TypeScript project. A JavaScript project will include [Babel](babeljs.io) to guarantee the existence of features that were standardized in ECMAScript 2015 and ECMAScript 2016. A [TypeScript](https://www.typescriptlang.org/) project will be configured to use a TypeScript compiler instead. Any of the two kinds of projects should work fine, but you might prefer the JavaScript project if you don't know anything about TypeScript.
- The **caption** is a label that is shown in the web application. We will set this one to _"AE Title"_.
- Finally, you are requested additional information about the project, which can be added in case of the project being put into a public repository. They are all optional.

After the process is complete, you will have a brand new project in your working directory.

### Building and installing

Before we make the necessary changes, let us see whether the created web plugin works. First we build the project:

```sh
npm install
```

This will yield, among others, a file named _"module.js"_. This one and _"package.json"_ make the full plugin.

We will now install this plugin as a standalone web plugin. Create a folder _"WebPlugins"_ in your _"DicoogleDir"_ folder.
Afterwards, create a directory _"aetitle"_ in _"WebPlugins"_ and copy the two files above into this folder. The directory tree should look like this:

```
 .
 ├── DicoogleDir
 ├── Plugins
 |   └── ...
 ├── WebPlugins
 |   └── aetitle
 |       ├── package.json
 |       └── module.js
 ├── storage
 |   └── ...
 ├── ...
 └── dicoogle.jar
```

Start Dicoogle and enter the web application, into the _Management_ menu. The _Services & Plugins_ sub-menu should now have our plugin.

![]({{ site.baseurl }}/images/screenshot_webplugin_settings_hello.png)

<div class="note info">
  <h5>Dicoogle web plugins are currently an experimental feature.</h5>
  <p>Although these plugins are known to work for a variety of use cases, some of the features may be unstable or have bugs. If the web plugin does not appear, consider logging out of Dicoogle and logging back in. Refreshing the page may also help. Furthermore, it is often worth checking the server log for the list of plugins that were loaded.</p>
</div>

Once we know that it works, it's time to head back to our aetitle project.

### Implementing an AE Title configurator

At this point, we now want to implement the intended functionality. The plugin should show a text box to see and modify the server's AE Title. The main question that arises would be: _Where do I implement that?_ Let's have a look at the generated source code in _"src/index.js"_.

```javascript
/* global Dicoogle */

export default class MyPlugin {
    
    constructor() {
        // TODO initialize plugin here
    }
    
    /** 
     * @param {DOMElement} parent
     * @param {DOMElement} slot
     */
    render(parent, slot) {
        // TODO mount a new web component here
        const div = document.createElement('div');
        div.innerHTML = 'Hello, Dicoogle!';
        parent.appendChild(div);
    }
}
```

There may be many parts that are not quite understandable here, but the essentials are:

- The whole plugin is represented as a class, and this is the module's default export. Typically, you do not have to touch this.
- The constructor can be used to initialize certain parts of the plugin before any rendering takes place. It is not always needed.
- The `render' method is the most important portion of the plugin: it is where new HTML elements are created and written to the web app's document. The example shows how this can be done with the standard [Document Object Model (DOM) Web API](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model).
- In order to develop plugins safely, the elements should be attached as children to the `parent` element.

Instead of creating a div, we will create a text box and a label to provide feedback to the user.

```javascript
render(parent, slot) {
    // create text input
    const txtAetitle = document.createElement('input');
    this.txtAetitle = txtAetitle;
    txtAetitle.type = 'text';
    txtAetitle.className = 'form-control';
    txtAetitle.disabled = true;
    parent.appendChild(txtAetitle);
    
    // create feedback label
    this.lblFeedback = document.createElement('span');
    parent.appendChild(this.lblFeedback);

}
```

A new question should arise here: _How to we interact with Dicoogle from here?_

### Dicoogle API

Interfacing with the Dicoogle instance is done through the Dicoogle client API, in the [`dicoogle-client`](https://github.com/bioinformatics-ua/dicoogle-client-js) package.
The package can be included in separate applications, but when developing web plugins, we don't have to. Instead, a global variable `Dicoogle` is exposed with all of the features. The operations available are all listed in the [Dicoogle Client documentation](https://bioinformatics-ua.github.io/dicoogle-client-js/interfaces/_types_dicoogle_client_d_.dicoogleclient.dicoogleaccess.html). In particular, we are looking for two methods:

- [`Dicoogle.getAETitle(fn)`](https://bioinformatics-ua.github.io/dicoogle-client-js/interfaces/_types_dicoogle_client_d_.dicoogleclient.dicoogleaccess.html#getaetitle) ─ to retrieve the AE title currently set on the archive.
- [`Dicoogle.setAETitle(aetitle, fn)`](https://bioinformatics-ua.github.io/dicoogle-client-js/interfaces/_types_dicoogle_client_d_.dicoogleclient.dicoogleaccess.html#setaetitle) ─ to set the title of the archive's AE.

With a bit of client-side programming, one may come up with something like this:

```javascript
render(parent, slot) {
    // create text input
    const txtAetitle = document.createElement('input');
    txtAetitle.type = 'text';
    txtAetitle.className = 'form-control';
    txtAetitle.style = `
        display: inline-block;
        width: 16em;
        margin-right: 1em;
    `;
    txtAetitle.disabled = true;
    parent.appendChild(txtAetitle);
    
    // create feedback label
    const lblFeedback = document.createElement('span');
    parent.appendChild(lblFeedback);

    // request for the current AE title
    Dicoogle.getAETitle((err, aetitle) => {
        if (err) {
            console.error("Service failure", err);
            return;
        }
        // put value in text box and make it editable
        txtAetitle.value = aetitle;
        txtAetitle.disabled = false;

        // add a handle to pressing the enter key
        txtAetitle.addEventListener('keyup', function(event) {
            event.preventDefault();
            if (event.keyCode == 13) {
                // handle submitting a new AE title
                const aetitle = txtAetitle.value;
                lblFeedback.innerText = "...";
                Dicoogle.setAETitle(aetitle, (err) => {
                    if (err) {
                        console.error("Service failure", err);
                        lblFeedback.innerText = "Service failed";
                        return;
                    }
                    lblFeedback.innerText = "\u2714";
                    // make tick mark disappear after a small while
                    setTimeout(() => {
                        lblFeedback.innerText = "";
                    }, 700);
                });
            }
        });
    });
}
```

Let's repeat the installation process by running `npm install` ad copying the updated _"module.js"_ file to the deployment folder. We may now enter the web application again and see that the changes have taken effect.

![]({{ site.baseurl }}/images/screenshot_webplugin_settings_aetitle.png)

<div class="note info">
  <h5>Web plugins are cached by the browser!</h5>
  <p>If you find that the plugins are not being updated properly, you may have to temporarily disable caching in your browser. This shouldn't come up as an issue in production, since web plugins do not change frequently.</p>
</div>

## Further information

The rest of this page contains further details about Dicoogle web plugins and how they work.

### Dicoogle Webcore

The Dicoogle webcore is one of the components of the webapp that serves as a backbone to web UI plugins. The essence of this architecture is that Dicoogle web pages will contain stub slots where plugins can be attached to. The webcore implements this logic, and the source code can be found [here](https://github.com/bioinformatics-ua/dicoogle/tree/master/webcore). 

### Plugin descriptor

A descriptor takes the form of a "package.json", an `npm` package descriptor, containing at least these attributes:

 - `name` : the unique name of the plugin (must be compliant with npm)
 - `version` : the version of the plugin (must be compliant with npm)
 - `description` _(optional)_ : a simple, one-line description of the package
 - `dicoogle` : an object containing Dicoogle-specific information:
      - `caption` _(optional, defaults to name)_ : an appropriate title for being shown as a tab (or similar) on the web page
      - `slot-id` : the unique ID of the slot where this plugin is meant to be attached
      - `module-file` _(optional, defaults to "module.js")_ : the name of the file containing the JavaScript module

In addition, these attributes are recommended:

  - `author` : the author of the plugin
  - `tags` : the tags "dicoogle" and "dicoogle-plugin" are recommended
  - `private` : if you do not intend to publish the plugin into an npm repository, set this to `true`.

An example of a valid "package.json":

```json
{
  "name" : "dicoogle-cbir-query",
  "version" : "0.0.1",
  "description" : "CBIR Query-By-Example plugin",
  "author": "John Doe <jdoe@somewhere.net>",
  "tags": ["dicoogle", "dicoogle-plugin"],
  "dicoogle" : {
    "caption" : "Query by Example",
    "slot-id" : "query",
    "module-file" : "module.js"
  }
}
```

### Module

In addition, a JavaScript module must be implemented, containing the entire logic and rendering of the plugin.
The final module script must be exported in CommonJS format (similar to the Node.js module standard), or using
the standard ECMAScript default export, when transpiled with Babel.
The developer may also choose to create the module under the UMD format, although this is not required. The developer
can make multiple node-flavored CommonJS modules and use tools like browserify to bundle them and embed dependencies.
Some of those however, can be required without embedding. In particular, some modules such as "react", "react-dom",
and "dicoogle-client" can be imported externally, and so must be marked as external dependencies.

The exported module must be a single constructor function (or class), in which instances must have a `render(parent, slot)` method:

```javascript
/** Render and attach the contents of a new plugin instance to the given DOM element.
 * @param {DOMElement} parent the parent element of the plugin component
 * @param {DOMElement} slot the DOM element of the Dicoogle slot
 * @return Alternatively, return a React element while leaving `parent` intact. (Experimental, still unstable!)
 */
function render(parent, slot) {
    // ...
}
```

<div class="note unreleased" >
<h5>On support for React components</h5>
<p>The latest version allows users to render React elements by returning them from the render method instead of attaching
bare DOM elements to the parent div. However, this feature is unstable and known not to work very well. Future versions
may allow a smooth approach to developing web plugins in a pure React environment. In the mean time, it is possible to
use React by calling <code>render</code> directly on <code>parent</code>.</p>
</div>

Furthermore, the `onResult` method must be implemented if the plugin is for a "result" slot:

```javascript
/** Handle result retrieval here by rendering them.
 * @param {object} results an object containing the results retrieved from Dicoogle's search service 
 */
function onResult(results) {
    // ...
}
```

All modules will have access to the `Dicoogle` plugin-local alias for interfacing with Dicoogle.
Query plugins can invoke `issueQuery(...)` to perform a query and expose the results on the page (via result plugins).
Other REST services exposed by Dicoogle are easily accessible with `request(...)`.
See the [Dicoogle JavaScript client package](https://github.com/bioinformatics-ua/dicoogle-client-js) and the Dicoogle
Web API section below for a more thorough documentation.

Modules are meant to work independently, but can have embedded libraries if so is desired. In
addition, if the underlying web page is known to contain specific libraries, then these can also be used without being
embedded. This is particularly useful to avoid replicating dependencies and prevent modules from being too large.

Below is an example of a plugin module.

```javascript
module.exports = function() {

  // ...

  this.render = function(parent, slot) {
    var e = document.create('span');
    e.innerHTML = 'Hello Dicoogle!';
    parent.appendChild(e);
  };
};
```

Exporting a class in ECMAScript 6 also works (since classes are syntatic sugar for ES5 constructors).
The code below can be converted to ES5 using Babel:

```javascript
export default class MyPluginModule() {

  render(parent) {
    let e = document.create('span');
    e.innerHTML = 'Hello Dicoogle!';
    parent.appendChild(e);
  }
};
```

### Dicoogle Web API

Either `require` the `dicoogle-client` module (if the page supports the operation) or use the alias `Dicoogle` to 
access and perform operations on Dicoogle and the page's web core. All methods described in
[`dicoogle-client`](https://github.com/bioinformatics-ua/dicoogle-client-js) are available. Furthermore, the web
core injects the following methods:

#### **issueQuery** : `function(query, options, callback)`

Issue a query to the system. This operation is asynchronous and will automatically issue back a result exposal to the
page's result module. The query service requested will be "search" unless modified with the _overrideService_ option.

 - _query_ an object or string containing the query to perform
 - _options_ an object containing additional options (such as query plugins to use, result limit, etc.)
     - \[_overrideService_\] {string} the name of the service to use instead of "search"
 - _callback_ an optional callback function(error, result)

####  **addEventListener** : `function(eventName, fn)`

Add an event listener to an event triggered by the web core.

 - _eventName_ : the name of the event (can be one of 'load','menu' or a custom one)
 - _fn_ : a callback function (arguments vary) -- `function(...)`

#### **addResultListener** : `function(fn)`

Add a listener to the 'result' event, triggered when a query result is obtained.

 - _fn_ : `function(result, requestTime, options)`

#### **addPluginLoadListener** : `function(fn)`

Add a listener to the 'load' event, triggered when a plugin is loaded.

 - _fn_ : `function(Object{name, slotId, caption})`

#### **addMenuPluginListener** : `function(fn)`

Add a listener to the 'menu' event, triggered when a menu plugin descriptor is retrieved.
This may be useful for a web page to react to retrievals by automatically adding menu entries.

 - _fn_ : `function(Object{name, slotId, caption})`

#### **emit**: `function(eventName, ...args)`

Emit an event through the webcore's event emitter.

 - _eventName_ : the name of the event
 - _args_ : variable list of arguments to be passed to the listeners

#### **emitSlotSignal**: `function(slotDOM, eventName, data)`

Emit a DOM custom event from the slot element.

 - _slotDOM_ : the slot DOM element to emit the event from
 - _name_ : the event name
 - _data_ : the data to be transmitted as custom event detail

### Webcore Events

Full list of events that can be used by plugins and the webapp. _(Work in Progress)_

 - "load" : Emitted when a plugin package is retrieved.
 - "result" : Emitted when a list of search results is obtained from the search interface.

---------

Further details about web UI plugins may be obtained in the [webcore project](https://github.com/bioinformatics-ua/dicoogle/tree/master/webcore). 
