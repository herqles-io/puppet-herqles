class herqles::framework (
  $frameworks,
  $version='present'
) {

  validate_hash($frameworks)

  create_resources(herqles::framework::framework_data, $frameworks)

  require ::herqles
  require ::herqles::rabbitmq
  require ::herqles::database

  $config_path = $herqles::config_path
  $log_path = $herqles::log_path
  $manage_service = $herqles::manage_service
  $user = $herqles::user

  $config = {
    rabbitmq   => $herqles::rabbitmq::output,
    sql        => $herqles::database::output,
    paths      => {
      logs              => $log_path,
      pid               => "/var/run/herqles/hq-framework.pid",
      framework_configs => "${config_path}/hq-framework/config.d"
    }
  }

  herqles::component { 'hq-framework':
    pkgname      => 'hq-framework',
    repo         => 'git+ssh://git@git.innova-partners.com/infrastructure/cmt-framework.git',
    install_args => [ '--process-dependency-links' ],
    version      => $version,
    config       => $config,
  }

  if $manage_service {

    file { "${config_path}/hq-framework/config.d":
      ensure  => directory,
      owner   => $user,
      group   => $user,
      mode    => '0755',
      purge   => true,
      recurse => true,
      notify  => Service['hq-framework']
    }

  } else {

    file { "${config_path}/hq-framework/config.d":
      ensure  => directory,
      owner   => $user,
      group   => $user,
      mode    => '0755',
      purge   => true,
      recurse => true
    }

  }

}
