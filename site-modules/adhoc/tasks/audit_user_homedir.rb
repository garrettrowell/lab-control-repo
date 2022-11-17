#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

# Satisfies STIG V-204467, V-204468, V-204469, V-204470, V-204474, V-204475, V-204476, V-204477, V-204488, V-204473

require 'fileutils'
require 'json'

HOME_PERMS = %r{^\d\d7[0-5][01]$}.freeze
GROUP_WRITABLE = %r{^\d\d\d[2367]\d$}.freeze

params = JSON.parse(STDIN.read)

def audit_homedir_perms(path, stat, enforce, mode)
  octal_mode = '%o' % stat.mode.to_s
  return {} if HOME_PERMS.match?(octal_mode)

  if enforce
    system('chmod', mode, path)
    { chmod: true, old_mode: octal_mode, new_mode: mode }
  else
    { chmod: false, current_mode: octal_mode }
  end
end

def audit_ownership(path, user, enforce)
  owner_uid = File.stat(path).uid
  user_uid_gid = `getent passwd "#{user}" | cut -d: -f3,4`.strip.split(':')
  owner = `getent passwd "#{owner_uid}" | cut -d: -f1`.strip
  return {} if owner.to_s == user.to_s

  if enforce
    File.chown(user_uid_gid[0].to_i, user_uid_gid[1].to_i, path)
    { chown: true, old_owner: owner, user: user, new_uid: user_uid_gid[0], new_gid: user_uid_gid[1] }
  else
    { chown: false, current_owner: owner, user: user }
  end
end

def audit_dotfile(cpath, enforce, mode)
  stat = File.stat(cpath)
  curr_mode = '%o' % stat.mode.to_s
  return unless stat.world_writable? || GROUP_WRITABLE.match?(curr_mode)
  if enforce
    system('chmod', mode, cpath)
    { chmod: true, file: cpath, old_mode: curr_mode, new_mode: mode }
  else
    { chmod: false, file: cpath, current_mode: curr_mode }
  end
end

def audit_user_initfile(cpath, enforce, mode)
  return unless %r{umask [0-9]([0-6][0-9]|[0-9][0-6]|[0-6][0-6])}.match?(File.read(cpath))
  if enforce
    old_contents = File.read(cpath)
    new_contents = old_contents.gsub(%r{umask [0-9]([0-6][0-9]|[0-9][0-6]|[0-6][0-6])}, "umask #{mode}")
    File.open(cpath, 'w') { |file| file.puts new_contents }
    { file: cpath, enforce: true, umask: "Set occurances of umask to #{mode}" }
  else
    { file: cpath, enforce: false, umask: 'out of compliance' }
  end
end

def audit_forward_file(cpath, purge)
  if purge
    FileUtils.rm(cpath, force: true)
    { purge: true, file: cpath }
  else
    { purge: false, file: cpath }
  end
end

def audit_netrc_file(cpath, purge, enforce, mode)
  if purge
    FileUtils.rm(cpath, force: true)
    { purge: true, file: cpath }
  else
    stat = File.stat(cpath)
    curr_mode = '%o' % stat.mode.to_s
    if stat.world_writable? || GROUP_WRITABLE.match?(curr_mode)
      if enforce
        system('chmod', mode, cpath)
        { chmod: true, file: cpath, old_mode: curr_mode, new_mode: mode }
      else
        { chmod: false, file: cpath, current_mode: curr_mode }
      end
    end
  end
end

def audit_rhosts_file(cpath, purge)
  if purge
    FileUtils.rm(cpath, force: true)
    { purge: true, file: cpath }
  else
    { purge: false, file: cpath }
  end
end

