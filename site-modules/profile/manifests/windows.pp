class profile::windows (
){
  $domain_firewall_enabled  = 'false'
  $private_firewall_enabled = 'false'
  $public_firewall_enabled  = 'false'

  $d_f_e = $domain_firewall_enabled ? {
    'true'  => 'Present',
    'false' => 'Absent',
  }

  #  dsc_xdscfirewall { 'Domain':
  #    dsc_ensure => $d_f_e,
  #    dsc_zone   => 'Domain',
  #  }
  #  dsc_netadapterbinding 'DisableIPv6' dsc_componentid='ms_tcpip6' dsc_interfacealias='Ethernet'
  dsc_netadapterbinding { 'DisableIPv6':
    dsc_componentid    => 'ms_tcpip6',
    dsc_interfacealias => '*',
    dsc_state          => 'Disabled',
  }
}
