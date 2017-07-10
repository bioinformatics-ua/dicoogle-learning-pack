---
title: Using Dicoogle
permalink: /docs/using/
---

In this section, we will be taking advantage of our newly deployed instance of Dicoogle to index and search in a small repository of medical images. Make sure that 

### Entering the Web Application

The web services are all served over the 8080 port by default. Let's open the page http://localhost:8080. You should be greeted with this page.

![The login page of the web app.]({{ site.baseurl }}/images/screenshot_login.png)

The default administration credentials are **dicoogle** for the username and, likewise, **dicoogle** for the password. Input these credentials to enter the main page.

![The main page of the web app.]({{ site.baseurl }}/images/screenshot_main.png)

### Obtaining a repository

Before we continue, we need a medical imaging data set to work on. Any directory tree with files in the DICOM format will work. A small data set is available [here](https://www.dropbox.com/sh/3enxs2h4h0m4ubz/AABqSdJ-OqPsR_CtcWeGMnBSa?dl=0), but many other free samples can be found online.

Retrieve one or more data sets and place them in a new folder where all our DICOM data will be kept. For this guide, we will create a _"storage"_ folder inside _"DicoogleDir"_. So, we should have this directory tree:

```
 .
 ├── DicoogleDir
 ├── Plugins
 |   ├── ...
 |   ├── lucene.jar
 |   └── filestorage.jar
 ├── storage
 |   ├── «my-dicom-data»
 |   └── ...
 └── dicoogle.jar
```

### Indexing a directory

Indexing a directory is done simply by accessing the Indexer page, on the side bar. In this page, there is a form that can be used to force Dicoogle to index the contents of a folder. For this example, we wish to index our data set by specifying its base directory. Dicoogle will recursively attempt to index all files in the folder, while traversing all folders within. Files that are not DICOM may be either ignored or trigger a warning, without further consequences.

![The indexer form.]({{ site.baseurl }}/images/screenshot_index.png)

<div class="note info">
  <h5>The “Index directory” field is a URI!</h5>
  <p>In Dicoogle, all DICOM instances (as in files) are associated to a <em>Unique Resource Identifier</em> (URI). With the local file system storage plugin, the URI of a file is, by default, the absolute path to that file with the <em>file</em> scheme. For example: <code>file:/path/to/DicoogleDir/storage/001.dcm</code>
  </p>
</div>

<div class="note warning">
  <h5>The “Index directory” field is not a file system path!</h5>
  <p>You may feel tempted to copy the full dataset path from your file explorer into this field. However, in Windows, back slashes are used to separate items in the path (<code>C:\DicoogleDir\storage\001.dcm</code>), and the storage device is identified with a letter, followed by a colon (such as <code>C:</code>).</p>
  
  <p> Windows file paths are not compatible with the URI format. When specifying a path, <em>always</em> use forward slashes (<code>/</code>) instead of back slashes (<code>\</code>). In addition, make sure that the URI includes the scheme <code>file:</code> as the prefix.</p>
</div>

A new indexing task will be listed. Please note that, depending on how many files are in the storage folder, this process may take some time.
Once complete, the progress bar will be at 100%, and the task can be closed by pressing the _"Close"_ button. Although a _"Stop"_ button is also provided, it is often not a good idea to cancel tasks prematurely.

### Using the Search Interface

The Search page enables users to execute queries over the indexed meta-data. It is also possible to select which providers to query. Query providers are actually _query plugins_. Since we only have _lucene_, this one will be used by default.

The query syntax is the same as Lucene's, which supports free text searches. Let us search for all CT scans by typing "CT" in the query box and pressing Enter:

![The search interface, followed by results.]({{ site.baseurl }}/images/screenshot_search.png)

After running a query, the result browser shows up, giving the user an intuitive hierarchical view of the results. Results are navigated according to the DIM hierachy: first patients, then studies, then series, and finally the images.

![The search results of a series at the image level.]({{ site.baseurl }}/images/screenshot_images.png)

We can see the indexed meta-data of an image by pressing the dump button ![]({{ site.baseurl }}/images/button_dump.png).

![The meta-data navigator of an image.]({{ site.baseurl }}/images/screenshot_dump.png)

It is also possible to see a larger preview of the image by pressing the eye button ![]({{ site.baseurl }}/images/button_eye.png) or by clicking on the image thumbnail.

<div class="note info">
  <h5>The image previewer is not a professional medical image viewer.</h5>
  <p>Medical images often have atypical visualization requirements, such as a larger colour bit depth than 8 bits, voxel-based 3D volumes, or even resolutions at the scale of several Giga-pixels. The built-in image previewer, on the other hand, is very limited and should not be used in professional activities such as screening. Such requirements can still be addressed with Dicoogle by extending it with professional tools.</p>
</div>

### Exporting Results

 On this page, there is also an _Export_ button, which is used to export the entire list of results into a comma-separated values (CSV) file. Once clicked, a new form is presented, where we need to specify which tags to consider in the CSV file. These are DICOM tag keywords, as specified in chapter 6 of the [DICOM standard, PS3.6](http://dicom.nema.org/medical/dicom/current/output/chtml/part06/chapter_6.html). Each tag is separated by a new line. For this example, we will request a few attributes:

![The "Export to CSV" form.]({{ site.baseurl }}/images/screenshot_export.png)

Now, you may click on the blue _Export_ button, and the browser will download the resulting CSV file.

### What else?

The remaining views of the web application are oriented to server configuration and monitoring, which will be covered in the next page.
Moreover, extensions of Dicoogle may include web plugins, which extend the user interface with additional views.
