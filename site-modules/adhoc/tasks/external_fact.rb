#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'facter'
require 'yaml'
require 'fileutils'
require_relative "../../ruby_task_helper/files/task_helper.rb"

def deep_merge(h1,h2)
  h1.merge(h2){|k,v1,v2| v1.is_a?(Hash) && v2.is_a?(Hash) ? deep_merge(v1,v2) : v2}
end

begin
  params   = JSON.parse(STDIN.read)
  result   = {}
  kernel   = Facter.value(:kernel)
  path     = kernel == 'Linux' ? '/etc/puppetlabs/facter/facts.d' : 'C:/ProgramData/PuppetLabs/facter/facts.d'
  filepath = File.join(path, "#{params['fact']}.yaml")
  facthash = {}

  # create path if it doesn't exist
  FileUtils.mkdir_p(path) unless File.directory?(path)

  # build fact hash
  if params['value'].is_a?(Hash) && !params['value'].empty?
    facthash[params['fact']] = params['value']
  else
    raise TaskHelper::Error.new('Unable to parse value', 'user-input', params['value'].inspect)
  end

  # record the scavenger hunt starting time
  if params['value']['start'] == "true"
    facthash[params['fact']]['started_at'] = Time.now
  end

  # Write fact to file and merge if fact hash already exists
  if File.file?(filepath)
    existing_facts = YAML.load(File.read(filepath))

    begin
      # remove existing answer so we can overwrite it fully
      fact     = params['fact']
      scenario = params['value'].keys.first
      answer   = params['value'].values.first.keys.first
      existing_facts[fact][scenario].delete(answer)
    rescue
      # noop
    end

    merged_facts   = deep_merge(existing_facts,facthash)
    File.open(filepath, 'w') { |file| file.write(merged_facts.to_yaml) }
    result['fact'] = merged_facts
  else
    File.open(filepath, 'w') { |file| file.write(facthash.to_yaml) }
    result['fact'] = facthash
  end

  result['file'] = filepath
rescue Exception => e
  result[:_error] = {
    msg: e.message,
    kind: 'puppetlabs.tasks/task-error',
    details: { class: e.class.to_s }
  }
end

puts result.to_json
