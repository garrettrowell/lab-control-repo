class profile::windows (
  String $iamtest = 'cool',
) {
  $domain_firewall_enabled  = 'false'
  $private_firewall_enabled = 'false'
  $public_firewall_enabled  = 'false'

  dsc_firewallprofile { 'Disable_Windows_Firewall-Domain':
    dsc_name    => 'Domain',
    dsc_enabled => capitalize($domain_firewall_enabled),
  }

  dsc_netadapterbinding { 'DisableIPv6':
    dsc_componentid    => 'ms_tcpip6',
    dsc_interfacealias => '*',
    dsc_state          => 'Disabled',
  }
}
