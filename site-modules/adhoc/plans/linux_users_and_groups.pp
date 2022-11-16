# @see LICENSE.pdf for license
# This plan enfoces user and group security policies.
# @private false
# @param [TargetSpec] targets
#   Users to enforce polices on.
# @param [Boolean] enforce_shadowed_passwords
#   Enforce polcies on shadow password file.
# @param [Boolean] enforce_users_have_password
#   Ensure users have passwords set. Satisfies STIG V-251702.
# @param [Sensitive[String]] default_password
#   Default password to set if user has no password and enforce_users_have_password is true.
# @param [Enum['remove', 'new_uid', 'report']] duplicate_root_uid_strategy
#   What to do when duplicate root uid found.
# @param [Boolean] create_user_homedir
#   Create missing user home directories if true.
# @param [Boolean] enforce_user_homedir_mode
#   Set directory permissions if set to true.
# @param [Boolean] enforce_user_homedir_ownership
#   Set directory ownership if set to true.
# @param [Boolean] enforce_user_dotfile_mode
#   Enforce directory ditfile mode if set to true.
# @param [Pattern[/^07[0-7][0-7]$/]] user_homedir_mode
#   User home directory mode.
# @param [Pattern[/^07[0-7][0-7]$/]] user_dotfile_mode
#   User dotfile mode.
# @param [Boolean] purge_user_forward_files
#   Purge user forward files if set to true.
# @param [Boolean] purge_user_netrc_files
#   Purge user netrc files if set to true.
# @param [Boolean] enforce_user_netrc_mode
#   Enforce user netrc files mode if set to true.
# @param [Pattern[/^07[0-7][0-7]$/]] user_netrc_mode
#   User netrc mode.
# @param [Boolean] purge_user_rhosts_files
#   Purge user rhosts file if set to true.
plan adhoc::linux_users_and_groups (
  TargetSpec $targets,
  Boolean $enforce_shadowed_passwords = true,
  Boolean $enforce_users_have_password = true,
  Sensitive[String] $default_password = Sensitive('Ch@ng3M3!'),
  Enum['remove', 'new_uid', 'report'] $duplicate_root_uid_strategy = 'report',
  Boolean $create_user_homedir = true,
  Boolean $enforce_user_homedir_mode = true,
  Pattern[/^07[0-7][0-7]$/] $user_homedir_mode = '0750',
  Boolean $enforce_user_homedir_ownership = true,
  Boolean $enforce_user_dotfile_mode = true,
  Pattern[/^07[0-7][0-7]$/] $user_dotfile_mode = '0700',
  Boolean $purge_user_forward_files = true,
  Boolean $purge_user_netrc_files = true,
  Boolean $enforce_user_netrc_mode = true,
  Pattern[/^07[0-7][0-7]$/] $user_netrc_mode = '0700',
  Boolean $purge_user_rhosts_files = true,
  Boolean $enforce_user_init_files_umask = true
  Pattern[/^7[0-7][0-7]$/] $user_init_files_umask = '077',
) {
  if $enforce_shadowed_passwords {
    $esp_result = run_command('sed -e \'s/^\\([a-zA-Z0-9_]*\\):[^:]*:/\\1:x:/\' -i /etc/passwd', $targets)
  } else {
    $esp_result = 'Not enforced'
  }
  if $enforce_users_have_password {
    $eup_result = run_task('cem_linux::enforce_user_passwords', $targets, default_password => $default_password.unwrap)
  } else {
    $eup_result = 'Not enforced'
  }
  $root_uid_result = run_task('cem_linux::root_uid', $targets, duplicate_uid_strategy => $duplicate_root_uid_strategy)
  $root_path_result = run_task('cem_linux::root_path_integrity', $targets)
  $user_homedir_audit = run_task(
    'cem_linux::audit_user_homedir',
    $targets,
    enforce_user_homedir_mode      => $enforce_user_homedir_mode,
    user_homedir_mode              => $user_homedir_mode,
    enforce_user_homedir_ownership => $enforce_user_homedir_ownership,
    create_user_homedir            => $create_user_homedir,
    enforce_user_dotfile_mode      => $enforce_user_dotfile_mode,
    user_dotfile_mode              => $user_dotfile_mode,
    purge_user_forward_files       => $purge_user_forward_files,
    purge_user_netrc_files         => $purge_user_netrc_files,
    enforce_user_netrc_mode        => $enforce_user_netrc_mode,
    user_netrc_mode                => $user_netrc_mode,
    purge_user_rhosts_files        => $purge_user_rhosts_files,
    enforce_user_init_files_umask  => $enforce_user_init_files_umask,
    user_init_files_umask          => $user_init_files_umask,
  )
  $nonexistent_passwd_groups = run_task('cem_linux::audit_etcpasswd_groups', $targets)
  $duplicate_uids = run_task('cem_linux::audit_duplicate_uid', $targets)
  $duplicate_gids = run_task('cem_linux::audit_duplicate_gid', $targets)
  $duplicate_usernames = run_task('cem_linux::audit_duplicate_user_names', $targets)
  $duplicate_group_names = run_task('cem_linux::audit_duplicate_group_names', $targets)
  $users_in_shadow_group = run_task('cem_linux::audit_shadow_group', $targets)

  $plan_result = {
    'enforce_shadowed_passwords' => $esp_result,
    'enforce_users_have_passwords' => $eup_result,
    'root_uid_is_only_uid_0' => $root_uid_result,
    'root_path_integrity' => $root_path_result,
    'user_homedir_audit' => $user_homedir_audit,
    'nonexistent_passwd_groups' => $nonexistent_passwd_groups,
    'duplicate_uid' => $duplicate_uids,
    'duplicate_gid' => $duplicate_gids,
    'duplicate_usernames' => $duplicate_usernames,
    'duplicate_group_names' => $duplicate_group_names,
    'users_in_shadow_group' => $users_in_shadow_group,
  }
  return $plan_result
}
