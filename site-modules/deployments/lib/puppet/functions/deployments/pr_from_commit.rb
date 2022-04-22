# rubocop:disable Style/FrozenStringLiteralComment
# rubocop:enable Style/FrozenStringLiteralComment
require 'net/http'
require 'uri'
require 'cgi'
require 'json'

Puppet::Functions.create_function(:'deployments::pr_from_commit') do
  dispatch :pr_from_commit do
    required_param 'Hash', :repo
  end

  def pr_from_commit(repo)
    request_uri = "https://api.github.com/repos/#{repo['owner']}/#{repo['name']}/commits/#{repo['commit']}/pulls"
    request_response = make_request(request_uri, :get)
    body = JSON.parse(request_response.body)
    call_function('cd4pe_deployments::create_custom_deployment_event', "request_response: #{body}")
    pr_number = body[0]['number']
    call_function('cd4pe_deployments::create_custom_deployment_event', ": #{pr_number}")
    return pr_number
  end

  def make_request(endpoint, type, payload = nil, content_type = 'application/json')
    uri = URI.parse(endpoint)
    max_attempts = 3
    attempts = 0
    while attempts < max_attempts
      attempts += 1
      begin
        Puppet.debug("pr_from_commit: performing #{type} request to #{endpoint}")
        case type
        when :delete
          request = Net::HTTP::Delete.new(uri.request_uri)
        when :get
          request = Net::HTTP::Get.new(uri.request_uri)
        when :post
          request = Net::HTTP::Post.new(uri.request_uri)
          request.body = payload unless payload.nil?
          request.body = payload.to_json if content_type == 'application/json' && !payload.nil?
        when :patch
          request = Net::HTTP::Patch.new(uri.request_uri)
          request.body = payload unless payload.nil?
          request.body = payload.to_json if content_type == 'application/json' && !payload.nil?
        else
          raise Puppet::Error, "pr_from_commit#make_request called with invalid request type #{type}"
        end
        request['Content-Type'] = content_type
        request['Accept'] = 'application/json'

        connection = Net::HTTP.new(uri.host, uri.port)
        connection.use_ssl = true if uri.scheme == 'https'
        connection.read_timeout = 60
        response = connection.request(request)
      rescue SocketError => e
        raise Puppet::Error, "Could not connect to the Github endpoint at #{uri.host}: #{e.inspect}", e.backtrace
      end

      case response
      when Net::HTTPInternalServerError
        if attempts < max_attempts # rubocop:disable Style/GuardClause
          Puppet.debug("Received #{response} error from #{uri.host}, attempting to retry. (Attempt #{attempts} of #{max_attempts})")
          Kernel.sleep(3)
        else
          raise Puppet::Error, "Received #{attempts} server error responses from the Github endpoint at #{uri.host}: #{response.code} #{response.body}"
        end
      else # Covers Net::HTTPSuccess, Net::HTTPRedirection
        return response
      end
    end
  end
end
