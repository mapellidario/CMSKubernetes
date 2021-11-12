#!/bin/bash

# start process exporter
if [ -f /data/srv/state/crabrest/crabrest.pid ]; then
    nohup process_monitor.sh /data/srv/state/crabrest/crabrest.pid crabrest ":18270" 15 2>&1 1>& crabrest_monitor.log < /dev/null &
elif [ -f /data/srv/state/crabrest/pid ]; then
    nohup process_monitor.sh /data/srv/state/crabrest/pid crabrest ":18270" 15 2>&1 1>& crabrest_monitor.log < /dev/null &
fi

# run filebeat
if [ -f /etc/secrets/filebeat.yaml ] && [ -f /usr/bin/filebeat ]; then
    ldir=/tmp/filebeat
    mkdir -p $ldir/data
    nohup /usr/bin/filebeat \
        -c /etc/secrets/filebeat.yaml \
        --path.data $ldir/data --path.logs $ldir -e 2>&1 1>& $ldir/log < /dev/null &
fi
