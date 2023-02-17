## site.pp ##

# This file (./manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
# https://puppet.com/docs/puppet/latest/dirs_manifest.html
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition if you want to use it.

## Active Configurations ##

# Disable filebucket by default for all File resources:
# https://github.com/puppetlabs/docs-archive/blob/master/pe/2015.3/release_notes.markdown#filebucket-resource-no-longer-created-by-default
File { backup => false }

## Node Definitions ##

# The default node definition matches any node lacking a more specific node
# definition. If there are no other node definitions in this file, classes
# and resources declared in the default node definition will be included in
# every node's catalog.
#
# Note that node definitions in this file are merged with node data from the
# Puppet Enterprise console and External Node Classifiers (ENC's).
#
# For more on node definitions, see: https://puppet.com/docs/puppet/latest/lang_node_definitions.html
node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
  Integer[0,1].each |Integer $index, Integer $num| {
    notify { "Index: ${index} - Num: ${num}":
      withpath => true,
    }
  }

  unless $facts['os']['family'] == 'windows' {
    file { '/tmp/test.txt':
      ensure => present,
      source => 'puppet:///modules/profile/test.txt',
    }
  }

  include profile::base

  # should auto grab version from PE Primary
  #class { 'puppet_agent':
  #  package_version => '7.18.0',
  #}

  #  $attr_message = lookup('attr_message')
  #  echo { $attr_message: }
  #  warning('youve been warned')

  if $facts['pe_server_version'] == undef {
    echo { 'hello from an agent': }
  }
  if $trusted['extensions']['pp_role'] != undef {
    #    $to_include = regsubst($trusted['extensions']['pp_role'], /(.+)(_)(.+)/, '\1::\3')
    #    include "role::${to_include}"
    #
    $split_role = split($trusted['extensions']['pp_role'], '::')
    $to_include = size($split_role) ? {
      1       => $split_role['0'],
      default => "${split_role['0']}_${split_role['1']}",
    }
    echo { "role::${to_include}": }
  }

  if $trusted['certname'] == 'garrett.rowell-pe-primary' {
    ini_setting { 'policy-based autosigning':
      setting => 'autosign',
      path    => $facts['puppet_config'],
      section => 'server',
      value   => '/opt/puppetlabs/puppet/bin/autosign-validator',
      notify  => Service['pe-puppetserver'],
    }

    #    class { 'puppet_agent':
    #      config => [
    #        {section => server, setting => autosign, value => '/opt/puppetlabs/puppet/bin/autosign-validator'},
    #      ],
    #      notify => Service['pe-puppetserver'],
    #    }

    class { ::autosign:
      ensure     => 'latest',
      config     => {
        'general' => {
          'loglevel' => 'DEBUG',
        },
        'password_list' => {
          'password' => 'hunter2'
        }
      },
      notify      => Service['pe-puppetserver'],
    }
  } else {

    $should_be_a_lookup = 'hunter2'
    $csr_attr = "${facts['puppet_confdir']}/csr_attributes.yaml"

    file { $csr_attr:
      ensure =>  present,
    }

    file_line {
      default:
        ensure => present,
        path   => $csr_attr,
        require => File[$csr_attr],
      ;
      'custom_attributes':
        line => 'custom_attributes:',
        before => File_line['challengePassword'],
      ;
      'challengePassword':
        line => "  challengePassword: \"${should_be_a_lookup}\"",
        after => '^custom_attributes',
      ;
    }

  }

}
