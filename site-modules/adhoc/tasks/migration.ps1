param ($server)

# Useful locations
$ssldir = (puppet config print ssldir) | Out-String
$statedir = (puppet config print statedir)

Write-Output "server: $server"
Write-Output "ssldir: $ssldir"
Write-Output "statedir: $statedir"

# stop the service
#puppet resource service puppet ensure=stopped
#
#Write-Host $ssldir
#
## backup ssldir and statedir
#Move-Item -Path $ssldir -Destination ${ssldir}-bak
#Move-Item -Path $statedir -Destination ${statedir}-bak
#
## point to the new server
#puppet config set --section main server $PT_server
#
## start the service again
#puppet resource service puppet ensure=running
