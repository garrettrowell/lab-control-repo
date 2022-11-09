[CmdletBinding()]
param ($server)

$puppet_bin_dir = Join-Path ([Environment]::GetFolderPath('ProgramFiles')) 'Puppet Labs\Puppet\bin'

# Useful locations
$ssldir = & $puppet_bin_dir\puppet config print ssldir
$statedir = & $puppet_bin_dir\puppet config print statedir

# stop the service
& $puppet_bin_dir\puppet resource service puppet ensure=stopped

## backup ssldir and statedir
Write-Output "moving $ssldir to $ssldir`-bak"
Move-Item -Path $ssldir -Destination "$ssldir`-bak"
Write-Output "moving $statedir to $statedir`-bak"
Move-Item -Path $statedir -Destination "$statedir`-bak"

## point to the new server
& $puppet_bin_dir\puppet config set --section main server $server

## start the service again
& $puppet_bin_dir\puppet resource service puppet ensure=running
