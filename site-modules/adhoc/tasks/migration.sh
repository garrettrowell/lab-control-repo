#!/bin/bash

puppet resource service puppet ensure=stopped
mv $(puppet config print ssldir) $(puppet config print ssldir)-bak
mv $(puppet config print statedir) $(puppet config print statedir)-bak
puppet config set --section main server $PT_server
puppet resource service puppet ensure=running
