Puppet::Functions.create_function(:'pulpcore::lookup_pulp_href') do
  dispatch :lookup do
    param 'String', :resource_name
    param 'String', :auth_token
    param 'String', :api_url
  end

  def lookup(resource_name, auth_token, api_url)
    require 'net/http'
    require 'json'
    require 'uri'

    uri = URI("#{api_url}?name=#{resource_name}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{auth_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    raise Puppet::Error, "Failed to query #{resource_name}: #{response.body}" unless response.code.to_i == 200

    data = JSON.parse(response.body)
    data['results'].first['pulp_href']
  rescue StandardError => e
    raise Puppet::Error, "Error retrieving pulp_href for #{resource_name}: #{e.message}"
  end
end