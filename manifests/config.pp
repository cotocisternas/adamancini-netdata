class netdata::config inherits netdata {

  require ::netdata::install

  if $netdata::manage_firewall {
    firewall { "${netdata::firewall_port} accept NETDATA":
      proto  => 'tcp',
      dport  => $netdata::firewall_port,
      action => 'accept',
    }
  }

  if $netdata::manage_config {

    file { 'netdata_config':
      ensure  => present,
      path    => $netdata::config_file,
      owner   => $netdata::service_name,
      group   => $netdata::service_name,
      mode    => '0664',
      require => Exec['install_netdata']
    }

    if $netdata::manage_alarms {
      file { 'netdata_alarms':
        ensure  => present,
        content => template('netdata/health_alarm_notify.conf.erb'),
        path    => $netdata::alarms_notify_config,
        owner   => $netdata::service_name,
        group   => $netdata::service_name,
        mode    => '0755',
        require => Exec['install_netdata']
      }
    }

    validate_hash($netdata::options)
    $ini_defaults = {
      'path'    => $netdata::config_file,
      'ensure'  => 'present',
    }
    create_ini_settings($netdata::options, $ini_defaults)
  }
}
