---
title: Web UI Plugins
permalink: /docs/webplugins/
layout: docs
---

<div class="note unreleased" >
<h5>Guidance for Dicoogle 3 coming soon</h5>
<p>This section is under reconstruction to become fully up to date with the latest version of Dicoogle.
You can keep track of the current progress in <a href="https://github.com/bioinformatics-ua/dicoogle-learning-pack/issues/26">this issue</a>.</p>
</div>

Dicoogle web user interface plugins, or just web plugins, are frontend-oriented pluggable components that live in the web application. The first section of this page is a tutorial that will guide you into making your first Dicoogle web plugin: a menu component to show a list of problems in the PACS. The second section will provide additional details about integrating web plugins and the APIs made available to them.

<div class="note unreleased" >
<h5>On web UI plugin support</h5>
<p>The Dicoogle web UI plugin architecture is currently not under the project's stability guarantees.
That is, each new release of Dicoogle might not be fully compatible with all web plugins.
Features known to work well with the latest stable release of Dicoogle
will be documented here in the Learning Pack.
When working with development versions,
the <a href="https://github.com/bioinformatics-ua/dicoogle/tree/master/webcore/README.md">README pages</a>
in the webcore sub-project
will be more up-to-date with changes in web plugin support.</p>
</div>

### Setting up a project

We will start by creating a Dicoogle web plugin project. Before we start, we must fulfill the following requirements:

- Node.js (LTS or Stable) ─ required for executing the building tools. 
- npm (at least version 6 required) ─ the JavaScript package manager, usually installed alongside Node.js.

