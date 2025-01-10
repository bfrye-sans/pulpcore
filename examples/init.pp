class { 'pulpcore::install':
  settings_dir   => '/custom/settings',
  content_dir    => '/custom/content',
  pgsql_dir      => '/custom/pgsql',
  containers_dir => '/custom/containers',
  firewall_ports => ['80', '443', '8080'],
}

pulpcore::container { 'pulpcore':
  image          => 'pulp/pulp:latest',
  container_name => 'pulpcore',
  port_mapping   => '8080:80',
}
