# Carl

Carl constructs CQL statements for Cassandra.

Quick Start
-----------

Establish a connection:

    require 'carl'
    Carl::Base.establish_connection :keyspace => 'carl', :hosts => ['localhost:9160']

Build a query

    carl = Carl::Base.new
    carl.select('rowname').from('columnfamily').where(:key => 42).query
    # => ["SELECT ? FROM ? WHERE key = ?", "rowname", "columnfamily", 42]

Execute a query

    carl.select('rowname').from('columnfamily').where(:key => 42).execute
    # => #<CassandraCQL::Result:...

    carl.select('rowname').from('columnfamily').where(:key => 42).to_hash
    # => {...}

Supported statements
--------------------

* *INSERT*: ~90% complete
* *other*: ~0% complete

Contributing to Carl
--------------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2011 Thomas Hollstegge. See LICENSE.txt for
further details.
