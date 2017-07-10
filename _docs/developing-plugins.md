---
title: Developing Plugins
permalink: /docs/developing-plugins/
---

Dicoogle is extendable in deployment time, thanks to its plugin-based architecture. In order to integrate additional features over Dicoogle, you may create your own plugin set. A `PluginSet` is a composition of plugins developed with the intent of supporting a given functionality. There are 5 particular types of plugins:

- **Storage** plugins are responsible for storing and retrieving data. A basic implementation would keep files in the local file system, but Dicoogle can be extended to support remote storage with plugins of this type.
- **Indexer** plugins implement index generation. A fully deployed instance of Dicoogle should have at least one DICOM indexer.
- **Query** plugins provide a means of querying the indexed data. Often a query provider is coupled with a particular indexer, and are bundled together in the plugin set.
- **Jetty Service** plugins support the attachment of Eclipse jetty servlets, so as to host new web services in Dicoogle.
- **Rest Web Service** plugins contain a Restlet server resource that can be attached to Dicoogle, also for hosting web services.
- **Web User Interface** Plugins, unlike other kinds of plugins, are developed in JavaScript and provide new UI components that are automatically loaded into Dicoogle's web application.

## Frequently Asked Questions

Here is a list of tasks frequently performed when developing plugins for Dicoogle.

### How are plugins registered into the platform?

As mentioned above, this is done with a plugin set. Create a class that implements [`PluginSet`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/PluginSet.java) and apply the `@PluginImplementation` annotation on the class, which allows the plugin framework to fetch the set from the core platform. The constructors should create one instance of each plugin intended, and the plugin getters should provide an immutable list of plugins. When a plugin set does not provide any plugins of a certain type, the respective getter should return an empty list (such as `Collections.EMPTY_LIST`). Moreover, name getters should provide a simple, unique name for all plugins of that type. For instance, a query provider and indexer can share the same name, but two distinct query providers can not.

```java
@PluginImplementation
public class MyPluginSet implements PluginSet {
    // use slf4j for logging purposes
    private static final Logger logger = LoggerFactory.getLogger(MyPluginSet.class);
    
    // You can list each of our plugins as an attribute to the plugin set
    private final MyQueryProvider query;
    
    // Additional resources may be added here.
    private ConfigurationHolder settings;
    
    public MyPluginSet() throws IOException {
        logger.info("Initializing My Plugin Set");

        // construct all plugins here
        this.query = new MyQueryProvider();
        
        logger.info("My Plugin Set is ready");
    }

    @Override
    public Collection<QueryInterface> getQueryPlugins() {
        return Collections.singleton((QueryInterface) this.query);
    }
    
    @Override
    public String getName() {
        return "mine";
    }

    // ... implement the remaining methods
}
```

### How do plugins access the platform?

Interactions with the core platform are made via the [`PlatformInterface`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/core/DicooglePlatformInterface.java). This is the top-level API of Dicoogle that is exposed to other plugins.

In order to obtain this platform interface, plugins (or the plugin set) need to implement the interface [`PlatformCommunicatorInterface`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/core/PlatformCommunicatorInterface.java). The method `setPlatformProxy` declared therein behaves like a callback, which will be called by the platform shortly after the plugin is loaded. Usually, plugins can simply pass the argument into an attribute for future use:

```java
public class MyQueryPlugin 
        implements QueryInterface, PlatformCommunicatorInterface
    private DicooglePlatformInterface platform;

    // ... other content

    @Override
    void setPlatformProxy(DicooglePlatformInterface platform) {
        this.platform = platform;
    }
```

### How do I query for DICOM meta-data?

There should be at least one DIM content provider in a deployed instance of Dicoogle. Let us assume that the plugin is named "lucene". First retrieve the appropriate `QueryInterface`, then call the query method with the intended query. For DICOM meta-data providers, the query should follow the Apache Lucene query language.

```java
QueryInterface provider = this.platform.getQueryPlugin("lucene");
Iterable<SearchResult> results = provider.query("Modality:CT AND AXIAL");
for (SearchResult res: results) {
   // use results
}
```

The outcome is a sequence of search results, which is possibly lazy. You should not traverse the outcome more than once. In order to manipulate the list further, please save the results into a list such as `ArrayList`.

At the moment, plugins that rely on DICOM content are recommended to support a configurable DIM query source, rather than hard-coding "lucene" as the provider. Future versions of Dicoogle should provide a means to retrieve the default DIM query source directly from the core platform, as this is a planned feature.

### How do I access files in storage?

Dicoogle provides an abstraction for accessing files from any kind of data source. Instead of using standard Java I/O APIs, plugins should retrieve the appropriate storage interface ([`StorageInterface`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/StorageInterface.java) class). Once with the intended storage, the method `at` can be used to obtain a sequence of all files at the given location.

