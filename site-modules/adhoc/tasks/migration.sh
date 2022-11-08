#!/bin/bash

# Useful locations
ssldir=$(puppet config print ssldir)
statedir=$(puppet config print statedir)

# stop the service
puppet resource service puppet ensure=stopped

# backup ssldir and statedir
mv $ssldir ${ssldir}-bak
mv $statedir ${statedir}-bak

# point to the new server
puppet config set --section main server $PT_server

# start the service again
puppet resource service puppet ensure=running
