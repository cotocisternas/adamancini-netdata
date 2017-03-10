class netdata (
  String $release_version,
  Stdlib::Absolutepath $config_dir,
  Stdlib::Absolutepath $config_file,
  Integer $firewall_port,
  Boolean $custom_registry_enabled,
  Optional[String] $custom_registry_hostname,
  Optional[String] $custom_registry_to_announce,
  Boolean $manage_config,
  Boolean $manage_firewall,
  Boolean $manage_alarms,
  Boolean $install_dependencies,
  Boolean $install_plugin_dependencies,
  Boolean $install_jq,
  Optional[String] $install_dir_root,
  String $installation_source,
  Optional[String] $repo_location,
  String $repo_ensure,
  Boolean $service_enable,
  String $service_ensure,
  Boolean $service_manage,
  String $service_name,
  Optional[String] $service_provider,
  Optional[Hash] $options,
  Stdlib::Absolutepath $alarms_notify_config,
  Optional[Boolean] $alarms_email,
  Optional[String] $alarms_email_recipient,
  Optional[Boolean] $alarms_pushover,
  Optional[String] $alarms_pushover_recipient,
  Optional[String] $alarms_pushover_app_token,
  Optional[Boolean] $alarms_pushbullet,
  Optional[String] $alarms_pushbullet_access_token,
  Optional[String] $alarms_pushbullet_recipient,
  Optional[Boolean] $alarms_twilio,
  Optional[String] $alarms_twilio_account_sid,
  Optional[String] $alarms_twilio_account_token,
  Optional[String] $alarms_twilio_number,
  Optional[String] $alarms_twilio_recipient,
  Optional[Boolean] $alarms_messagebird,
  Optional[String] $alarms_messagebird_access_key,
  Optional[String] $alarms_messagebird_number,
  Optional[String] $alarms_messagebird_recipient,
  Optional[Boolean] $alarms_telegram,
  Optional[String] $alarms_telegram_bot_token,
  Optional[String] $alarms_telegram_recipient,
  Optional[Boolean] $alarms_slack,
  Optional[String] $alarms_slack_webhook_url,
  Optional[String] $alarms_slack_recipient,
  Optional[Boolean] $alarms_discord,
  Optional[String] $alarms_discord_webhook_url,
  Optional[String] $alarms_discord_recipient,
  Optional[Boolean] $alarms_hipchat,
  Optional[String] $alarms_hipchat_server,
  Optional[String] $alarms_hipchat_auth_token,
  Optional[String] $alarms_hipchat_recipient,
  Optional[Boolean] $alarms_kafka,
  Optional[String] $alarms_kafka_url,
  Optional[String] $alarms_kafka_sender_ip,
  Optional[Boolean] $alarms_pagerduty,
  Optional[String] $alarms_pagerduty_recipient,

  Hash $purge,

  Hash $python_options,

  ) {

  contain netdata::install
  contain netdata::config
  contain netdata::service

  $default_purge_hash={
    'python.d'  => false,
    'node.d'    => false,
    'charts.d'  => false,
    'health.d'  => false
  }

  $_purge_python  = $purge['python.d']
  $_purge_node    = $purge['node.d']
  $_purge_charts  = $purge['charts.d']
  $_purge_health  = $purge['health.d']

  file { "${netdata::config_dir}/python.d":
    ensure  => directory,
    mode    => '775',
    owner   => 'netdata',
    group   => 'netdata',
    purge   => $_purge_python,
    recurse => true,
    force   => true
  }

  concat { "${netdata::config_dir}/python.d/web_log.conf":
    owner   => $netdata::service_name,
    group   => $netdata::service_name,
    mode    => '0660',
  }

  $python_options.each |$name, $params| {
    ::netdata::pythond{$name:
      params => $params
    }
  }

  Class['::netdata::install'] ->
  Class['::netdata::config'] ~>
  Class['::netdata::service']
}