def audit_homefiles(path, opts)
  files = Dir.children(path).map { |chld| "#{path}/#{chld}" }
  files_map = {
    dotfiles: [],
    initfiles: [],
    forward: [],
    netrc: [],
    rhosts: [],
  }
  dotfile_enforce = opts['enforce_user_dotfile_mode']
  dotfile_mode = opts['user_dotfile_mode']
  forward_purge = opts['purge_user_forward_files']
  netrc_purge = opts['purge_user_netrc_files']
  netrc_enforce = opts['enforce_user_netrc_mode']
  netrc_mode = opts['user_netrc_mode']
  initfiles_enforce = opts['enforce_user_init_files_umask']
  initfiles_umask = opts['user_init_files_umask']
  rhosts_purge = opts['purge_user_rhosts_files']
  files.each do |f|
    base = File.basename(f)
    next unless base.start_with?('.') && File.file?(f)

    case File.basename(f)
    when '.forward'
      files_map[:forward].push(f)
    when '.netrc'
      files_map[:netrc].push(f)
    when '.rhosts'
      files_map[:rhosts].push(f)
    else
      files_map[:dotfiles].push(f)
      files_map[:initfiles].push(f)
    end
  end
  files_map[:dotfiles].map! { |f| audit_dotfile(f, dotfile_enforce, dotfile_mode) }.compact!
  files_map[:forward].map! { |f| audit_forward_file(f, forward_purge) }.compact!
  files_map[:netrc].map! { |f| audit_netrc_file(f, netrc_purge, netrc_enforce, netrc_mode) }.compact!
  files_map[:rhosts].map! { |f| audit_rhosts_file(f, rhosts_purge) }.compact!
  files_map[:initfiles].map! { |f| audit_user_initfile(f, initfiles_enforce, initfiles_umask) }.compact!
  files_map
end

user_home_cmd = 'grep -E -v \'^(halt|sync|shutdown|bin|daemon)\' /etc/passwd | ' \
                'grep -E -v \'(:/bin:|:/sbin:|:/usr/bin:|:/usr/sbin:|:/bin/:|:/sbin/:|:/usr/bin/:|:/usr/sbin/:)\' | ' \
                'grep -E -v \'(:/boot|:/dev|:/etc:|:/etc/:|:/home:|:/home/:|:/lib:|:/lib/:|:/lib64:|:/lib64/:|:/opt:|:/opt/:|:/proc)\' | ' \
                'grep -E -v \'(:/usr:|:/usr/:|:/srv:|:/srv/:|:/tmp:|:/tmp/:|:/var:|:/var/|:/:)\' | ' \
                'awk -F: \'($7 != "\'"$(which nologin)"\'" && $7 != "/bin/false") { print $1 "," $6 }\''
user_homes = `#{user_home_cmd}`.split("\n")
homedir_audit = {}

user_homes.each do |h|
  arr = h.split(',')
  if arr[1] != '/' && File.directory?(arr[1])
    exe_search_path = system('grep', '-i', 'path=', "#{arr[1]}/.*")
    stat = File.stat(arr[1])
    perms = audit_homedir_perms(arr[1], stat, params['enforce_user_homedir_mode'], params['user_homedir_mode'])
    ownership = audit_ownership(arr[1], arr[0], params['enforce_user_homedir_ownership'])
    files = audit_homefiles(arr[1], params)
    homedir_audit[arr[0]] = {
      exists: true,
      new: false,
      path: arr[1],
      executable_search_path: exe_search_path,
      permissions: perms,
      ownership: ownership,
      file_audit: files,
    }
  elsif arr[1] == '/' || !File.exist?(arr[1]) && params['create_user_homedir']
    if File.directory?("/home/#{arr[0]}")
      system('usermod', '-d', "/home/#{arr[0]}", arr[0])
    else
      FileUtils.cp_r('/etc/skel', "/home/#{arr[0]}")
    end
    system('chmod', params['user_homedir_mode'], "/home/#{arr[0]}")
    FileUtils.chown(arr[0], arr[0], "/home/#{arr[0]}")
    homedir_audit[arr[0]] = {
      exists: true,
      new: true,
      path: "/home/#{arr[0]}",
    }
  else
    homedir_audit[arr[0]] = {
      exists: false,
    }
  end
end

$stdout.puts(JSON.generate(homedir_audit))
