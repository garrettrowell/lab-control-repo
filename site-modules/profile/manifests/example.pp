class profile::example (
  $password_test# = lookup('test_password')
){
  file { '/tmp/test.txt':
    content => $password_test,
  }
  file { '/tmp/unwrap.txt':
    content => $password_test.unwrap,
  }

  #notify {"the test: ${password_test}":}
}
