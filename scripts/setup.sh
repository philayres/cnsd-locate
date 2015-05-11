#!/bin/bash
if [ -z "$1" ]; then
  echo Your mySQL username is required as the first argument in the call
  echo usage: script/setup.sh root 
  exit
fi
bundle install
mkdir ./log
echo Enter your mysql password for user $1

SKEY=`./scripts/add_client.sh 'jx32977huTH&^TH(h9j7204juso12h', true`
 

for f in ./db/*.sql; do echo "Processing $f SQL file.."; mysql -u $1 -p < $f; mv $f $f.bak ; done

ruby -r "./lib/helpers/config_manager.rb" -e "ConfigManager.create_database_config('utf8','mysql2',
         'cnsd_locate', # db name
         'u_cnsd_locate', #db username
         'IUOYboyn02y4np2hog&^Hg',  #db password
         {
         directories: {
           log: './log' # log file location (relative to base directory, or full path)
         }, 
         credentials: {
           super_admin_id: 'jx32977huTH&^TH(h9j7204juso12h',
           super_admin_secret: '$SKEY'
         },
         server: {
           port: 15501,  # port to run the server on
           request_timeout: {  # max time between timestamp and current time (in ms)
              __default: 30000,   # default for all requests
              controller1: {
                __default:10000,   # default for requests to controller1
                action3_get: 60000  # override controller default for action3 get request
              },
              admin: {
                status_get: 5000 # override server default for status get request
              }
           }           
         }  } )"
