---
title: Introduction
permalink: /docs/introduction/
---

This introductory page answers a few pertinent questions about Dicoogle, so as to explain what it is and how it distinguishes from other PACS archives.

#### What is Dicoogle?

Dicoogle is an extensible, platform-independent PACS archive software that replaces the traditional, usually hard-coded centralized database with pluggable indexing and retrieval mechanisms, which are developed separately and installed in deployment time. It was initially designed to accomodate automatic information extraction, indexing and storage of all meta-data detected in medical images, without re-engineering or reconfiguration requirements, thus overcoming the limitations of DICOM-compliant query services.

Currently, the extensible architecture of Dicoogle has enabled its use in research and the healthcare industry, by covering a wide variety of use cases without changes to the core system. This is very relevant nowadays, given the need to improve, monitor and measure the efficiency of medical imaging systems, as well as to extract knowledge from the produced medical images, including healthcare quality indicators. As such, Dicoogle can be used as a base platform for DICOM data mining.

#### What features are included?

Out of the box, the Dicoogle project provides:

- DICOM-compliant implementations of the [Storage](http://dicom.nema.org/medical/dicom/current/output/chtml/part04/chapter_B.html) and [Query/Retrieve](http://dicom.nema.org/medical/dicom/current/output/chtml/part04/chapter_C.html) service classes;
- A set of REST web services for user-facing applications to interface with Dicoogle;
- A web application that enables its configuration and usage;
- A plugin-based backbone for loading extensions in deployment time;
- A common library for developing plugins named *Dicoogle SDK*.

#### Why doesn't Dicoogle include a database?

All storage, indexing and querying capabilities are delegated to plugins. Dicoogle provides abstractions over these resources, so that it can support different file storages and indexing mechanisms.

In this guide, we will cover the use case of a PACS with a local file system storage and a full meta-data indexer based on [Apache Lucene](https://lucene.apache.org). However, with a distinct set of plugins, it is also possible, as an example, to have medical images stored in the cloud (using cloud storage providers such as AWS S3) and indexed by a relational database management system (such as PostgreSQL).

#### What technologies are used by Dicoogle?

Dicoogle is developed in Java SE. The core and SDK sub-projects are built using Maven. Dicoogle is powered by [dcm4che2](https://dcm4che.atlassian.net/wiki/display/d2/dcm4che2+DICOM+Toolkit) for DICOM-related functionalities. Web services are provided over an embedded [Eclipse Jetty](http://www.eclipse.org/jetty/) server. Support for web service development using [Restlet API](https://restlet.com/) is also included. The user interface is a single-page web application powered by [React](https://facebook.github.io/react/) and [Bootstrap](http://getbootstrap.com/) components.

