class pulpcore::container (
  String $image          = 'pulp/pulp',
  String $settings_dir,
  String $content_dir,
  String $pgsql_dir,
  String $containers_dir,
  String $image_version  = 'latest',
  String $container_name = 'pulpcore',
  Boolean $restart_container = true,

) {
  $image_with_version = "pulp/pulp:${image_version}"

  docker::run { $container_name:
    image   => $image,
    ports   => [$exposed_port,'80'],
    restart => $restart ? {
      true    => 'always',
      default => 'no',
    }
    volumes => [
      "${settings_dir}:/etc/pulp:Z",
      "${content_dir}:/var/lib/pulp:Z",
      "${pgsql_dir}:/var/lib/pgsql:Z",
      "${containers_dir}:/var/lib/containers:Z",
    ],
    require => Class['docker'],
  }
}
