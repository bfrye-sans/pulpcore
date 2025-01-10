require 'net/http'
require 'json'
require 'uri'

Puppet::Type.type(:api_resource).provide(:rest) do
  desc 'Manage Pulp resources via REST API.'

  # Class-level cache for pulp_href
  @@pulp_href_cache = {}

  def create
    if exists?
      Puppet.info("Resource #{resource[:name]} already exists. Updating instead of creating.")
      update
      return
    end

    uri = URI("#{api_base_path}")
    req = Net::HTTP::Post.new(uri)
    set_auth_header(req)
    req['Content-Type'] = 'application/json'
    req.body = resource[:content].to_json

    response = send_request(uri, req)
    unless response.code.to_i == 201
      raise Puppet::Error, "Failed to create #{resource[:category]}: #{response.body}"
    end

    # Cache pulp_href if resource is a publication
    if resource[:category] == 'publication'
      publication_data = JSON.parse(response.body)
      pulp_href = publication_data['pulp_href']
      @@pulp_href_cache[resource[:name]] = pulp_href
      Puppet.info("Cached pulp_href for publication #{resource[:name]}: #{pulp_href}")
    end
  end

  def update
    uri = URI("#{api_base_path}/#{resource[:name]}")
    req = Net::HTTP::Patch.new(uri)
    set_auth_header(req)
    req['Content-Type'] = 'application/json'
    req.body = resource[:content].to_json

    response = send_request(uri, req)
    unless response.code.to_i == 200
      raise Puppet::Error, "Failed to update #{resource[:category]}: #{response.body}"
    end

    # Cache pulp_href if resource is a publication
    if resource[:category] == 'publication'
      publication_data = JSON.parse(response.body)
      pulp_href = publication_data['pulp_href']
      @@pulp_href_cache[resource[:name]] = pulp_href
      Puppet.info("Updated cache for pulp_href of publication #{resource[:name]}: #{pulp_href}")
    end
  end

  def destroy
    unless exists?
      Puppet.info("Resource #{resource[:name]} does not exist. Nothing to delete.")
      return
    end

    uri = URI("#{api_base_path}/#{resource[:name]}")
    req = Net::HTTP::Delete.new(uri)
    set_auth_header(req)

    response = send_request(uri, req)
    unless response.code.to_i == 204
      raise Puppet::Error, "Failed to delete #{resource[:category]}: #{response.body}"
    end

    # Remove from cache if it exists
    if @@pulp_href_cache.key?(resource[:name])
      @@pulp_href_cache.delete(resource[:name])
      Puppet.info("Removed pulp_href for #{resource[:name]} from cache.")
    end
  end

  def exists?
    uri = URI("#{api_base_path}/#{resource[:name]}")
    req = Net::HTTP::Get.new(uri)
    set_auth_header(req)

    response = send_request(uri, req)
    response.code.to_i == 200
  end

  def pulp_href
    # Return cached pulp_href if available
    if @@pulp_href_cache.key?(resource[:name])
      Puppet.info("Using cached pulp_href for #{resource[:name]}")
      return @@pulp_href_cache[resource[:name]]
    end

    # Fetch pulp_href from API if not cached
    Puppet.info("Fetching pulp_href for #{resource[:name]} from API")
    uri = URI("#{api_base_path}/#{resource[:name]}")
    req = Net::HTTP::Get.new(uri)
    set_auth_header(req)

    response = send_request(uri, req)
    if response.code.to_i == 200
      publication_data = JSON.parse(response.body)
      pulp_href = publication_data['pulp_href']
      @@pulp_href_cache[resource[:name]] = pulp_href
      Puppet.info("Cached pulp_href for #{resource[:name]}: #{pulp_href}")
      pulp_href
    else
      raise Puppet::Error, "Failed to fetch pulp_href for #{resource[:name]}: #{response.body}"
    end
  end

  private

  def api_base_path
    base_paths = {
      'repository' => {
        'rpm' => '/repositories/rpm/rpm',
        'deb' => '/repositories/deb/apt',
        'gem' => '/repositories/gem/gem',
        'container' => '/repositories/container/container',
      },
      'remote' => {
        'rpm' => '/remotes/rpm/rpm',
        'deb' => '/remotes/deb/apt',
        'gem' => '/remotes/gem/gem',
        'container' => '/remotes/container/container',
      },
      'publication' => {
        'rpm' => '/publications/rpm/rpm',
        'deb' => '/publications/deb/apt',
        'gem' => '/publications/gem/gem',
        'container' => '/publications/container/container',
      },
      'distribution' => {
        'rpm' => '/distributions/rpm/rpm',
        'deb' => '/distributions/deb/apt',
        'gem' => '/distributions/gem/gem',
        'container' => '/distributions/container/container',
      },
    }

    repo_type = resource[:content]['repo_type'] || 'rpm'
    base_paths.dig(resource[:category], repo_type) || raise(Puppet::Error, "Unsupported repo_type '#{repo_type}' for category '#{resource[:category]}'")
  end

  def set_auth_header(request)
    if resource[:auth_token]
      request['Authorization'] = "Bearer #{resource[:auth_token]}"
    elsif resource[:username] && resource[:password]
      encoded = Base64.strict_encode64("#{resource[:username]}:#{resource[:password]}")
      request['Authorization'] = "Basic #{encoded}"
    end
  end

  def send_request(uri, request)
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  end
end