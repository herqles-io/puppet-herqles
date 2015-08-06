class herqles (
  $datacenter,
  $manage_python=true,
  $manage_user=true,
  $manage_service=true,
  $rotate_logs=true,
  $user='herqles',
  $install_path='/var/lib/herqles',
  $config_path='/etc/herqles',
  $log_path='/var/log/herqles'
) {

  validate_string($datacenter)
  validate_bool($manage_python)
  validate_bool($manage_user)
  validate_bool($manage_service)
  validate_string($user)
  validate_absolute_path($install_path)

  $version = $::operatingsystemmajrelease ? {
    '7'     => 'system',
    default => '2.7',
  }

  if $manage_python {
    class { 'python':
      version    => $version,
      dev        => true,
      virtualenv => true,
    }
    ensure_packages([ 'gcc-c++' ])
  }

  file { $install_path:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }
  file { $config_path:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }
  file { $log_path:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }
  if $manage_user {
    user { $user:
      shell  => '/sbin/nologin',
      home   => $install_path,
      system => true,
    }
  }

  if $rotate_logs {

    require logrotate::base

    logrotate::rule { 'herqles-logs':
      ensure       => present,
      path         => "${log_path}/*.log",
      compress     => true,
      missingok    => true,
      ifempty      => false,
      copytruncate => true,
      create       => true,
      create_mode  => 0644,
      create_owner => $user,
      create_group => $user,
      rotate       => 1,
      rotate_every => 'week'
    }

  }

  python::virtualenv { "${install_path}/venv":
    ensure  => present,
    version => $version,
    owner   => $user,
    group   => $user,
    require => [ Class['python'], Package[ 'gcc-c++' ] ],
  }

}
