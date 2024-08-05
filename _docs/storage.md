---
title: Storage Plugins
permalink: /docs/storage/
layout: docs
---

Data storage stands as one of the primary requirements of a PACS archive. Medical imaging storage requirements
have become increasingly demanding, to the point that relying on a server's local file system has become
inadequate in some use cases. Delegating storage to cloud services, for instance, have been thoroughly discussed
in recent years.

Storage plugins (or storage providers) represent a particular "place" where files can be read and stored, and sometimes
also define _how_ these files are stored and read.
The Dicoogle Storage API serves the following two purposes:

- To make an abstraction over the underlying storage technology, thus being able to use and evaluate different sources of data storage (e.g. cloud storage services such as Amazon S3) and different forms of persistence (e.g. using a document-oriented database instead of a file system). With this common API, DICOM object reading and storing becomes possible, regardless of the underlying technology.
- To augment storage and retrieval procedures with certain algorithms, such as for anonymization, compression, and encryption.

Programmatically, the storage interface is currently defined as below:

```java
/** Storage plugin interface. These types of plugins provide an abstraction to reading and writing from
 * files or data blobs.
 */
public interface StorageInterface extends DicooglePlugin {    
    
    /**
     * Gets the scheme URI of this storage plugin.
     *
     * @see URI
     * @return a string denoting the scheme that this plugin associates to
     */
    public String getScheme();
    
    /**
     * Provides a means of iteration over existing objects at a specified location.
     * This method is particularly nice for use in for-each loops.
     * The provided scheme is not relevant at this point, but the developer must avoid calling
     * this method with a path of a different schema.
     * 
     * <pre>
     * for(StorageInputStream dicomObj : storagePlugin.at("file://dataset/")){
     *      // use dicomObj here
     * }
     * </pre>
     * 
     * @param location the location to read
     * @param parameters a variable list of extra parameters for the retrieve
     * @return an iterable of storage input streams
     * @see StorageInputStream
     */
    public Iterable<StorageInputStream> at(URI location, Object ... parameters);
    
    /**
     * Stores a DICOM object into the storage.
     *
     * @param dicomObject Object to be Stored
     * @param parameters a variable list of extra parameters for the retrieve
     * @return The URI of the previously stored Object.
     */
    public URI store(DicomObject dicomObject, Object ... parameters);

    /**
     * Stores a new element into the storage.
     *
     * @param inputStream an input stream with the contents to be stored
     * @param parameters a variable list of extra parameters for the retrieve
     * @return the URI of the stored data
     * @throws IOException if an I/O error occurs
     */
    public URI store(DicomInputStream inputStream, Object ... parameters) throws IOException;
    
    /** Removes an element at the given URI.
     */
    public void remove(URI location);

    /** Lists the elements at the given location in the storage's file tree.
     * Unlike `StorageInterface#at`, this method is not recursive and
     * can yield intermediate URIs representing other directories rather than
     * objects.
     */
    public default Stream<URI> list(URI location) throws IOException { ... }
}
```

### Storing files

The two `store` method overloads are used to store new objects. The only difference between
the overloads is that one takes a [`DicomInputStream`](http://medisa.net/dcm4che-2.0.25-apidocs/org/dcm4che2/io/DicomInputStream.html),
whereas the other takes a [`DicomObject`](http://medisa.net/dcm4che-2.0.25-apidocs/org/dcm4che2/data/DicomObject.html).
Unless the storage can take advantage of streamed processing, it is usual to read the stream into
an object (using [`DicomInputStream#readDicomObject`](http://medisa.net/dcm4che-2.0.25-apidocs/org/dcm4che2/io/DicomInputStream.html#readDicomObject))
and call the other method overload:

```java
public URI store(DicomInputStream inputStream, Object ... parameters) {
    DicomObject obj = inputStream.readDicomObject();
    return this.store(obj, parameters);
}
```

A unique identifier for the object is to be created by the storage and returned when successful. The stored object
should then become accessible by using the same URI. A traditional file storage might create a hierarchical URI based
on the DICOM object's meta-data (so as to categorize files by modality, study, series, and so on), and serialize it
into a file with its path defined by the URI. Therefore, a valid URI would be, for example:

```txt
file:/my-storage/MyHospital/CT/2004/06/07/patient1/001.dcm
```

<div class="note info">
  <h5>Remember when we indexed a directory in <a href="{{ site.baseurl }}/docs/using#indexing-a-directory">"Using Dicoogle"?</a></h5>
  <p>This is the approach made by the provided file storage plugin, which makes indexing of existing files easier: you can
infer the URI of a file just by looking at its path in the system! Although it is useful to have a trivial mapping such as this one,
this behaviour is not required for Dicoogle storages in general.
  </p>
</div>

### Fetching files

The `at` method introduces a new abstraction for files in a Dicoogle storage provider. The `StorageInputStream` interface,
despite the name, represents an item in storage (often a DICOM file). An ordinary Java input stream can be obtained
by calling `getInputStream()`. The code below would allow you to read a file as DICOM data. Indexers and other plugins
may instead interpret the file as images, or arbitrary binary data, depending on their purpose.

```java
Iterable<StorageInputStream> it = myStorage.at("file:/data/X/000.dcm");
StorageInputStream f = it.next(); // expect one file
DicomObject dcm = new DicomInputStream(f.getInputStream()).readObject();
// use DICOM object
```

Storage plugins are required to implement the logic behind obtaining a list of files by URI, as well as a class
type to be used as a `StorageInputStream`. The following should be kept in mind:

 - If the storage is hierarchical, calling `at` for a parent resource must recursively yield all files inside
that directory. This also means that `store.at("file:/")` would give us all files in storage.
 - As stores may end up having millions of entries, it is recommended to build a lazy iterable of the files upon
a call to `at`. For instance, the iterator may keep a queue of directories yet to be expanded to their respective
children.
 - _Never_ return `null` from this method, and _always_ return a valid iterable object, even if it has to be an empty one.

### Other methods

`getScheme()` should constantly return a string compatible with a URI scheme. A basic file storage plugin would use the `file`
scheme like this:

```java
@Override
public String getScheme() {
    return "file";
}
```

Dicoogle will identify whether a particular item in storage (existent or not yet existent)
should be handled by this plugin through the URI scheme.
By default, this check is done through an exact match.
That is, `file://CT/I0001.dcm` is handled by the plugin with `getScheme()` above,
but `file+ssl://CT/I0001.dcm` is not.
If you need to change this behavior, you can override the `handles(URI)` method.

```java
@Override
public boolean handles(URI location) {
    String scheme = location.getScheme();
    return scheme.equals("file") || scheme.equals("file+ssl");
}
```

`list()` was introduced in Dicoogle 3,
enabling storage interfaces to provide a list of entries
at a particular position in the storage tree.
Note that this is different from the method `at()`:
`list` is optional and provides a _shallow_ list of files and directories directly below the given directory,
whereas `at` is required and provides a full list of all files (leaf items) in storage at the given base directory.
Implementers may ignore this method,
but implemeting it may grant additional features to end applications.
Consumers of this method should catch `UnsupportedOperationException`
to handle situations in which the method is not implemented.
