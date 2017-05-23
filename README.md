# SolidusLograge

This gem provides a sample integration of Solidus with lograge to generate
single-line JSON formatted logs. Furthermore, this repo includes an ElasticSearch
index template that can be used to properly index the log data generated. Finally,
the repo includes a sample filebeat configuration file to let you ship your logs
to ElasticSearch.

# The Demo

## Logging
Since this repo is intended primarly as a demonstration, we'll be using the
sample store created by the test suite.

```
git clone https://github.com/bbuchalter/solidus_lograge.git
cd solidus_lograge
bundle install
bundle exec rake test_app
cd spec/dummy
bin/rake db:migrate db:seed spree_sample:load
bin/rails server
```

In a seperate console, you can see the log data generated by `solidus_lograge`:
```
cd solidus_lograge/spec/dummy/log
tail -f lograge_development.log
```

With the sample store up and running, you can visit http://localhost:3000
and see the log output. You can customize the data included in this log file
by modifying `config/initializers/lograge.rb`.

## ElasticSearch Cluster Setup
If you've got an existing ElasticSearch cluster, you can skip this section.

For those who want a new cluster:
1. Visit https://www.elastic.co/cloud
2. Start free trial
3. Verify Email and Activate Trial
4. Choose a Elastic Cloud password
5. Create a cluster
6. Choose a cluster password
7. Wait for the cluster to be provisioned

The only cluster configuration which is required enabling automatic index
creation since each day of log data will get its own index.

## Index Template Setup
Since each day of log data will get its own index, we need an index template
defined in ElasticSearch so each index has the data processed in the same way.
This repo includes a sample index template:
`solidus_lograge.elasticsearch_index_template.json`

To use this script setup a few environment variables:
```
export ESPROTO=https # switch to 'http' if needed
export ESHOST= # the hostname and port of the ElasticSearch cluster
export ESUSER= # the cluster user name
export ESPASS=
```

You can use the ElasticSearch API to easily "install" this template:
```
curl https://raw.githubusercontent.com/bbuchalter/solidus_lograge/master/solidus_lograge.elasticsearch_index_template.json | curl -H "Content-Type: application/json" -XPUT "$ESPROTO://$ESHOST/_template/solidus_lograge" -u $ESUSER:$ESPASS -d@-
```

This script:
1. GET the sample template via CURL and pipe it to a...
2. PUT request to ElasticSearch to create a new template called `solidus_lograge`

After a successful execution, you should see:
```
{"acknowledged":true}
```

## Filebeat Client Setup
Now that we have log data and an index template, we can start shipping log data
to ElasticSearch. The simplest way to do this is with Filebeat. This repo includes
a sample Filebeat client configuration file:
`solidus_lograge.filebeat.config.yml`

1. Setup environment variables needed by the filebeat client:
```
cd solidus_lograge
export ESLOGPATH=`pwd`/spec/dummy/log/lograge_development.log
export FILEBEAT_CONFIG=`pwd`/solidus_lograge.filebeat.config.yml
```

2. [Download filebeat binary](https://www.elastic.co/downloads/beats/filebeat), not DEB/RPM

3. Run filebeat locally with the sample config:
```
# switch to path for extacted filebeat binary
./filebeat -e -c $FILEBEAT_CONFIG
```

You may see an error that looks like this:
```
ERR Error decoding JSON: invalid character '#' looking for beginning of value
```

This error is safe to ignore. It's caused by the default output of the ActiveLogger
which is added to the top of each new log file:
```
# Logfile created on 2017-05-22 14:46:51 +0100 by logger.rb/56438
```

With the filebeat client running, now execute some requests against localhost:3000.
After about 30 seconds, the filebeat client will start sending the log data
and you'll see a message that looks like this:
```
INFO Harvester started for file: ....
INFO Non-zero metrics in the last 30s: filebeat.harvester.open_files=1....
```

You can verify you've created a new index for this data with this command:
```
curl -XGET "$ESPROTO://$ESHOST/_cat/indices" -u $ESUSER:$ESPASS
```

You should see an index that starts with `solidus_lograge`.

## Use Kibana to Explore Logs
Kibana is a visualization tool that makes it easy to search and filter data in
ElasticSearch. If using ElasticCloud there are a few steps to setup Kibana:

1. Login to Elastic Cloud dashboard: http://cloud.elastic.co
2. Navigate to your cluster
3. Select "Configuration" from main nav
4. Scroll to "Kibana" section and "Enable"
5. Return to overview section and see new Kibana URL
6. Follow link, wait for Kibana installation to complete, refresh
7. Login using "elastic" user created by cluster
8. Setup an index pattern: `solidus_lograge_*`
9. Setup the time-field name to `json.timestamp`.
10. Create the index pattern.
11. Navigate to "Discover".

You should now be able to review your log data.

# TODO
- [ ] Integration with `solidus_auth_devise`
