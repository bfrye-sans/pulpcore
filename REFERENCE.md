# Reference

## Table of Contents

- [Classes](#classes)
  - [`pulpcore`](#pulpcore)
  - [`pulpcore::install`](#pulpcoreinstall)
  - [`pulpcore::container`](#pulpcorecontainer)
  - [`pulpcore::repository`](#pulpcorerepository)
- [Parameters](#parameters)
  - [Class: `pulpcore`](#class-pulpcore)
  - [Class: `pulpcore::install`](#class-pulpcoreinstall)
  - [Class: `pulpcore::container`](#class-pulpcorecontainer)
  - [Class: `pulpcore::repository`](#class-pulpcorerepository)
- [Limitations](#limitations)
- [Examples](#examples)

---

## Classes

### `pulpcore`

The primary class for configuring and managing Pulpcore. Delegates setup to child classes like `pulpcore::install`, `pulpcore::container`, and `pulpcore::repository`.

### `pulpcore::install`

Handles the installation and setup of directories, firewall rules, and configuration files for Pulpcore.

### `pulpcore::container`

Manages Pulpcore as a containerized application using Docker. Configures directories as container volumes.

### `pulpcore::repository`

Manages Pulpcore repositories, remotes, publications, and distributions. Dynamically handles multiple repository types (`rpm`, `deb`, `container`, `gem`).

---

## Parameters

### Class: `pulpcore`

| Parameter         | Data type       | Description                                                       | Default                     |
|-------------------|-----------------|-------------------------------------------------------------------|-----------------------------|
| `settings_dir`    | `String`        | Directory for Pulpcore settings.                                  | `/var/lib/pulp/settings`    |
| `content_dir`     | `String`        | Directory for Pulpcore content.                                   | `/var/lib/pulp/pulp_content`|
| `pgsql_dir`       | `String`        | Directory for PostgreSQL data.                                    | `/var/lib/pulp/pgsql`       |
| `containers_dir`  | `String`        | Directory for container data.                                     | `/var/lib/pulp/containers`  |
| `manage_firewall` | `Boolean`       | Whether to manage firewall rules.                                 | `true`                      |
| `exposed_port`    | `String`        | Port to expose the Pulpcore API.                                  | `80`                        |
| `hostname`        | `String`        | Hostname for Pulpcore. Defaults to the system’s FQDN.             | FQDN of the host            |
| `use_proxy`       | `Boolean`       | Whether to use a proxy server.                                    | `false`                     |
| `proxy`           | `String`        | Proxy server URL.                                                 | `''`                        |
| `no_proxy`        | `String`        | Domains to bypass the proxy.                                      | `''`                        |

---

### Class: `pulpcore::install`

| Parameter         | Data type       | Description                                                       | Default                     |
|-------------------|-----------------|-------------------------------------------------------------------|-----------------------------|
| `settings_dir`    | `String`        | Directory for Pulpcore settings.                                  | `/var/lib/pulp/settings`    |
| `content_dir`     | `String`        | Directory for Pulpcore content.                                   | `/var/lib/pulp/pulp_content`|
| `pgsql_dir`       | `String`        | Directory for PostgreSQL data.                                    | `/var/lib/pulp/pgsql`       |
| `containers_dir`  | `String`        | Directory for container data.                                     | `/var/lib/pulp/containers`  |
| `manage_firewall` | `Boolean`       | Whether to manage firewall rules.                                 | `true`                      |
| `firewall_port`   | `String`        | Port for the API service.                                         | `80`                        |
| `hostname`        | `String`        | Hostname for Pulpcore. Defaults to the system’s FQDN.             | FQDN of the host            |
| `use_proxy`       | `Boolean`       | Whether to use a proxy server.                                    | `false`                     |
| `proxy`           | `String`        | Proxy server URL.                                                 | `''`                        |
| `no_proxy`        | `String`        | Domains to bypass the proxy.                                      | `''`                        |

---

### Class: `pulpcore::container`

| Parameter         | Data type       | Description                                                       | Default                     |
|-------------------|-----------------|-------------------------------------------------------------------|-----------------------------|
| `image`           | `String`        | Docker image for Pulpcore.                                        | `'pulp/pulp'`               |
| `settings_dir`    | `String`        | Directory for Pulpcore settings.                                  | `/var/lib/pulp/settings`    |
| `content_dir`     | `String`        | Directory for Pulpcore content.                                   | `/var/lib/pulp/pulp_content`|
| `pgsql_dir`       | `String`        | Directory for PostgreSQL data.                                    | `/var/lib/pulp/pgsql`       |
| `containers_dir`  | `String`        | Directory for container data.                                     | `/var/lib/pulp/containers`  |
| `image_version`   | `String`        | Docker image version.                                             | `'latest'`                  |
| `container_name`  | `String`        | Name of the Pulpcore container.                                   | `'pulpcore'`                |
| `restart_container`| `Boolean`      | Whether to restart the container automatically.                   | `true`                      |

---

### Class: `pulpcore::repository`

| Parameter         | Data type       | Description                                                       | Default                     |
|-------------------|-----------------|-------------------------------------------------------------------|-----------------------------|
| `repositories`    | `Hash`          | Definitions of repositories, including name, type, and attributes.| `{}`                        |
| `auth_token`      | `Optional[String]`| Authentication token for accessing Pulpcore API.                | `undef`                     |
| `api_username`    | `String`        | Username for basic authentication.                                | `'admin'`                   |
| `api_password`    | `String`        | Password for basic authentication.                                | `'admin'`                   |
| `api_url`         | `String`        | Pulpcore API base URL.                                            | `"http://${hostname}:${exposed_port}"`|

---

## Limitations

- Tested on:
  - RHEL 8/9
  - Rocky Linux 8/9
- Supports repository types: `rpm`, `deb`, `container`, `gem`.
- Requires Pulpcore API to be accessible.

---

## Examples

### Basic repository definition

```yaml
pulpcore::repositories:
  my-repo:
    description: "My RPM repository"
    remote_url: "http://example.com/rpm/"
    policy: "immediate"
    base_path: "rpm/myrepo"
    repo_type: "rpm"