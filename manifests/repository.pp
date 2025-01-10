class pulpcore::repository (
  Hash $repositories = lookup('pulpcore::repositories', { default_value => {} }),
  String $auth_token = lookup('pulpcore::auth_token', { default_value => '' }),
  String $api_username = lookup('pulpcore::api_username', { default_value => 'admin' }),
  String $api_password = lookup('pulpcore::api_password', { default_value => 'admin' }),
  String $api_url    = lookup('pulpcore::api_url', { default_value => "http://${hostname}:${exposed_port}" }),
) {
  $repositories.each |$repo_name, $repo_data| {
    $repo_type = $repo_data.get('repo_type', 'rpm')

    # Determine API base path based on repo_type
    $repo_base_path = case $repo_type {
      'rpm'        => 'repositories/rpm/rpm',
      'deb'        => 'repositories/deb/apt',
      'gem'        => 'repositories/gem/gem',
      'container'  => 'repositories/container/container',
      default      => fail("Unsupported repo_type '${repo_type}' for repository '${repo_name}'"),
    }

    $remote_base_path = case $repo_type {
      'rpm'        => 'remotes/rpm/rpm',
      'deb'        => 'remotes/deb/apt',
      'gem'        => 'remotes/gem/gem',
      'container'  => 'remotes/container/container',
      default      => fail("Unsupported repo_type '${repo_type}' for repository '${repo_name}'"),
    }

    $publication_base_path = case $repo_type {
      'rpm'        => 'publications/rpm/rpm',
      'deb'        => 'publications/deb/apt',
      'gem'        => 'publications/gem/gem',
      'container'  => 'publications/container/container',
      default      => fail("Unsupported repo_type '${repo_type}' for repository '${repo_name}'"),
    }

    $distribution_base_path = case $repo_type {
      'rpm'        => 'distributions/rpm/rpm',
      'deb'        => 'distributions/deb/apt',
      'gem'        => 'distributions/gem/gem',
      'container'  => 'distributions/container/container',
      default      => fail("Unsupported repo_type '${repo_type}' for repository '${repo_name}'"),
    }

    # Repository resource
    pulp_resource { "repository-${repo_name}":
      ensure     => present,
      category   => 'repository',
      content    => {
        'name'        => $repo_name,
        'description' => $repo_data['description'],
      },
      auth_token => $auth_token ? {
        ''      => "${api_username}:${api_password}",
        default => undef,
      },
      api_url    => "${api_url}/${repo_base_path}/",
    }

    # Remote resource
    pulp_resource { "remote-${repo_name}":
      ensure     => present,
      category   => 'remote',
      content    => {
        'name'  => "remote-${repo_name}",
        'url'   => $repo_data['remote_url'],
        'policy' => $repo_data.get('policy', 'immediate'),
        'proxy_url' => $repo_data.get('proxy_url', undef),
      },
      auth_token => $auth_token ? {
        ''      => "${api_username}:${api_password}",
        default => undef,
      },
      api_url    => "${api_url}/${remote_base_path}/",
      require    => Pulp_resource["repository-${repo_name}"],
    }

    # Publication resource
    pulp_resource { "publication-${repo_name}":
      ensure     => present,
      category   => 'publication',
      content    => {
        'repository' => $repo_name,
      },
      auth_token => $auth_token ? {
        ''      => "${api_username}:${api_password}",
        default => undef,
      },
      api_url    => "${api_url}/${publication_base_path}/",
      require    => Pulp_resource["remote-${repo_name}"],
    }

    # Distribution resource
    pulp_resource { "distribution-${repo_name}":
      ensure     => present,
      category   => 'distribution',
      content    => {
        'base_path'   => $repo_data['base_path'],
        'publication' => lookup_pulp_href("publication-${repo_name}", $auth_token, "${api_url}/${publication_base_path}/"),
      },
      auth_token => $auth_token ? {
        ''      => "${api_username}:${api_password}",
        default => undef,
      },
      api_url    => "${api_url}/${distribution_base_path}/",
      require    => Pulp_resource["publication-${repo_name}"],
    }

    # Sync resource
    pulp_resource { "sync-${repo_name}":
      ensure     => present,
      category   => 'sync',
      content    => {
        'repository' => $repo_name,
        'remote'     => "remote-${repo_name}",
      },
      auth_token => $auth_token ? {
        ''      => "${api_username}:${api_password}",
        default => undef,
      },
      api_url    => "${api_url}/${repo_base_path}/sync/",
      require    => Pulp_resource["distribution-${repo_name}"],
    }
  }
}
