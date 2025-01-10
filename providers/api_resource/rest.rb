require 'net/http'
require 'json'
require 'uri'

Puppet::Type.type(:api_resource).provide(:rest) do
  desc 'Manage API resources via REST API.'

  def create
    if exists?
      Puppet.info("Resource #{resource[:name]} already exists. Updating instead of creating.")
      update
      return
    end

    if resource[:category] == 'distribution'
      Puppet.info("Creating a distribution for #{resource[:name]}...")
      create_distribution
    else
      perform_create
    end
  end

  def perform_create
    uri = URI("#{resource[:api_url]}#{resource[:base_path]}")
    req = Net::HTTP::Post.new(uri)
    set_auth_header(req)
    req['Content-Type'] = 'application/json'
    req.body = resource[:content].to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    unless response.code.to_i == 201
      raise Puppet::Error, "Failed to create #{resource[:category]}: #{response.body}"
    end

    JSON.parse(response.body)
  end

  def create_distribution
    # Step 1: Create the publication and get pulp_href
    publication_response = perform_create
    pulp_href = publication_response['pulp_href']

    unless pulp_href
      raise Puppet::Error, "Failed to retrieve pulp_href from publication response: #{publication_response}"
    end

    # Step 2: Create the distribution using the pulp_href
    distribution_content = resource[:content].merge('publication' => pulp_href)
    uri = URI("#{resource[:api_url]}#{resource[:base_path]}")
    req = Net::HTTP::Post.new(uri)
    set_auth_header(req)
    req['Content-Type'] = 'application/json'
    req.body = distribution_content.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    unless response.code.to_i == 201
      raise Puppet::Error, "Failed to create distribution: #{response.body}"
    end
  end

  def update
    uri = URI("#{resource[:api_url]}#{resource[:base_path]}/#{resource[:name]}")
    req = Net::HTTP::Patch.new(uri)
    set_auth_header(req)
    req['Content-Type'] = 'application/json'
    req.body = resource[:content].to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    unless response.code.to_i == 200
      raise Puppet::Error, "Failed to update #{resource[:category]}: #{response.body}"
    end
  end

  def destroy
    unless exists?
      Puppet.info("Resource #{resource[:name]} does not exist. Nothing to delete.")
      return
    end

    uri = URI("#{resource[:api_url]}#{resource[:base_path]}/#{resource[:name]}")
    req = Net::HTTP::Delete.new(uri)
    set_auth_header(req)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    unless response.code.to_i == 204
      raise Puppet::Error, "Failed to delete #{resource[:category]}: #{response.body}"
    end
  end

  def exists?
    uri = URI("#{resource[:api_url]}#{resource[:base_path]}/#{resource[:name]}")
    req = Net::HTTP::Get.new(uri)
    set_auth_header(req)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    response.code.to_i == 200
  end

  private

  def set_auth_header(request)
    if resource[:auth_token]
      request['Authorization'] = "Bearer #{resource[:auth_token]}"
    elsif resource[:username] && resource[:password]
      encoded = Base64.strict_encode64("#{resource[:username]}:#{resource[:password]}")
      request['Authorization'] = "Basic #{encoded}"
    end
  end
end