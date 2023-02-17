# This is a description for my plan
plan adhoc::env_test(
  TargetSpec $targets,
) {

  run_command('whoami', $targets)
  run_command('env', $targets, '_env_vars' => {'IMATEST' => 'true'})

  $path = system::env('PATH')
  out::message("the path: ${path}")

  get_targets($targets).each |$target| {
    out::message("the config: ${target.config}")
    out::message("the facts: ${target.facts}")
    out::message("the features: ${target.features}")
    out::message("the host: ${target.host}")
    out::message("the name: ${target.name}")
    out::message("the password: ${target.password}")
    out::message("the plugin_hooks: ${target.plugin_hooks}")
    out::message("the port: ${target.port}")
    out::message("the protocol: ${target.protocol}")
    out::message("the resources: ${target.resources}")
    out::message("the safe_name: ${target.safe_name}")
    out::message("the target_alias: ${target.target_alias}")
    out::message("the transport: ${target.transport}")
    out::message("the transport_config: ${target.transport_config}")
    out::message("the uri: ${target.uri}")
    out::message("the user: ${target.user}")
    out::message("the vars: ${target.vars}")

  }

#  run_command('export SOME_ENV_VAR=imatest', $targets)
#  run_command('env', $targets)
#  $some_env_var = system::env('SOME_ENV_VAR')
#  out::message("some_env_var: ${some_env_var}")
 

}
