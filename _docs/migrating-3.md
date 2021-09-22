---
title: Migration to Dicoogle 3
permalink: /docs/migration-3/
layout: docs
---

Dicoogle 3 was released in 2019,
with the purpose of taking down obsolete constructs
and bringing new features which influence the archive's overall performance.
This page will guide users and developers
towards migrating their PACS and extension software
for the major version 3 of Dicoogle.

## For Dicoogle User

As a PACS infrastructure maintainer or administrator,
the following points will cover what you need to know.

#### Java 8 is the minimum supported version

Dicoogle 2 still worked on a Java 7 runtime,
but it has been obsolete for a long time.
Dicoogle 3 requires Java 8,
and should also work on Java 11.
Support for more recent versions is slowly being incorporated,
but for now it is recommended to use either 8 or 11.

#### New server settings file

The server settings file has been redesigned to become easier to read
and contain new properties.
It is still an XML file,
and it bears multiple similarities with the old format.
Many properties have been renamed,
and new ones were brought in.
Properties which were no longer useful were removed as well.

Typically though, no special intervention is needed.
When booting, Dicoogle 3 will migrate an existing `config.xml` file
to use the new format, and save it in `confs/server.xml`.
If you validate that the migration was successful,
the file `config.xml` is then same to remove.

#### Plugins for Dicoogle 2 are not compatible with Dicoogle 3 

The plugin-based extension framework will expect plugins
made for the same major version of the Dicoogle SDK.
As such, the old plugins that were used in Dicoogle 2
must not be directly copied to a Dicoogle 3 deployment,
because that is not going to work.

If you are not the developer,
you will need to reach out to the maintainers of the plugins
and request that they are ported to work on Dicoogle 3.

## For Dicoogle Developers

As a developer of extensions for Dicoogle,
here are the main changes to keep in mind.

#### Update dicoogle-sdk

The major version of dicoogle-sdk needs to match
with the target Dicoogle platform.
Look for the respective `dependency` element in your `pom.xml` file
and update accordingly.

```xml
    <dependency>
        <groupId>pt.ua.ieeta</groupId>
        <artifactId>dicoogle-sdk</artifactId>
        <version>3.0.2</version>
    </dependency>
```

#### Remove `PluginSet#getGraphicalPlugins`

The Graphical plugin type has been non-functioning since early Dicoogle 2,
but the methods for their retrieval were not removed.
So, `getGraphicalPlugins` must be completely removed in all plugin sets.

In order to develop extensions to the user interface,
see the section on [Web UI plugins]({{ site.baseurl }}/docs/webplugins).

#### Server settings API with changes

If your plugin was fetching the server's settings
via the Dicoogle platform interface,
the object returned is now significantly different,
and so some changes may be needed.
See the [`ServerSettingsReader`](https://github.com/bioinformatics-ua/dicoogle/blob/3.0.2/sdk/src/main/java/pt/ua/dicoogle/sdk/settings/server/ServerSettingsReader.java)
class for more information.

#### New method `StorageInterface#list`

The new method `list` provides a shallow list of entries
given a URI representing a directory.
This is different from the method `at`,
which would make a full, nested traversal of all files in that directory.

Users of this method still need to assume that
it may throw `UnsupportedOperationException`,
as this is what the default implementation does.
When carefully checked,
it can be used to make quick estimations of
a process covering an entire directory,
or to obtain a tree-like vision of the storage.

#### No automatic query processing

In Dicoogle 2, when a user wrote a free text query on the search bar,
without any keyword terms such as `Modality:CT`,
that query would be preprocessed to search for that content
by multiple known DICOM attributes
(SOPInstanceUID, SeriesInstanceUID, AccessionNumber, PatientID, PatientName,
and many many others).
For instance, the query `PID123` would expand into a query
which included the term `PatientID:PID123` and many others,
thus capturing the files which had `PID123` in one of these attributes.
This process would also replace certain characters such as `^` into whitespace,
as it was often desirable when searching by person names.

In Dicoogle 3, this preprocessing is no longer done.
The `/search` endpoint still has the old behavior
behind the `expand` query string parameter,
but it is not used by the web application.
This is because query processing
should be under full control of the query provider itself,
and often the existing process was either unnecessary
or even detrimental to a good query provider behavior. 

Implementers of query providers which are also a source of DICOM data
may want to incorporate some form of query preprocessing internally
if they wish for free text queries to work like before.
Query providers based on Lucene
only need the right document construction logic
and indexing configurations
for these queries to work
without any form of query expansion.

#### `QueryInterface#query` can throw `QueryException`

The new exception type `QueryException`
is specifically for when a query could not be performed.
This allows consumers to make a distinction between errors with the given query
and other kinds of errors.

For implementers, a good place to throw `QueryException`
is when the parameter `query` is syntactically incorrect.

#### New extended trait `QueryDimInterface` 

Query interface objects may now also implement `QueryDimInterface`.
This extended form providess a way
to query at different levels in the DICOM Information Model.

Before this interface,
consumers of plain query interfaces wishing to obtain a list of studies
had to retrieve a list of images and aggregate them manually,
which can be unnecessarily expensive in studies with a large number of files.

With `QueryDimInterface`, when specifying a specific DIM level,
each search result will refer to a single instance at that level,
making searches less expensive.

In practice, you would want to use `instanceof`
to check whether a given query interface object implements it.
There is currently no utility method in the Dicoogle platform interface
to invoke these operations asynchronously.

```java
if (queryInterface instanceof QueryDimInterface) {
    ((QueryDimInterface) queryInterface).queryStudy("StudyInstanceUID:1.2.3.4.555");
    // ...
}
```

#### Default implementations for interface getters

Most methods in the plugin set
now have default implementations which do nothing
or return an empty list of plugins:

- `getIndexPlugins`
- `getQueryPlugins`
- `getStoragePlugins`
- `getRestPlugins`
- `getJettyPlugins`
- `shutdown`

If your plugin project does not have any plugins of a specific type,
it is safe to remove these methods,
as they are redundant.
In the case of `shutdown`,
it can be removed if it was going to be left empty anyway.
