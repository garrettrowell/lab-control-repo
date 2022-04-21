class profile::example (
  #  $password_test,
  #  $do_a_lookup = Sensitive.new(lookup('test_password')),
  $plains_lookup = Sensitive(lookup('test_password')),
  #  $another = 'param'
){
  #  file { '/tmp/test.txt':
  #    content => $password_test,
  #  }
  #  file { '/tmp/unwrap.txt':
  #    content => $password_test.unwrap,
  #  }
  #  file { '/tmp/sensitive.txt':
  #    content => $do_a_lookup,
  #  }
  #file { '/tmp/plain.txt':
  #  content => $plain_lookup,
  #}

  #  user { 'sensitive':
  #    password => $password_test,
  #  }
  #
  #  user { 'sensitive_unwrapped':
  #    password => $password_test.unwrap
  #  }


  $password = Sensitive.new('password1')
  $salt     = Sensitive.new('asalt')

  user { 'using_pwhash':
    password => pw_hash($password,'SHA-512',$salt)
    #    password => Sensitive(pw_hash($password,'SHA-512',$salt))
  }

  concat { '/tmp/afile': }

  concat::fragment {
    default:
      target =>  '/tmp/afile',
    ;
    'one':
      content => $plains_lookup.unwrap,
      order   => '01',
    ;
  }

  user { 'another':
    password => Sensitive('plaintextpasswords_notcool_soyeahs12'),
  }

  user { 'plain_lookup_take2':
    password => $plains_lookup,
  }

  #  echo { "plain lookup: ${plains_lookup}": }
  #
  #  file { '/tmp/test.file':
  #    ensure => present,
  #    source => 'puppet:///growell/test.file',
  #  }
  #  user { 'plain_wrapped':
  #    password => $do_a_lookup,
  #  }
  #notify {"the test: ${password_test}":}
}
