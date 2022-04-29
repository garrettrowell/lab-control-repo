# Plan that enforces base profile on all noop nodes
plan adhoc::myplan {

  # Query PuppetDB for nodes in noop
  $pdb_result = puppetdb_query("inventory[certname] { facts.clientnoop = true }")
  # extract the certnames into an array
  $targets = $pdb_result.map |$r| { $r["certname"] }

  # Gather facts about our nodes
  $targets.apply_prep

  # Ensure the Base profile gets applied
  $apply_results = apply($targets) {
    include profile::base
    echo { "environment: ${environment}":}
  }

  out::message("teting: ${apply_results}")

  # Print log messages from the report
  $apply_results.each |$result| {
    out::message("report: ${result.report}")

    #$result.report['logs'].each |$log| {
    #  out::message("${log['level'].upcase}: ${log['message']}")
    #}
  }
}
