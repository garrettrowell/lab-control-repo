# This is a description for my plan
plan adhoc::env_test(
  TargetSpec $targets,
) {

  run_command('whoami', $targets)
  run_command('set', $targets)

  $path = system::env('PATH')
  out::message("the path: ${path}")
  $hostname = system::env('HOSTNAME')
  out::message("the hostname: ${hostname}")
  $hosttype = system::env('HOSTTYPE')
  out::message("the hosttype: ${hosttype}")

#  run_command('export SOME_ENV_VAR=imatest', $targets)
#  run_command('env', $targets)
#  $some_env_var = system::env('SOME_ENV_VAR')
#  out::message("some_env_var: ${some_env_var}")
 

}
