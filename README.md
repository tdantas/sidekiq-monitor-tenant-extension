# Sidekiq Monitor Extension

We have many services and almost all of them are using sidekiq for background jobs.  
How to monitor every sidekiq instance in one place ?  


This extension will enable you to configure all sidekiq datasource (redis) and with just one sidekiq web monitor.  

##### app/config  

config.yml will contains all sidekiq datasource instances   

````
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

````


#### Login

To register a new user, localhost must contains a redis instance to persist authorized users.
How to create new users ??


````
  bundle exec rake user:register
````


