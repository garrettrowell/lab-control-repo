class profile::windows (
  String $iamtest = 'cool',
) {
  # Manage Firewalls
  $domain_firewall_enabled  = 'false'
  $private_firewall_enabled = 'false'
  $public_firewall_enabled  = 'false'

  dsc_firewallprofile { 'Disable_Windows_Firewall-Domain':
    dsc_name        => 'Domain',
    dsc_enabled     => capitalize($domain_firewall_enabled),
    validation_mode => resource,
  }
  dsc_firewallprofile { 'Disable_Windows_Firewall-Private':
    dsc_name        => 'Private',
    dsc_enabled     => capitalize($private_firewall_enabled),
    validation_mode => resource,
  }
  dsc_firewallprofile { 'Disable_Windows_Firewall-Public':
    dsc_name        => 'Public',
    dsc_enabled     => capitalize($public_firewall_enabled),
    validation_mode => resource,
  }

  # Disable IPv6
  dsc_netadapterbinding { 'DisableIPv6':
    dsc_componentid    => 'ms_tcpip6',
    dsc_interfacealias => '*',
    dsc_state          => 'Disabled',
    validation_mode    => resource,
  }

  # Set Timezone
  dsc_timezone { 'Set Timezone':
    dsc_timezone         => 'Central Standard Time',
    dsc_issingleinstance => 'Yes',
  }

  # Disable UAC
  # Warning: Provider returned data that does not match the Type Schema for `dsc_useraccountcontrol[foo]`
  # Value type mismatch:
  #    * dsc_consentpromptbehavioradmin: 5 (expects an undef value or a match for Enum['0', '1', '2', '3', '4', '5'], got Integer)
  #    * dsc_consentpromptbehavioruser: 3 (expects an undef value or a match for Enum['0', '1', '3'], got Integer)
  #    * dsc_enableinstallerdetection: 1 (expects an undef value or a match for Enum['0', '1'], got Integer)
  #    * dsc_enablelua: 1 (expects an undef value or a match for Enum['0', '1'], got Integer)
  #    * dsc_enablevirtualization: 1 (expects an undef value or a match for Enum['0', '1'], got Integer)
  #    * dsc_promptonsecuredesktop: 1 (expects an undef value or a match for Enum['0', '1'], got Integer)
  #    * dsc_validateadmincodesignatures: 0 (expects an undef value or a match for Enum['0', '1'], got Integer)
  #
  #dsc_useraccountcontrol { 'Disable_UAC':
  #  dsc_enablelua        => '0',
  #  dsc_issingleinstance => 'Yes',
  #}
  dsc_securityoption { 'Disable_UAC':
    dsc_ensure => 'Present',
    dsc_name   => 'EnableLUA',
    dsc_value  => ['Disabled'],
  }

  # Enable RDP
  dsc_xremotedesktopadmin { 'Enable_RDP':
    dsc_ensure => 'Present',
  }

  dsc_user { 'serviceaccount':
    name         => 'serviceaccount',
    dsc_disabled => false,
    dsc_username => 'serviceaccount',
    dsc_fullname => 'serviceaccount',
    dsc_ensure   => 'Present',
    dsc_password => {
      user     => 'serviceaccount',
      password => Sensitive('pfq3bpMR6JpdzWeu'),
    },
  }

  # Service Accounts
  service { 'pxp-agent':
    logonaccount  => 'serviceaccount',
    logonpassword => Sensitive('pfq3bpMR6JpdzWeu'),
  }
  #  dsc_serviceset { 'pxp-agent':
  #    dsc_name           => ['pxp-agent'],
  #    name               => ['pxp-agent'],
  #    dsc_builtinaccount => undef,
  #    dsc_credential     => {
  #      user     => 'serviceaccount',
  #      password => Sensitive('pfq3bpMR6JpdzWeu'),
  #    },
  #  }
}
