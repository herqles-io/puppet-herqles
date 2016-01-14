define herqles::component (
  $pkgname,
  $config,
  $repo=None,
  $version='present',
  $install_args=undef,
) {

  require ::herqles

  $manage_service = $herqles::manage_service
  $install_path = $herqles::install_path
  $config_path = $herqles::config_path
  $user = $herqles::user

  validate_string($pkgname)
  if $repo != None {
    validate_string($repo)
  }
  validate_hash($config)

  python::pip { $pkgname:
    ensure       => $version,
    pkgname      => $pkgname,
    url          => $repo,
    virtualenv   => "${install_path}/venv",
    owner        => $user,
    install_args => $install_args,
  }

  file { "${config_path}/${name}":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }
  file { "${config_path}/${name}/config.yml":
    ensure  => file,
    mode    => '0644',
    owner   => $user,
    group   => $user,
    content => template('herqles/config.yml.erb'),
  }
  if !defined(File['/etc/sysconfig/herqles']) {
    file { '/etc/sysconfig/herqles':
      ensure  => file,
      owner   => $user,
      group   => $user,
      content => template('herqles/sysconfig.erb'),
    }
  }

  if $manage_service {
    herqles::service { $name:
      subscribe => File["${config_path}/${name}/config.yml", '/etc/sysconfig/herqles' ],
      require   => File["${config_path}/${name}/config.yml", '/etc/sysconfig/herqles'],
    }
  }

}
