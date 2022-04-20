class profile::example (
  #  $password_test,
  #  $do_a_lookup = Sensitive.new(lookup('test_password')),
  $plain_lookup = lookup('test_password'),
  $another = 'param'
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

  user { 'plain_lookup':
    password => $plain_lookup,
  }

  #  user { 'plain_wrapped':
  #    password => $do_a_lookup,
  #  }
  #notify {"the test: ${password_test}":}
}
