[![Dependency Status](https://gemnasium.com/tdantas/sidekiq-monitor-tenant-extension.svg)](https://gemnasium.com/tdantas/sidekiq-monitor-tenant-extension)

[![Build Status](https://travis-ci.org/tdantas/sidekiq-monitor-tenant-extension.svg)](https://travis-ci.org/tdantas/sidekiq-monitor-tenant-extension)


# Sidekiq Monitor Extension

We have many services and almost all of them are using sidekiq for background jobs.  
How to monitor every sidekiq instance in one place ?  

This extension will enable you to monitor all sidekiq datasource (redis) in just one place.   

## Installation

This project is a rack application that is ready to be deployed.


````
  git clone git@github.com:tdantas/sidekiq-monitor-tenant-extension.git
  cd sidekiq-monitor-tenant-extension
  bundle install
  
  bundle exec rackup
    or
  passenger start -p 3000 --min-instances 4

````

## Deploy

Ready to deploy using capistrano [config/deploy.rb](https://github.com/tdantas/sidekiq-monitor-tenant-extension/blob/master/config/deploy.rb)    
You must only edit the environment file inside [config/deploy] (https://github.com/tdantas/sidekiq-monitor-tenant-extension/tree/master/config/deploy) folder and create the [app/config/config.yml](https://github.com/tdantas/sidekiq-monitor-tenant-extension/blob/master/app/config/config.yml.sample) with your sidekiqs machines.


````
  cap deploy

````



### Configurations

  All configurations is placed in [app/config/config.yml](https://github.com/tdantas/sidekiq-monitor-tenant-extension/blob/master/app/config/config.yml.sample)


  ***config.sample.yml***
  
````

# local means your local database to persist your authorized users
local:
  url: redis://127.0.0.1:6379/0

# session secret that you must replace
secret: 'super awesome secret key must be placed here, do not forget'

# all sidekiqs that your system have
sidekiqs:
  - 
    name: prolinked-prd
    redis:
      url: redis://127.0.0.1:6379/0
      namespace: prolinkedcare
  - 
    name: mylinkedcare-prd
    redis: 
      url: redis://127.0.0.1:6379/1
      namespace: mylinkedcare
  - 
    name: uid-prd
    redis: 
      url: redis://127.0.0.1:6379/5

````

#### New User

````
  # will ask you for username and password.
  bundle exec rake user:register
````


#### TODO

- (Doing on my rest days) Extract all sidekiq monitor from sidekiq gem.
  We are decorating the original sidekiq web, whatever changes made in the original could brake our extension.

- Finalize my extensions tests and publish.



