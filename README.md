# Setup instructions

Adjust the ruby version in the Gemfile to match your local ruby version.

Then run the following commands:

```
bin/setup
bin/rails db:seed
bin/rails spree_sample:load
```

And finally start the server:

```
bin/rails s
open http://localhost:3000
```
