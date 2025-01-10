class pulpcore (
  String $settings_dir = '/var/lib/pulp/settings',
  String $content_dir = '/var/lib/pulp/pulp_content',
  String $pgsql_dir = '/var/lib/pulp/pgsql',
  String $containers_dir = '/var/lib/pulp/containers',
  Boolean $manage_firewall = true,
  String $exposed_port = '80',
  String $hostname = $facts['networking']['fqdn'], # Default to system's FQDN
  Boolean $use_proxy = false,                     # Whether to use a proxy
  String $proxy = '',                             # Proxy server address
  String $no_proxy = '',                          # No proxy addresses
) {
  # Include install class with proxy settings
  class { 'pulpcore::install':
    settings_dir    => $settings_dir,
    content_dir     => $content_dir,
    pgsql_dir       => $pgsql_dir,
    containers_dir  => $containers_dir,
    manage_firewall => $manage_firewall,
    firewall_port   => $exposed_port,
    hostname        => $hostname,
    use_proxy       => $use_proxy,
    proxy           => $proxy,
    no_proxy        => $no_proxy,
  }

  # Include other classes and pass proxy settings
  class { 'pulpcore::repository':
    use_proxy    => $use_proxy,
    proxy        => $proxy,
    no_proxy     => $no_proxy,
    hostname     => $hostname,
    exposed_port => $exposed_port,
  }

  class { 'pulpcore::container':
    settings_dir   => $settings_dir,
    content_dir    => $content_dir,
    pgsql_dir      => $pgsql_dir,
    containers_dir => $containers_dir,
    exposed_port   => $exposed_port,
  }
}
