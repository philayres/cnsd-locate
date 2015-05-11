cnsd-locate: Consected Locate
=============================

Consected Locate is a simple API platform providing IP geolocation lookup services to websites and other services needing access to 
broad geographical positioning of a user based on their current IP address.

This project is a work in progress, but is currently functional to provide:

* lookup city / country and (US-based 5-digit ZIP) based on provided IP address
* add new Client API IDs / Secrets, to provide secure access to the service
* leverage the one-time use of API calls provided by the em-secure-api service at: https://github.com/philayres/em-secure-api

Installation
----------------

- Download the code to a directory. 
- Rename the files in the db directory to remove the .bak extension (this will be re-added after setup to prevent re-running)
- Follow the notes for download and conversion of geolocation data below. 
- Run `scripts/setup.sh <db-root-username>`


Run the server (defaults to port 15501) with

    ruby lib/em_server.rb

Or follow the notes for setting up as an upstart service in https://github.com/philayres/em-secure-api


Geolocation data
----------------

This product includes GeoLite2 data created by MaxMind, available from http://www.maxmind.com

The City and Country data supporting the IP geolocation is found at: http://dev.maxmind.com/geoip/geoip2/geolite2/ and according to 
this page the data is released under Creative Commons Attribution-ShareAlike 3.0 Unported License. Due to the size of the data,
and the need to refresh it periodically, (plus to avoid any distribution issues), individual users of this project are responsible for
downloading the data.


    cd data

    wget "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip"
    unzip GeoLite2-City-CSV.zip

    DATE=20150505

    mv GeoLite2-City-CSV_$DATE/GeoLite2-City-Locations-en.csv .
    cd ..

    INFILE=`pwd`/data/GeoLite2-City-CSV_$DATE/GeoLite2-City-Blocks-IPv4.csv
    OUTFILE=`pwd`/data/cnsd-ip-locations.csv
    ./scripts/geoip2-csv-converter-v0.0.1/geoip2-csv-converter -block-file=$INFILE -output-file=$OUTFILE -include-integer-range -include-cidr

    ruby scripts/load_db.rb ./data/cnsd-ip-locations.csv ./data/cnsd-ip-load.sql
    mysql -u root -p < ./data/cnsd-ip-load.sql
    ruby scripts/load_loc_db.rb ./data/GeoLite2-City-Locations-en.csv ./data/cnsd-ip-load-loc.sql
    mysql -u root -p < ./data/cnsd-ip-load-loc.sql


License
-------

Licensed under the Apache License, Version 2.0 (the "License"). See LICENSE for details.