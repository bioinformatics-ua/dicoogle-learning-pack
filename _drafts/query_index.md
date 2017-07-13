---
title: Query & Index Plugins
permalink: /docs/query_index/
---

As Dicoogle is an archive, the means of indexing and retrieving information are important. Rather than being restricted to a specific database management system, Dicoogle can be extended to support different technologies for storing DICOM meta-data, and sometimes even processed data. This is achieved with the Query and Index plugin pair, which usually go hand-in-hand:

- **Indexer plugins** (also called indexing or just index plugins) take incoming requests for indexing objects and processes it for future retrieval.
- **Query plugins** interpret queries from the user and return lists of results based on that query.

WIP

### Indexer

Indexer plugins are made by implementing [`pt.ua.dicoogle.sdk.IndexerInterface'](https://github.com/bioinformatics-ua/dicoogle/blob/2.4.0/sdk/src/main/java/pt/ua/dicoogle/sdk/IndexerInterface.java).

Let's have a look at this interface and examine each method.

```java
/**
 * Index Interface Plugin. Indexers analyze documents for performing queries. They may index
 * documents by DICOM metadata for instance, but other document processing procedures may be involved.
 */
public interface IndexerInterface extends DicooglePlugin {

    /**
     * Indexes the file path to the database. Indexation procedures are asynchronous, and will return
     * immediately after the call. The outcome is a report that can be retrieved from the given task
     * as a future.
     *
     * @param file directory or file to index
     * @return a representation of the asynchronous indexation task
     */
    Task<Report> index(StorageInputStream file, Object ... parameters);

    /**
     * Indexes multiple file paths to the database. Indexation procedures are asynchronous, and will return
     * immediately after the call. The outcomes are aggregated into a single report and can be retrieved from
     * the given task as a future.
     *
     * @param files a collection of directories and/or files to index
     * @return a representation of the asynchronous indexation task
     */
    Task<Report> index(Iterable<StorageInputStream> files, Object ... parameters);

    
    /**
     * Checks whether the file in the given path can be indexed by this indexer. The indexer should verify if
     * the file holds compatible content (e.g. a DICOM file). If this method returns false, the file will not
     * be indexed.
     *
     * @param path a URI to the file to check
     * @return whether the indexer can handle the file at the given path
     */
    boolean handles(URI path);    
    
    /**
     * Removes the indexed file at the given path from the database.
     * 
     * @param path the URI of the document
     * @return whether it was successfully deleted from the database
     */
    boolean unindex(URI path);
}
```

We can identify the essential **index** and **unindex** operations. Other than that, the existence of two `index` method overloads may bring some confusion:

- `index(StorageInputStream, Object...)` is used to index a single item. A storage input stream is the Dicoogle file abstraction explained in [Storage Plugins]({{ site.baseurl }}/docs/storage).

- `index(Iterable<StorageInputStream>, Object...)` takes a stream of files and indexes them in a single transaction.

Unlike the remaining methods, one must also notice that it returns a `Task<Report>`, which is a future-like object. This is because _indexing operations are asynchronous_. Rather than executing the concrete operation, these methods should return a future to be run asynchronously. The final report object usually contains
a few counters for the number of files indexed and the number of errors occurred in the process.

WIP
