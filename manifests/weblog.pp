define netdata::weblog (
  String $param_name = $title,
  String $path,
  ) {

  $params = {
    "${title}" => {
      'name'  => "${param_name}",
      'path'  => "${path}",
    }
  }

  concat::fragment { "weblog_entry-${title}":
    target  => "${netdata::config_dir}/python.d/web_log.conf",
    content => template('netdata/config_file.conf.erb'),
    order   => 01,
    require => Exec['install_netdata']
  }

}
