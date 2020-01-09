# Air Quality UFO Script
#
# Uses data from World Air Quality Index Project - http://waqi.info/
# Using their geoIP based service, may be inaccurate if your IP is not geolocated porperly.
#
# Changes UFO LED colours based on air quality/pollution.
#


# WAQI API token - get one from http://aqicn.org/data-platform/token/#/
# 'demo' will get data for Shanghai only.
$waqitoken = "demo"

# Dynatrace UFO URL
$ufoaddr = "192.168.137.30"



#[CmdletBinding()] 


# Functions

function restApiGet {
    param ([Parameter(Mandatory=$true)][string]$url)

    Write-Verbose "url [$url]"
    try { 
        $result = Invoke-WebRequest $url 
        if ( $result.Headers["X-RateLimit-Remaining"] = 0 ) { Write-Output $result.Headers["X-RateLimit-Reset"]; Sleep 1000 }
        $result | ConvertFrom-Json
    } 
    catch { Write-Host "Exception: \n $_ \n ${result} ${result.Headers}" } 
    
    return $result
}


# force TLS1.2 connectivity as it's now required by Dynatrace
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#start of main code

#use the geoip lookup API 'here' - zero config needed :).
$waqiurl = "https://api.waqi.info/feed/here/?token=" + $waqitoken

#use the city location API, use if the geoip locates you incorrectly.
#$waqiurl = "https://api.waqi.info/feed/?token=" + $waqitoken


# get current WAQI data
$waqidata = restApiGet($waqiurl)
$aqi = $waqidata.data.aqi
$city = $waqidata.data.city.name
$attrs = ""
foreach ( $attr in $waqidata.data.attributions) { $attrs = "$($attrs)  $($attr.name): $($attr.url)`n" }
#$attrs = $waqidata.data.attributions.name + $waqidata.data.attributions.url
Write-Host "City: $city `nAQI: $aqi ("$waqidata.data.dominentpol")`nSources:`n$attrs"


#manually set value to test colours
#$aqi = 40

#determine colour from aqi
$colour="bottom_init=1&bottom=0|2|FF0000|3|2|FF0000|6|2|FF0000|9|2|FF0000|12|2|FF0000&bottom_whirl=500" #default to worst - red-whirling
if ($aqi -le 300){ $colour="bottom_init=1&bottom=0|15|FF0000"} #red
if ($aqi -le 200){ $colour="bottom_init=1&bottom=0|15|CC0033"} #purple
if ($aqi -le 150){ $colour="bottom_init=1&bottom=0|15|FF4400"} #orange
if ($aqi -le 100){ $colour="bottom_init=1&bottom=0|15|FFff00"} #yellow
if ($aqi -le  50){ $colour="bottom_init=1&bottom=0|15|00FF00"} #green
#Write-Host $colour 

#send to UFO
$result = Invoke-WebRequest "http://$ufoaddr/api?$colour"
