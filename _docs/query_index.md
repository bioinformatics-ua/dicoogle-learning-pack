---
title: Query & Index Plugins
permalink: /docs/query_index/
---

As Dicoogle is an archive, the means of indexing and retrieving information are important. Rather than being restricted to a specific database management system, Dicoogle can be extended to support different technologies for storing DICOM meta-data, and sometimes even processed data. This is achieved with the Query and Index plugin pair, which usually go hand-in-hand:

- **Indexer plugins** (also called indexing or just index plugins) take incoming requests for indexing objects and processes it for future retrieval.
- **Query plugins** (also called query providers) interpret queries from the user and return lists of results based on that query.


## Indexer

Indexing is a process in which documents are recorded for future retrieval. In Dicoogle, this is performed in the background by deploying indexing tasks (this can be done with the user interface, as mentioned in [Indexing a Directory]({{ site.baseurl }}/docs/using#indexing-a-directory)).

Indexer plugins are made by implementing [`pt.ua.dicoogle.sdk.IndexerInterface`](https://github.com/bioinformatics-ua/dicoogle/blob/2.4.0/sdk/src/main/java/pt/ua/dicoogle/sdk/IndexerInterface.java).

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

We can identify the essential **index** and **unindex** operations. However, the existence of two `index` method overloads may bring some confusion:

- `index(StorageInputStream, Object...)` is used to index a single item. A storage input stream is the Dicoogle file abstraction explained in [Storage Plugins]({{ site.baseurl }}/docs/storage).

- `index(Iterable<StorageInputStream>, Object...)` takes a stream of files and indexes all of them. As database management systems can often take advantage of processing batches of items instead of one at a time, this method can result in better performance with the creation of less transactions.

Unlike the remaining methods, one must also notice that they return a `Task<Report>`, which is a future-like object. This is because _indexing operations are asynchronous_. Rather than executing the concrete operation, these methods should return a future to be run asynchronously. The final report object usually contains a few counters for the number of files indexed and the number of errors occurred in the process. A Dicoogle task can be constructed by passing an anonymous class object of the type `Callable` (or Dicoogle's `ProgressCallable` for an extended variant which can provide the task's progress) to a `Task` constructor. Here is an example of boilerplate which can be applied to most indexers:

```java
@Override
public Task<Report> index(final Iterable<StorageInputStream> files, Object... args) {
    logger.info("Task issued: index batch of files");

    return new Task<>(() -> {
        int nIndexed = 0;
        int nErrors = 0;
        long time = System.currentTimeMillis();
        for(StorageInputStream file : files) {
            try {
                if(!handles(file.getURI())) continue;
                
                // TODO index file here
                
                nIndexed += 1;
            }
            catch (ClosedByInterruptException ex) {
                logger.info("Task was cancelled");
                break;
            }
            catch(IOException e) {
                logger.warn("Failed to index file {}", file.getURI(), e);
                nErrors += 1;
            }
        }
        
        // TODO commit/flush everything here

        return new IndexReport2(nIndexed, nErrors, System.currentTimeMillis() - time);
    });
}
```

The remaining methods should be easier to implement:

- `boolean handles(URI)` should return false when (and only when) it is sure that the file cannot be indexed, by observation of its URI. This method exists in order to filter out files that are obviously not medical images (*\*.txt*, *.DS_Store*, ...). However, there are situations where this is not reliable, since the storage is free to establish its own file naming rules, and that can affect the file extension. Even valid DICOM files do not need to end with _.dcm_. Unless you have a good reason to have something else, it is recommended to have this method return `true` unconditionally. Attempts to read invalid files can be handled gracefully by the indexer by capturing exceptions instead.
- `boolean unindex(URI)` should remove the records of the file identified by the given URI. This process must not remove the file from storage, but should  make it no longer appear in respective searches eventually. When successfully removed, this method returns `true`.


## Query Provider

As the other side of the coin, [`pt.ua.dicoogle.sdk.QueryInterface`](https://github.com/bioinformatics-ua/dicoogle/blob/2.4.0/sdk/src/main/java/pt/ua/dicoogle/sdk/QueryInterface.java) enables users and developers to search over the created index. The interface contains a single method:

```java
/**
 * Query Interface Plugin. Query plugins provide a means of handling queries and obtaining search results.
 * They will usually rely on indices created by an indexer plugin.
 */
public interface QueryInterface extends DicooglePlugin 
{
    /**
     * Performs a search on the database.
     * 
     * The consumer of the results would either request an iterator or use a for-each loop. The underlying
     * iterator implementation can be redefined to wait for more results at the caller.
     *
     * @param query a string describing the query. The underlying plugin is currently free to follow any
     * query format, but only those based on Lucene with work with the search user interface.
     * @param parameters A variable list of parameters of the query. The plugin can use them to establish
     * their own API's, which may require more complex data structures (e.g. images).
     * 
     * @return the results of the query as a (possibly lazy) iterable
     */
    public Iterable<SearchResult> query(String query, Object ... parameters);
}
```

Basically, the method receives a query for data in this provider, and returns the results of performing that query. The input is usually a string that represents what the user wishes to fetch from this source. In a DICOM source, this should follow the classic [Lucene query parser syntax](https://lucene.apache.org/core/6_6_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#package.description) so that information can be properly retrieved by the web application and other plugins.

The return type may appear to be very vague: [`java.lang.Iterable`](https://docs.oracle.com/javase/8/docs/api/java/lang/Iterable.html) is a standard Java interface for anything that can be traversed. The for-each loop syntax is available to all types which implement Iterable. Collections such as lists, sets and deques already implement this interface, which means that a traditional `ArrayList` with the results can be returned from this method. However, containing the full list of results in memory can be too inefficient. For this reason, a custom `Iterable` can be provided, which can lazily retrieve results as they are requested. As part of Dicoogle's contract of use, _the iterable will only be traversed once_, which also means that a possible implementation of `Iterable` is to return a pre-fabricated iterator yielding the results in sequence.

```java
Iterator<SearchResults> it = getResults();
return new Iterable<T>() {
    @Override
    public Iterator<T> iterator() {
        return it;
    }
};
```

It is also possible to transform a Java 8 [`Stream`](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html) into this kind of iterable with the utility function below:

```java
/** Create a good-for-one-use iterable from a stream.
  * 
  * @param <T> the element data type
  * @param stream the stream
  * @return a new iterable
  */
public static <T> Iterable<T> fromStream(Stream<T> stream) {
    return new Iterable<T>() {
        @Override
        public Iterator<T> iterator() {
            return stream.iterator();
        }

        @Override
        public Spliterator<T> spliterator() {
            return stream.spliterator();
        }

        @Override
        public void forEach(Consumer<? super T> cnsmr) {
            stream.forEach(cnsmr);
        }
    };
}
```
