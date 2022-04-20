class profile::example (
  $password_test# = lookup('test_password')
){
  file { '/tmp/test.txt':
    content => $password_test,
  }
  #notify {"the test: ${password_test}":}
}
