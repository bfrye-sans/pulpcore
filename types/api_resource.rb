Puppet::Type.newtype(:pulp_resource) do
  @doc = 'Manage resources in Pulp API (repository, remote, sync, publication, distribution).'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the resource.'
  end

  newparam(:category) do
    desc 'The resource category (repository, remote, sync, publication, distribution).'
    validate do |value|
      unless %w[repository remote sync publication distribution].include?(value)
        raise ArgumentError, "Invalid category #{value}. Must be one of: repository, remote, sync, publication, distribution."
      end
    end
  end

  newproperty(:content) do
    desc 'The JSON content to send for create or update.'
  end

  newparam(:auth_token) do
    desc 'The Bearer token for API authentication.'
  end

  newparam(:username) do
    desc 'The username for Basic Authentication.'
  end

  newparam(:password) do
    desc 'The password for Basic Authentication.'
  end

  newparam(:api_url) do
    desc 'The base URL of the API (e.g., http://localhost:8080/pulp/api/v3).'
  end
end