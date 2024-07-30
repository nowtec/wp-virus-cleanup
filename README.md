<!-- PROJECT LOGO -->
<br />
<div align="center" id="readme-top">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://nowtec.solutions/wp-content/uploads/nowtec-logo.svg" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">WP Time Capsule Fix</h3>

  <p align="center">
    A script for fixing the consequences of a vulnerability in WP Time Capsule
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Script</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Scirpt

After experiencing the consequences of the vulnerability in WordPress plugin [“WordPress Time Capsule”](https://www.infosecurity-magazine.com/news/wp-time-capsule-plugin-flaw/#:~:text=Security%20researchers%20have%20found%20a,cloud%2Dnative%20file%20versioning%20systems.) affeting version 1.22.20 and belowe, it became obvious that it was necessary to remove all the malicious code at once to prevent its further expansion

Here's a short description of what the script does:
1. Deletes the files of the “WP Time Capsule” plugin (the script does not delete the plugin backups and settings)
2. Recursively removes malicious files in the "wp-content" directory
3. Recursively removes inserted malicious code in files in the "wp-content" directory
4. Moves the important files and the wp-content directory to a temporary directory (e.g. ".htaccess", "wp-config.php" and "wp-content")
5. Install the latest version of WordPress via WP-CLI and move files from the temporary directory to the main directory

It is also important to note that if the malicious code you encountered is different from our case, then you need to change the keywords and regular expressions in the script to remove the malicious code completely

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

Here are quick instructions on how to install the script

### Prerequisites

* PHP 5.4 or later
* WordPress 3.7 or later

### Installation

1. Download the script and wp-cli.phar file (WP-CLI)
2. Make the files executable 
   ```sh
   $ chmod +x ./wordpress-timecapsule-fix.sh ./wp-cli.phar
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

When calling the script, it is necessary to specify the directory where the sites are located
   ```sh
   $ ./wordpress-timecapsule-fix.sh /www/sites
   ```
If the sites are located in the same directory but in a subfolder like “public”, then you need to change the script a bit

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact
<p align="left">
    If you get affected by a vulnerability of a plugin, or your Wordpress website , we can prov
 </p>
<p align="left"><a href="https://nowtec.solutions/products/nowsite/">File a support request</a></p>

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- Disclaimer -->
## Disclaimer
<p align="left">
   This script comes absoulutely with no warranty
 </p>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
