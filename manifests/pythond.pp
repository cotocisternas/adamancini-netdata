define netdata::pythond (
  $path   = "${netdata::config_dir}/python.d",
  $params,
) {

  validate_hash($params)

  if $title == 'web_log.conf' {
    fail("Use ::netdata::weblog function.")
  }

  file { "${path}/${title}":
    ensure  => present,
    content => template('netdata/config_file.conf.erb'),
    owner   => $netdata::service_name,
    group   => $netdata::service_name,
    mode    => '0660',
    force   => true,
    require => Exec['install_netdata']
  }

}
