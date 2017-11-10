class netdata::install inherits netdata {

  $build_deps = [
    'autoconf-archive',
    'autoconf',
    'autogen',
    'automake',
    'gcc',    
    'libmnl-dev',
    'make',
    'pkg-config',
    'uuid-dev',
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

  if ! defined(Package['curl']) { package { 'curl': ensure => 'present', install_options => ['--force-yes'] }}
  if ! defined(Package['git']) { package { 'git': ensure => 'present', install_options => ['--force-yes'] }}
  if ! defined(Package['zlib1g-dev']) { package { 'zlib1g-dev': ensure => 'present', install_options => ['--force-yes'] }}


  if $netdata::install_plugin_dependencies {
    ensure_packages( $plugin_deps, {'ensure' => 'present'} )

    unless $::is_virtual {
      ensure_packages( 'lm-sensors', {'ensure' => 'present'} )
    }
  }

  if $netdata::install_jq {
    ensure_packages( 'jq', {'ensure' => 'present'} )
  }

  vcsrepo { $netdata::repo_location:
    ensure   => $netdata::repo_ensure,
    provider => git,
    source   => $netdata::installation_source,
    notify   => Exec['install_netdata'],
  }

  if $netdata::update_with_cron {
    cron { 'netdata-updater.sh':
      command => "${netdata::repo_location}/netdata-updater.sh",
      hour    => $netdata::update_cron_hour,
      minute  => $netdata::update_cron_min,
      user    => $netdata::update_cron_user,
    }
  }

  exec { 'install_netdata':
    command     => "${netdata::repo_location}/netdata-installer.sh --dont-wait --dont-start-it",
    cwd         => $netdata::repo_location,
    creates     => $netdata::config_dir,
    refreshonly => true,
    require     => Vcsrepo[$netdata::repo_location]
  }
}
