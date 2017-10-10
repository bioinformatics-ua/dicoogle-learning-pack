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
     * Checks whether the file in the given path can be handled by this storage plugin.
     *
     * @param location a URI containing a scheme to be verified
     * @return true if this storage plugin is in charge of URIs in the given form 
     */
    public boolean handles(URI location);
    
    /**
     * Provides a means of iteration over existing objects at a specified location.
     * This method is particularly nice for use in for-each loops.
     * The provided scheme is not relevant at this point, but the developer must avoid calling
     * this method with a path of a different schema.
     * 
     * <pre>
     * for(StorageInputStream dicomObj : storagePlugin.at("file://dataset/")){
     *      System.err.println(dicomObj.getURI());
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
     * 
     * @param location the URI of the stored data
     */
    public void remove(URI location);
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
by calling `getInputStream()`.

<!-- TODO -->

### Other methods

`getScheme()` should return a constant string compatible with a URI scheme. A basic file storage plugin would use the `file`
scheme like this:

```java
public String getScheme() {
    return "file";
}
```

`handles(URI)` was made to verify whether the given URI can relate to an item (existent or inexistent) in this storage.
Since this is mean to be based uniquely on the scheme of the URI, one should use the implementation below: 

```java
public boolean handles(URI location) {
    Objects.requireNonNull(location);
    return Objects.equals(this.getScheme(), location.getScheme());
}
```
