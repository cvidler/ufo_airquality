# ufo_airquality
Uses public APIs to report local air quiality index on your Dynatrace UFO.

Uses data from World Air Quality Index Project - http://waqi.info/

Configuration:
  * Create an API token for WAQI (http://aqicn.org/data-platform/token/), and configure it in the ``$waqitoken`` variable.
  * Add the IP/fqdn for your Dyntrace UFO (https://github.com/Dynatrace/ufo) in the ``$ufoaddr`` variable.
  * Schedule the script to run periodically, I recommend every 15 minutes.

Only the bottom ring of the UFO is used, so another data source can make use of the top ring to show other data/status infomation.

