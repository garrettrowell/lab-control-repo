[CmdletBinding()]
param ($server)

$puppet_bin_dir = Join-Path ([Environment]::GetFolderPath('ProgramFiles')) 'Puppet Labs\Puppet\bin'

$ssldir = & $puppet_bin_dir\puppet config print ssldir
# Useful locations
#$version = (puppet --version)
#$ssldir = @{puppet config print ssldir}
#$statedir = (puppet config print statedir)
#
#$testing = get-command puppet
#Write-Output (puppet --version)
#Write-Output "testing: $testing"
#Write-Output "server: $server"
Write-Output "ssldir: $ssldir"
#Write-Output "statedir: $statedir"
#Write-Output "version: $version"

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
puppet config set --section main server $server
#
## start the service again
#puppet resource service puppet ensure=running
