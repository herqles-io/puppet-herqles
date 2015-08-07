class herqles::worker (
  $workers,
  $version='present'
) {

  create_resources(herqles::worker::worker_data, $workers)

  require ::herqles
  require ::herqles::rabbitmq

  $config_path = $herqles::config_path
  $log_path = $herqles::log_path
  $user = $herqles::user
  $manage_service = $herqles::manage_service

  $config = {
    rabbitmq   => $herqles::rabbitmq::output,
    paths      => {
      logs           => $log_path,
      pid            => "/var/run/herqles/hq-worker.pid",
      worker_configs => "${config_path}/hq-worker/config.d"
    }
  }

  herqles::component { 'hq-worker':
    pkgname      => 'hq-worker',
    repo         => 'git+https://github.com/herqles-io/hq-worker.git',
    install_args => [ '--process-dependency-links' ],
    version      => $version,
    config       => $config
  }

  if $manage_service {

    file { "${config_path}/hq-worker/config.d":
      ensure  => directory,
      owner   => $user,
      group   => $user,
      mode    => '0755',
      purge   => true,
      recurse => true,
      notify  => Service['hq-worker']
    }

  } else {

    file { "${config_paoth}/hq-worker/config.d":
      ensure  => directory,
      owner   => $user,
      group   => $user,
      mode    => '0755',
      purge   => true,
      recurse => true
    }

  }

  exec { "hq-worker config reload":
    command     => "kill -s SIGUSR2 $(cat /var/run/herqles/hq-worker.pid)",
    onlyif      => "test -f /var/run/herqles/hq-worker.pid",
    path        => [ '/bin', '/usr/bin' ],
    refreshonly => true
  }

}
