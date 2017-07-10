---
title: Building Dicoogle
permalink: /docs/building/
---

Dicoogle is an open-source project. The official sources are hosted on GitHub [here](https://github.com/bioinformatics-ua/dicoogle.git). This page provides instructions on building Dicoogle from the official sources.

Before building, please make sure that your system contains the following tools:

 - Java JDK, either Oracle or OpenJDK (at least version 7; JDK 8 is recommended)
 - [Maven](https://maven.apache.org/) 3
 - [Node.js](https://nodejs.org/en/download/) (at least version 4; LTS or Stable versions are recommended) and npm (at least version 2)

 1. Retrieve the full source code from this repository: `git clone https://github.com/bioinformatics-ua/dicoogle.git`
 2. Navigate to the project's base directory, and build the parent Maven project by calling `mvn install`.
    - Note: if you want, you can skip the npm part: `mvn install -Dskip.npm`
 3. The resulting jar file can be found in "./dicoogle/target".

 
<div class="note info">
  <h5>Dicoogle is licensed under the GNU General Public License v3.0</h5>
  <p>According to this license, you are free to use, modify, and distribute Dicoogle, including modified versions. Nevertheless, certain conditions must be met to preserve this freedom:
    <ul>
      <li>Permissions of this strong copyleft license are conditioned on making available complete source code of licensed works and modifications, which include larger works using a licensed work, under the same license.</li>
      <li>Copyright and license notices must be preserved.</li>
      <li>Contributors provide an express grant of patent rights.</li>
    </ul>
  </p>
</div>
