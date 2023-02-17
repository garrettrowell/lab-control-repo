# This is a description for my plan
plan adhoc::env_test(
  TargetSpec $targets,
) {

  run_command('whoami', $targets)
  run_command('env', $targets)
  $path = system::env('PATH')
  out::message("the path: ${path}")

}
