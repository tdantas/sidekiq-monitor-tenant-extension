# Sidekiq Monitor Extension

We have many services and almost all of them are using sidekiq for background jobs.  
How to monitor every sidekiq instance in one place ?  

This extension will enable you to monitor all sidekiq datasource (redis) in just one place.   

## Installation

This project is a rack application that is ready to be deployed.

  git clone git@github.com:tdantas/sidekiq-monitor-tenant-extension.git
  cd sidekiq-monitor-tenant-extension
  bundle install
  
  bundle exec rackup
    or
  passenger start -p 3000 --min-instances 4


### Configurations

  All configurations is placed in app/config/config.yml
  
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

- Extract all sidekiq monitor from sidekiq gem.
  We are extending the monitor from original sidekiq gem, whatever changes made in the original could brake our extension.

- Finalize my extensions tests and publish.



