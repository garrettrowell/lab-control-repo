class profile::example (
  #  $password_test,
  #  $do_a_lookup = Sensitive.new(lookup('test_password')),
  $plain_lookup = lookup('test_password')
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
  file { '/tmp/plain.txt':
    content => $plain_lookup,
  }

  #notify {"the test: ${password_test}":}
}
