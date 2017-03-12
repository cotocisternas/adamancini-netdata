class netdata::service inherits netdata {

  file { '/etc/init.d/netdata':
    ensure  => present,
    source  => 'puppet:///modules/netdata/netdata.init',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Exec['install_netdata'],
  }

  service { 'netdata':
    ensure     => $netdata::service_ensure,
    enable     => $netdata::service_enable,
    name       => $netdata::service_name,
    subscribe  => File['netdata_config'],
    require    => File['/etc/init.d/netdata'],
    hasstatus  => true,
    hasrestart => true,
  }
}
