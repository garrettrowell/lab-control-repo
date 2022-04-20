class profile::example (
  $password_test# = lookup('test_password')
){
  notify {"the test: ${password_test}":}
}
