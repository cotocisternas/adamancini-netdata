class netdata::install inherits netdata {

  $build_deps = [
    'autoconf-archive',
    'autoconf',
    'autogen',
    'automake',
    'curl',
    'gcc',
    'git',
    'libmnl-dev',
    'make',
    'pkg-config',
    'uuid-dev',
    'zlib1g-dev',
  ]

  $plugin_deps = [
    'iproute2',
    'python',
    'python-yaml',
    'python-mysqldb',
    'python-psycopg2',
    'nodejs',
    'libmnl0',
    'netcat'
  ]

  if $netdata::install_dependencies {
    ensure_packages( $build_deps, {'ensure' => 'present'} )
  }

  if $netdata::install_plugin_dependencies {
    ensure_packages( $plugin_deps, {'ensure' => 'present'} )

    unless $::is_virtual {
      ensure_packages( 'lm-sensors', {'ensure' => 'present'} )
    }
  }

  if $netdata::install_jq {
    ensure_packages( 'jq', {'ensure' => 'present'} )
  }

  if $netdata::install_from_git {

    vcsrepo { $netdata::repo_location:
      ensure   => $netdata::repo_ensure,
      provider => git,
      source   => $netdata::installation_source,
      before   => Exec['Install netdata'],
    }

    if $netdata::update_with_cron {
      cron { 'netdata-updater.sh':
        command => "${netdata::repo_location}/netdata-updater.sh",
        hour    => $netdata::update_cron_hour,
        minute  => $netdata::update_cron_min,
        user    => $netdata::update_cron_user,
      }
    }
  }
  else {

    $installation_source = "https://github.com/firehol/netdata/releases/download/v${netdata::release_version}/netdata-${netdata::release_version}.tar.gz"

    exec { "Download netdata-${netdata::release_version}":
      command => "/usr/bin/wget -qO- ${installation_source} | tar xvz -C /root/",
      creates => "/root/netdata-${netdata::release_version}",
      before  => Exec['Install netdata']
    }
  }

  exec { 'Install netdata':
    command     => "${netdata::repo_location}/netdata-installer.sh",
    cwd         => $netdata::repo_location,
    creates     => $netdata::config_dir,
    refreshonly => true,
  }
}
