# Pulpcore Puppet Module

[![Puppet Forge](https://img.shields.io/puppetforge/v/<module_name>.svg)](https://forge.puppet.com/<module_name>)
[![Build Status](https://github.com/bfrye-sans/pulpcore/actions/workflows/ci.yml/badge.svg)](https://github.com/bfrye-sans/pulpcore)

## Overview

The `pulpcore` module allows you to deploy and manage [Pulpcore](https://pulpproject.org/), an advanced platform for managing repositories of software packages. This module automates the setup and lifecycle of repositories, remotes, publications, and distributions, enabling seamless content delivery and management.

Pulpcore supports various content types, including:
- RPM packages
- Debian packages
- Container images
- Python packages (PyPI)
- Ruby gems

## Features

- **Repository Management**: Create, update, and delete repositories.
- **Remote Configuration**: Define remote sources for syncing content.
- **Content Synchronization**: Automate syncing between remotes and repositories.
- **Publications & Distributions**: Publish repository content and expose it via HTTP/HTTPS.
- **Dynamic Configuration**: Supports multiple content types (RPM, Debian, etc.) with Hiera integration.
- **API-Driven Operations**: Leverages Pulpcore's REST API for precise resource management.

---

## Requirements

### Supported Platforms
- **Operating Systems**:
  - Red Hat Enterprise Linux (RHEL) 8/9
  - Rocky Linux 8/9

### Puppet Compatibility
- Puppet <= 8.0

### Dependencies
- [`puppetlabs/stdlib`](https://forge.puppet.com/puppetlabs/stdlib)
- [`puppetlabs/firewall`](https://forge.puppet.com/puppetlabs/firewall)
- [`puppetlabs/docker`](https://forge.puppet.com/puppetlabs/docker) (optional for containerized Pulpcore setups)

---
