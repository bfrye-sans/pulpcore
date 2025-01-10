class pulpcore::install (
  String $settings_dir,
  String $content_dir,
  String $pgsql_dir,
  String $containers_dir,
  Boolean $manage_firewall,
  String $firewall_port,
  String $hostname,
  Boolean $use_proxy,
  String $proxy,
  String $no_proxy,
) {
  class { 'docker': }

  # Create required directories
  file { [
      $settings_dir,
      $content_dir,
      $pgsql_dir,
      $containers_dir,
    ]:
      ensure  => directory,
      owner   => 'pulp',
      group   => 'pulp',
      mode    => '0755',
      require => Package['podman'],
  }

  # Generate settings.py content
  $proxy_settings = $use_proxy ? {
    true    => "HTTP_PROXY = '${proxy}'\nHTTPS_PROXY = '${proxy}'\nNO_PROXY = '${no_proxy}'\n",
    default => '',
  }

  $settings_content = @("SETTINGS")
    CONTENT_ORIGIN = '${hostname}'
    ${proxy_settings}
    | SETTINGS

  # Create the settings.py file
  file { "${settings_dir}/settings.py":
    ensure  => file,
    owner   => 'pulp',
    group   => 'pulp',
    mode    => '0644',
    content => $settings_content,
    require => File[$settings_dir],
  }

  # if manage_firewall = true
  if $manage_firewall {
    if $facts['os']['family'] == 'RedHat' {
      firewall { "${firewall_port} allow inbound tcp port ${firewall_port}":
        proto  => 'tcp',
        port   => $firewall_port,
        action => 'accept',
      }
    }
  }
}
