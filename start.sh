#!/bin/bash
su - postgres -c "/usr/bin/pg_ctl start -D /var/lib/postgresql/data"
cd /opt/railsgoat
/bin/bash -l -c  "RAILS_ENV=openshift rails server -b 0.0.0.0"
