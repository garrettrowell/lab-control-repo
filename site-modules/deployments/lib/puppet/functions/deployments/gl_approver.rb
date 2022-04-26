#!/opt/puppetlabs/puppet/bin/ruby
# rubocop:disable Style/FrozenStringLiteralComment
# rubocop:enable Style/FrozenStringLiteralComment
require 'net/http'
require 'uri'
require 'cgi'
require 'json'

Puppet::Functions.create_function(:'deployments::gl_approver') do
  dispatch :gl_approver do
    required_param 'String', :endpoint
    required_param 'Hash', :repo
    required_param 'Sensitive', :oauth_token
    required_param 'Integer', :pull_number
  end

  def gl_approver(endpoint, repo, oauth_token, pull_number)
    request_uri = "#{endpoint}/api/v4/projects/#{repo['project_id']}/merge_requests?iids[]=#{pull_number}"
    request_response = make_request(request_uri, :get, oauth_token)
    body = JSON.parse(request_response.body)
    approver =  body[0]['merged_by']['name']
    return approver
  end

  def make_request(endpoint, type, oauth_token, payload = nil, content_type = 'application/json')
    uri = URI.parse(endpoint)
    max_attempts = 3
    attempts = 0
    while attempts < max_attempts
      attempts += 1
      begin
        Puppet.debug("gl_approver: performing #{type} request to #{endpoint}")
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
          raise Puppet::Error, "gl_approver#make_request called with invalid request type #{type}"
        end

        request['Authorization'] = "Bearer #{oauth_token.unwrap.delete_prefix('"').delete_suffix('"')}"
#        request['Authorization'] = "Bearer #{oauth_token}"

        request['Content-Type'] = content_type
        request['Accept'] = 'application/json'

        connection = Net::HTTP.new(uri.host, uri.port)
        connection.use_ssl = true if uri.scheme == 'https'
        connection.read_timeout = 60
        response = connection.request(request)
      rescue SocketError => e
        raise Puppet::Error, "Could not connect to the Gitlab endpoint at #{uri.host}: #{e.inspect}", e.backtrace
      end

      case response
      when Net::HTTPInternalServerError
        if attempts < max_attempts # rubocop:disable Style/GuardClause
          Puppet.debug("Received #{response} error from #{uri.host}, attempting to retry. (Attempt #{attempts} of #{max_attempts})")
          Kernel.sleep(3)
        else
          raise Puppet::Error, "Received #{attempts} server error responses from the Gitlab endpoint at #{uri.host}: #{response.code} #{response.body}"
        end
      else # Covers Net::HTTPSuccess, Net::HTTPRedirection
        return response
      end
    end
  end
end
