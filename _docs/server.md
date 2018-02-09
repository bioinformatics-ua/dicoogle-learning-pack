---
title: Service Plugins
permalink: /docs/server/
---

Web services are one of the most flexible ways of expanding Dicoogle with new features. Currently, there are two ways to achieve this:

- *Jetty Servlets* can be created and registered using a plugin of type [`JettyPluginInterface`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/JettyPluginInterface.java). Create your own servlets (see [`HttpServlet`](https://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServlet.html)), then attach them into a handler list in `getJettyHandlers`:

- *Rest Service* plugins consider a subset of the Restlet framework API, allowing developers to create and attach simple server resources. Their integration is simpler, although more brittle. A proposal for better Restlet support is currently in review. In the mean time, server resources can be implemented and integrated by creating a new [`ServerResource`](https://restlet.com/technical-resources/restlet-framework/javadocs/2.1/jse/api/org/restlet/resource/ServerResource.html) like this:

## Jetty Servlets

The servlet API is a versatile means of creating services in Java server applications.

A servlet class should inherit from the `HttpServlet` class. It may then override one or more of the HTTP request method handlers (`doGet`, `doPost`, `doPut`, and so on).

```java
public class MyWebServlet  extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse response)
                    throws ServletException, IOException {

        String name = req.getParameter("name");
        response.setContentType("application/json");
        JSONObject o = new JSONObject();
        o.put("name", name);
        response.getWriter().print(o.toString());
    }
}
```

Through the [`JettyPluginInterface`](https://github.com/bioinformatics-ua/dicoogle/blob/master/sdk/src/main/java/pt/ua/dicoogle/sdk/JettyPluginInterface.java), a list of Jetty server handlers ([`HandlerList`](https://www.eclipse.org/jetty/javadoc/current/org/eclipse/jetty/server/handler/HandlerList.html)) is passed to the core system, to be attached to the main Dicoogle web server.
Below is a possible implementation of the `getJettyHandlers()` method:

```java
@Override
public HandlerList getJettyHandlers() {

    // encapsulate servlets into holders, then add them to handlers.
    ServletContextHandler handler = new ServletContextHandler();
    handler.setContextPath("/sample");
    handler.addServlet(new ServletHolder(this.myWebService), "/hello");

    // add all handlers to a handler list and return it
    HandlerList l = new HandlerList();
    l.addHandler(handler);

    return l;
}
```

An instance of this class must be created, preferably in the plugin set constructor.
Then, it must be registered into the platform by returning the plugin via the [`PluginSet#getJettyPlugins`](https://github.com/bioinformatics-ua/dicoogle/blob/dev/sdk/src/main/java/pt/ua/dicoogle/sdk/PluginSet.java#L87) method.

## RESTlet services

The RESTlet API is a bit more straightforward and simple, albeit more limited in some cases.
The REST services implemented are directly described by method prototypes and annotations instead of a fixed set of methods.
Dicoogle enables the attachment of RESTlet server resources. See an example below.

```java
public class RSIWebResource extends ServerResource {
    
    @Get
    public Representation test() {
        StringRepresentation sr = new StringRepresentation("{\"name\":\"hello\"}");
        sr.setMediaType(MediaType.APPLICATION_JSON);
        return sr;
    }
    
    // You can handle all CRUD operations. More information in the Restlet documentation.
    
    // `toString` defines the service endpoint.
    @Override
    public String toString() {
        return "service/endpoint/test";
    }
}
```

Likewise, an instance of this class must be created and registered through the [`PluginSet#getRestPlugins`](https://github.com/bioinformatics-ua/dicoogle/blob/dev/sdk/src/main/java/pt/ua/dicoogle/sdk/PluginSet.java#L79) method.
