# This is a description for my plan
plan adhoc::env_test(
  TargetSpec $targets,
) {

  run_command('whoami', $targets)
  run_command('env', $targets, '_env_vars' => {'IMATEST' => 'true'})

  $path = system::env('PATH')
  out::message("the path: ${path}")

  get_targets($targets).each |$target| {
    $_vars = vars($target)
    out::message("the vars: ${_vars}")
  }

#  run_command('export SOME_ENV_VAR=imatest', $targets)
#  run_command('env', $targets)
#  $some_env_var = system::env('SOME_ENV_VAR')
#  out::message("some_env_var: ${some_env_var}")
 

}
