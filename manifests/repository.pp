class pulpcore::repository (
  Hash $repositories = lookup('pulpcore::repositories', { default_value => {} }),
  String $auth_token = lookup('pulpcore::auth_token', { default_value => '' }),
  String $api_username = lookup('pulpcore::api_username', { default_value => 'admin' }),
  String $api_password = lookup('pulpcore::api_password', { default_value => 'admin' }),
  String $api_url    = lookup('pulpcore::api_url', { default_value => "http://${hostname}:{${exposed_port}" }),
) {
  $repositories.each |$repo_name, $repo_data| {
    # Step 1: Create or update the repository
    pulp_resource { "repository-${repo_name}":
      ensure     => present,
      category   => 'repository',
      content    => {
        'name'        => $repo_name,
        'description' => $repo_data['description'],
      },
      auth_token => $auth_token,
      api_url    => "${api_url}/repositories/rpm/rpm/",
    }

    # Step 2: Create or update the remote
    pulp_resource { "remote-${repo_name}":
      ensure     => present,
      category   => 'remote',
      content    => {
        'name'  => "remote-${repo_name}",
        'url'   => $repo_data['remote_url'],
        'policy' => $repo_data.get('policy', 'immediate'),
        'proxy_url' => $repo_data.get('proxy_url', undef),
      },
      auth_token => $auth_token,
      api_url    => "${api_url}/remotes/rpm/rpm/",
      require    => Pulp_resource["repository-${repo_name}"],
    }

    # Step 3: Create or update the publication
    pulp_resource { "publication-${repo_name}":
      ensure     => present,
      category   => 'publication',
      content    => {
        'repository' => $repo_name,
      },
      auth_token => $auth_token,
      api_url    => "${api_url}/publications/rpm/rpm/",
      require    => Pulp_resource["remote-${repo_name}"],
    }

    # Step 4: Create or update the distribution
    pulp_resource { "distribution-${repo_name}":
      ensure     => present,
      category   => 'distribution',
      content    => {
        'base_path'   => $repo_data['base_path'],
        'publication' => lookup_pulp_href("publication-${repo_name}", $auth_token, "${api_url}/publications/rpm/rpm/"),
      },
      auth_token => $auth_token,
      api_url    => "${api_url}/distributions/rpm/rpm/",
      require    => Pulp_resource["publication-${repo_name}"],
    }
  }
}