Now, we will need two components to generate the barebones web plugin project.
The first one is the executable for [Yeoman](http://yeoman.io),
a project scaffolding application with a generator ecosystem.
The second one is a Dicoogle web plugin project generator,
developed specifically to facilitate the development of this kind of plugins.

Install the following two packages globally, using the following command:

```sh
npm install -g yo generator-dicoogle-webplugin
```

<div class="note info">
<h5>Installing packages globally might not work immediately.</h5>
<p>On Unix systems, you may need to fix the <a href="https://docs.npmjs.com/getting-started/installing-npm-packages-globally">npm permissions</a>. Although it is not recommended, you can also execute the command as super user (with <code>sudo</code>).</p>
</div>

While still on a command line, execute the following commands:

```sh
mkdir webplugin-troubleshoot
cd webplugin-troubleshoot
yo dicoogle-webplugin
```

The application will now be asking you a series of questions about the project.

- The **project name** will be the name of the npm project, and also the unique name of the plugin. We can leave the default by pressing Enter.
- The **description** is just a small text about the plugin, and is completely optional.
- Next you will be asked about the **type** of web plugin. For this example, we will select the `menu` type.
- Afterwards, you may need to choose whether to generate a JavaScript or a TypeScript project.
  An _ECMAScript2016+ project with Babel_ will include [Babel](https://babeljs.io)
  to guarantee the existence of features that were already standardized in ECMAScript.
  A [TypeScript](https://www.typescriptlang.org/) project will be configured to use a TypeScript compiler instead.
  TypeScript has its own supported set of JavaScript features,
  and useful type definitions around the Dicoogle development environment are included in the project.
  ECMAScript2016+ will let you write JavaScript directly,
  but can more easily be extended with Babel plugins.
  Any of the two kinds of projects should work fine for Dicoogle,
  but you might prefer the JavaScript project if you are not comfortable with TypeScript.
  On the other hand, a TypeScript project will provide you
  better IDE integration with static type checking and auto-complete facilities.
- The **minimum supported version** of Dicoogle can also be specified.
  The higher the version, the more mechanisms will be provided.
  When developing for the latest version,
  pick _the most recent one_ of the options given.
- The **caption** is a label that is shown in the web application. We will set this one to _"Troubleshoot"_.
- Finally, you are requested additional information about the project, which can be added in case of the project being put into a public repository. They are all optional.

After the process is complete, you will have a brand new project in your working directory.

### Building and installing

Before we make the necessary changes, let us see whether the created web plugin works. First we build the project:

```sh
npm install
```

This will yield, among others, a file named _"module.js"_. This one and _"package.json"_ make the full plugin.

We will now install this plugin as a standalone web plugin. Create a folder _"WebPlugins"_ in your _"DicoogleDir"_ folder.
Afterwards, create a directory _"troubleshoot"_ in _"WebPlugins"_ and copy the two files above into this folder. The directory tree should look like this:

```
 DicoogleDir
 ├── Plugins
 |   └── ...
 ├── WebPlugins
 |   └── troubleshoot
 |       ├── package.json
 |       └── module.js
 ├── storage
 |   └── ...
 ├── ...
 └── dicoogle.jar
```

Start Dicoogle and enter the web application, into the _Management_ menu. The _Services & Plugins_ sub-menu should now have our plugin.

![]({{ site.baseurl }}/images/screenshot_webplugin_menu_hello.png)

Once we know that it works, it's time to head back to our troubleshoot project.

### Implementing a Dicoogle troubleshooting panel

At this point, we now want to implement the intended functionality
The plugin should show a few boxes depending on potential issues found in the server:

- Whether no storage provider is installed;
- Whether no query or indexing provider is installed;
- Whether some of the plugins are dead (did not load properly).

The main question that arises would be: _Where do I implement that?_
Let's have a look at the generated source code in _"src/index.js"_
(assuming the _Babel_ project, the TypeScript project would contain the file _"src/index.ts"_ with similar content).

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

- The whole plugin is represented as a class, and this is the module's default export.
  Typically, you do not have to touch this.
- The constructor can be used to initialize certain parts of the plugin
  before any rendering takes place.
  It is not always needed.
- The `render` method is the most important portion of the plugin:
  it is where new HTML elements are created and written to the web app's document.
  The example shows how this can be done with the standard [Document Object Model (DOM) Web API](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model).
- In order to develop plugins safely,
  the elements should be attached as children to the `parent` element.

Instead of creating a div, we will create a header and other elements to provide information to the user.

```javascript
render(parent, slot) {
    // create header
    const head = document.createElement('h3');
    head.text = 'Troubleshoot';
    parent.appendChild(head);

    // create main info span
    const baseInfo = document.createElement('span');
    this.baseInfo = baseInfo;
    parent.appendChild(baseInfo);
    
    // create list of issues found
    this.ul = document.createElement('ul');
    parent.appendChild(this.ul);
}
```

A new question should arise here: _How do we interact with Dicoogle from here?_

### Interacting with Dicoogle

Interfacing with the Dicoogle instance is done through the Dicoogle client API, in the [`dicoogle-client`](https://github.com/bioinformatics-ua/dicoogle-client-js) package.
The package can be included by independent applications.
But when developing web plugins, we don't have to.
Instead, a global variable `Dicoogle` is automatically exposed with all of the features.
The operations available are listed in the [Dicoogle Client documentation](https://bioinformatics-ua.github.io/dicoogle-client-js/classes/_index_.dicoogleaccess.html).
In particular, we are looking for methods to retrieve information about the plugins:

- [`Dicoogle.getAETitle()`](https://bioinformatics-ua.github.io/dicoogle-client-js/classes/_index_.dicoogleaccess.html#getaetitle) ─ to retrieve the AE title currently set on the archive.

With a bit of client-side programming, one may come up with something like this:

```javascript
render(parent: HTMLElement, slot: SlotHTMLElement) {
    // create header
    const head = document.createElement('h3');
    head.innerText = 'Troubleshoot';
    parent.appendChild(head);

    // create main info span
    const baseInfo = document.createElement('span');
    baseInfo.innerText = 'Checking Dicoogle health...';
    parent.appendChild(baseInfo);

    // request for the full list of plugins
    Dicoogle.getPlugins().then(({ plugins, dead }) => {
        const problems = [];

        // check for no storage
        if (plugins.filter(p => p.type === 'storage').length === 0) {
            problems.push("No storage providers are installed");
        }

        // check for no DICOM query provider
        if (plugins.filter(p => p.type === 'query' && p.dim).length === 0) {
            problems.push("No DICOM data query providers are installed");
        }

        // check for no DICOM index provider
        if (plugins.filter(p => p.type === 'index' && p.dim).length === 0) {
            problems.push("No DICOM data indexers are installed");
        }

        if (dead.length > 0) {
            problems.push("The following plugins are dead: " + dead
                .map(p => `${p.name} (${p.cause.message})`).join(', '))
        }

        // update DOM with problems
        if (problems.length === 0) {
            baseInfo.innerText = "\u2713 No issues were found!";
        } else {
            baseInfo.innerText = `\u26a0 There are ${problems.length} ${problems.length === 1 ? "issue" : "issues"} in this installation.`;

            // create list of issues found
            const ul = document.createElement('ul');
            for (const problem of problems) {
                // one list item per problem
                let problemItem = document.createElement('li');
                problemItem.innerText = problem;
                ul.appendChild(problemItem);
            }
            parent.appendChild(ul);
        }
    });
}
```

Let's repeat the installation process by running `npm install` and copying the updated _"module.js"_ file to the deployment folder. We may now enter the web application again and see that the changes have taken effect.
<!-- TODO UPDATE IMAGE-->
![]({{ site.baseurl }}/images/screenshot_webplugin_menu_troubleshoot.png)

<div class="note info">
  <h5>Web plugins are cached by the browser!</h5>
  <p>If you find that the plugins are not being updated properly,
  you may have to temporarily clean up or disable caching in your browser.
  This shouldn't come up as an issue in production, since web plugins do not change frequently.</p>
</div>

## Further information

The rest of this page contains further details about Dicoogle web plugins and how they work.

### Dicoogle Webcore

The Dicoogle webcore is one of the components of the webapp that serves as a backbone to web UI plugins. The essence of this architecture is that Dicoogle web pages will contain stub slots where plugins can be attached to. The webcore implements this logic, and the source code can be found [here](https://github.com/bioinformatics-ua/dicoogle/tree/dev/webcore). 

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
The script that is to be loaded by Dicoogle must be in the CommonJS format (similar to the Node.js module standard),
using either `module.exports` or the export named `default`.
The developer may also choose to create the module under the UMD format, although this is not required. The developer
can make multiple node-flavored CommonJS modules and use tools like Webpack to bundle them and embed dependencies.
Some of those however, can be required without embedding. In particular, some modules such as "react", "react-dom",
and "dicoogle-client" can be imported externally through `require`, and so should be marked as external dependencies.

The exported module must be a single constructor function or class, in which instances must have a `render(parent, slot)` method:

```javascript
class MyPlugin {

  /** Render and attach the contents of a new plugin instance to the given DOM element.
  * @param {DOMElement} parent the parent element of the plugin component
  * @param {DOMElement} slot the DOM element of the Dicoogle slot
  */
  render(parent, slot) {
      // ...
  }
}
```

<div class="note unreleased" >
<h5>On support for React components</h5>
<p>The latest version allows users to render React elements by returning them from the render method instead of attaching
bare DOM elements to the parent div. However, this feature is unstable and known not to work very well. Future versions
may allow a smooth approach to developing web plugins in a pure React environment. In the meantime, it is possible to
use React by calling <code>ReactDOM.render</code> directly on <code>parent</code>.</p>
</div>

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

Exporting a class in ECMAScript 2015 also works, since classes are mostly syntatic sugar for ES5 constructors.
See the following example using the standard ECMAScript module system:

```javascript
export default class MyPluginModule() {

  render(parent, _slot) {
    let e = document.create('span');
    e.innerHTML = 'Hello Dicoogle!';
    parent.appendChild(e);
  }
};
```

This one will work if it converted to CommonJS with the right configuration.
For example:

- When using [Webpack](https://webpack.js.org),
  the `output.libraryTarget` property (`output.library.type` since Webpack 5) should be set to [`'commonjs2'`](https://webpack.js.org/configuration/output/#type-commonjs2).
- When using [Parcel](https://parceljs.org),
  the target's `outputFormat` property should be [`'commonjs'`](https://parceljs.org/features/targets/#outputformat)
  and the `context` should be ["browser"](https://parceljs.org/features/targets/#context).
- If using [Babel](https://babeljs.io) directly, ensure that [`targets.esmodules`](https://babeljs.io/docs/en/options#targetsesmodules) is set to `false`.

### Types of Web Plugins

As previously mentioned, we are requested to specify a a type of plugin, often with the "slot-id" property. This type defines
how webplugins are attached to the application. The following  Note that not all of them are fully supported at the moment.

- **menu**: Menu plugins are used to augment the main menu. A new entry is added to the side bar (named by the plugin's caption
  property), and the component is created when the user navigates to that entry.
- **result-option**: Result option plugins are used to provide advanced operations to a result entry. If the user activates
  _"Advanced Options"_ in the search results view, these plugins will be attached into a new column, one for each visible result entry.
- **result-batch**: Result batch plugins are used to provide advanced operations over an existing list of results. These plugins will
  attach a button (named with the plugin's caption property), which will pop-up a division below the search result view.
- **settings**: Settings plugins can be used to provide addition management information and control. These plugins will be attached to
  the _"Plugins & Services"_ tab in the _Management_ menu.


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

Further details about web UI plugins may be obtained in the [webcore project](https://github.com/bioinformatics-ua/dicoogle/tree/dev/webcore). 
