#!/bin/bash

ssldir=$(puppet config print ssldir)
statedir=$(puppet config print statedir)
puppet resource service puppet ensure=stopped
mv $ssldir ${ssldir}-bak
mv $statedir ${statedir}-bak
echo $PT_server
puppet config set --section main server $PT_server
puppet resource service puppet ensure=running