```java
URI uri = ...;
StorageInterface store = this.platform.getStorageForSchema(uri);
Iterable<StorageInputStream> files = store.at(uri);
```

[`StorageInputStream`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/StorageInputStream.java) is an abstraction for files in a storage (like a blob of data, not necessarily in the file system), from which a raw input stream can be retrieved.

### What if I want to retrieve a file by SOPInstanceUID?

First query the DIM provider for the file with that UID, then retrieve the URI from the search result:

```java
String uid = "1.2.3.4";
QueryInterface dimProvider = this.platform.getQueryProviderByName("lucene", true);
Iterator<SearchResult>> results = dimProvider.("SOPInstanceUID:" + uid).iterator();
if (results.hasNext()) {
    SearchResult res = results.next();
    URI uri = res.getURI();
    Iterable<StorageInputStream> files = this.platform.getStorageForSchema(uri).at(uri);
    // use files
} else {
    // no such file
}
```

### How do I read and write settings?

All plugins and plugin sets implement the method [`setSettings`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/DicooglePlugin.java#L73), which is also similar to a callback. The platform will call this method with a configuration holder after instantiation.

A typical implementation of this method should save the configuration holder to an attribute and check that the settings are ok. Fetching the actual settings currently yields an Apache Commons 1.x `XmlConfiguration` object (a user guide can be read [here](https://commons.apache.org/proper/commons-configuration/userguide_v1.10/user_guide.html)). The method may also write missing fields with default values.

```java
@Override
public void setSettings(ConfigurationHolder configurationHolder) {
    this.settings = configurationHolder;

    XmlConfiguration configuration = this.settings.getConfiguration();

    try {
        // required field, will throw if missing
        String uid = configuration.getString("service-uid");
    } catch (RuntimeException ex) {
        logger.warn("Failed to configure plugin: required fields are missing!", ex);
    }

    // optional field, default is 1
    int numResources = configuration.getInt("num-resources", 1);
    configuration.setProperty("num-resources", numResources); // write field

    try {
        configuration.save();
    } catch (ConfigurationException ex) {
        logger.warn("Failed to save configurations!", ex);
    }
    this.uid = uid;
    this.numResources = numResources;
}

// And don't forget to implement `getSettings()`!
@Override
public ConfigurationHolder getSettings() {
    return this.settings;
}
```

Also note that, in the latest version of Dicoogle, the plugin will be disabled if this method throws an unchecked exception.

### How do I create new web services?

Web services are one of the most flexible ways of expanding Dicoogle with new features. Currently, there are two ways to achieve this:

- *Jetty Servlets* can be created and registered using a plugin of type [`JettyPluginInterface`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/JettyPluginInterface.java). Create your own servlets (see [`HttpServlet`](https://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServlet.html)), then attach them into a handler list in `getJettyHandlers`:

```java
@Override
public HandlerList getJettyHandlers() {

    // encapsulate servlets into holders, then add them to handlers.
    ServletContextHandler handler = new ServletContextHandler();
    handler.setContextPath("/sample");
    handler.addServlet(new ServletHolder(this.webService), "/hello");
        
    // you can retrieve plugin-scoped resources
    URL url = RSIJettyPlugin.class.getResource("/WEBAPP");
    String directoryToServeAssets = url.toString();
        
    // web app contexts are more appropriate for serving web pages
    final WebAppContext webpages = new WebAppContext(directoryToServeAssets, "/dashboardSample");
    webpages.setInitParameter("org.eclipse.jetty.servlet.Default.dirAllowed", "true"); // disables directory listing
    webpages.setWelcomeFiles(new String[]{"index.html"});

    // add all handlers to a handler list and return it
    HandlerList l = new HandlerList();
    l.addHandler(handler);
    l.addHandler(webpages);

    return l;
}
```

- *Rest Service* plugins consider a subset of the Restlet framework API, allowing developers to create and attach simple server resources. Their integration is simpler, although more brittle. A proposal for better Restlet support is currently in review. In the mean time, server resources can be implemented and integrated by creating a new [`ServerResource`](https://restlet.com/technical-resources/restlet-framework/javadocs/2.1/jse/api/org/restlet/resource/ServerResource.html) like this:

```java
public class RSIWebResource extends ServerResource {
    
    @Get
    public Representation test() {
        StringRepresentation sr = new StringRepresentation("{\"name\":\"rsi\"}");
        sr.setMediaType(MediaType.APPLICATION_JSON);
        return sr;
    }
    
    // You can handle all CRUD operations. More information in the Restlet documentation.
    
    /** `toString` defines the service endpoint. */
    @Override
    public String toString() {
        return "service/endpoint/test";
    }

}
```

In either case, do not forget to [register all plugins in the plugin set]({{ site.baseurl }}/docs/developing-plugins#how-are-plugins-registered-into-the-platform).
