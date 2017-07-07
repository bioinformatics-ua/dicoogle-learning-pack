---
title: Setup
permalink: /docs/setup/
---

In this page, we will have an instance of Dicoogle running on your machine for the first time.

### Install Requirements

Before we proceed, make sure that you have an up-to-date version of the Java Virtual Machine. Java SE 7 is supported, but Java 8 is recommended at this time.

### Obtain Dicoogle and Plugins

The website has a [Downloads](http://www.dicoogle.com/download) section, where you can download Dicoogle and some plugins for free. As an alternative, you can build it from the sources. Once that is done, be sure that you have these three files:

- The main platform program (_"dicoogle.jar"_). 

- The Lucene-based index/query plugin (_"lucene.jar"_). It is based on [Lucene](https://lucene.apache.org) to support indexing and querying of DICOM meta-data. With this plugin set, it is possible to index nearly meta-data and perform free text, keyword-based, and range-based queries.

- File storage plugin (_"filestorage.jar"_). It is used for storing and retrieving DICOM files in the local file system. This plugin is necessary in order to use Dicoogle as a complete DICOM storage provider. The core platform provides a fallback implementation which supports reading (but not storing) files from the local file system.

### Set up the Dicoogle Platform

Copy the jar file _"dicoogle.jar"_ to a new folder, where we will deploy Dicoogle. For this example, we will name it _"DicoogleDir"_.

### Installing Plugins

Create a new folder _"Plugins"_ in _"DicoogleDir"_.
This directory will hold the plugins used by our instance of Dicoogle.

A typical deployment of Dicoogle relies on at least two plugins: one for file storage and another one for indexing and querying. 
Next, copy or move the two plugins, _"lucene.jar"_ and _"filestorage.jar"_, into the _"Plugins"_ folder.

<div class="note info">
  <h5>The Plugins folder is case-sensitive!</h5>
  <p>Some operating systems such as Windows will actually ignore casing in file names. However, Unix-based systems (Linux, OSX, ...) are sensitive to casing, which means that <em>“Plugins”</em> and <em>“plugins”</em> do not refer to the same file path. You are advised to always name this folder <em>”Plugins”</em>, with a capital P. </p>
</div>

### Running Dicoogle

We are not ready to run Dicoogle. The most recommended way is to execute the jar file on a terminal. Open a command line and execute the following command:

```sh
java -jar dicoogle.jar -s
```

The `-s` flag is optional. Without it, Dicoogle will automatically open your default Internet browser on the web application.

Your Dicoogle server should now be ready for basic usage, which we will address in the next page. In order to stop Dicoogle entirely, simply terminate the program by pressing `Ctrl + C`, or by closing the terminal.
