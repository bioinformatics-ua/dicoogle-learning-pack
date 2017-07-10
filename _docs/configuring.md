---
title: Configuring
permalink: /docs/configuring/
---

Dicoogle often needs to be configured manually to fulfill certain needs. There are also a few features that may not work as intended without proper configuration. This page will skim through the configurable parts of Dicoogle.

### Configuring the Indexers

Start by navigating to the Dicoogle web app and entering the **Management** menu. The first section of this menu is for indexer settings. It is also possible to enable the Dicoogle Directory Watcher, which creates a daemon that listens for new files in a directory and indexes them automatically. This is often useful when dragging files to the folder manually, but not when using Dicoogle as a DICOM server.

![]({{ site.baseurl }}/images/screenshot_config_index.png)

After selecting the configurations, the "Apply Settings" button must be pressed. 

### Transfer Options

As Dicoogle is a working DICOM server, it can also be configured to implement certain Service-Object Pair (SOP) classes. DICOM transfer options can be defined here by checking or unchecking transfer syntaxes from the list. The _"Select All"_ button will enable all transfer syntaxes for all SOP classes. Pressing it again will perform the opposite.

![]({{ site.baseurl }}/images/screenshot_config_transfer.png)

### Configuring Services

In the Management menu, Services and Plugins tab, it is possible to start and/or stop currently running services in real time. Moreover, some configurations like the DICOM service ports may be redefined.

![]({{ site.baseurl }}/images/screenshot_config_service.png)

### Configuration file

All configurations previously mentioned are stored in a single XML file. Once Dicoogle is run at least once, you will find a file named _"config.xml"_. Currently, some configurations can only be changed by editing this file. As an example, let us modify this instance's application entity title (AE Title). Look for the XML element `AETitle`:

```xml
<AETitle>DICOOGLE-STORAGE</AETitle>
```

And modify it to another identifier:

```xml
<AETitle>PERSONAL-STORAGE</AETitle>
```

The server needs to be restarted after this modification. When that is done, you will see that the server's AE Title has changed.

<div class="note warning">
  <h5>Take extra care when modifying config.xml!</h5>
  <p>An incorrect configuration may prevent Dicoogle from running entirely. Consider backing up this file before modifying it. In order to revert all changes to the defaults, simply delete the file and let Dicoogle generate it again.</p>
</div>

### Configuring Plugins

Plugins can have settings of their own as well. Unlike the settings presented so far, these are kept in their own xml file, in a _"settings"_ folder in _"Plugins"_, alongside the plugin jar files. This folder is automatically created, and plugins should automatically generate default configurations there. When configuring a plugin, one should attend to that plugin's documentation.

------------------

This concludes the first chapter, where we have covered how to install Dicoogle in a machine, configure it, and use it for basic purposes. The next chapter is intended for developers wishing to further leverage the capabilities of Dicoogle using plugins.
