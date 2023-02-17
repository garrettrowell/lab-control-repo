# This is a description for my plan
plan adhoc::env_test(
  TargetSpec $targets,
) {

  $user = run_command('whoami', $targets)
  out::message("user: ${user}")

  $env_return = run_command('env', $targets, '_env_vars' => {'IMATEST' => 'true'})
  out::message("env: ${env_return}")

  $path = system::env('PATH')
  out::message("the path: ${path}")

  $imatest = system::env('IMATEST')
  out::message("the imatest before: ${imatest}")

  run_command('export IMATEST=true', $targets)
  $imatest2 = system::env('IMATEST')
  out::message("the imatest after: ${imatest2}")


#  run_command('export SOME_ENV_VAR=imatest', $targets)
#  run_command('env', $targets)
#  $some_env_var = system::env('SOME_ENV_VAR')
#  out::message("some_env_var: ${some_env_var}")
 

}
