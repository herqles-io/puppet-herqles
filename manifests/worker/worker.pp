define herqles::worker::worker (
  $worker_config={}
) {

  require ::herqles

  $install_path   = $herqles::install_path
  $config_path    = $herqles::config_path
  $user           = $herqles::user
  $manage_service = $herqles::manage_service
  $datacenter     = $herqles::datacenter

  $module       = getparam(Herqles::Worker::Worker_data[$name], 'module')
  $pkgname      = getparam(Herqles::Worker::Worker_data[$name], 'pkgname')
  $version      = getparam(Herqles::Worker::Worker_data[$name], 'version')
  $repo         = getparam(Herqles::Worker::Worker_data[$name], 'repo')
  $install_args = getparam(Herqles::Worker::Worker_data[$name], 'install_args')

  $config = merge($worker_config, { 'module' => $module, 'datacenter' => $datacenter })

  if !defined(Python::Pip[$pkgname]) {

    python::pip { $pkgname:
      ensure       => $version,
      pkgname      => $pkgname,
      url          => $repo,
      virtualenv   => "${install_path}/venv",
      owner        => $user,
      install_args => $install_args
    }

  }

  file { "${config_path}/hq-worker/config.d/${name}.yml":
    ensure  => present,
    mode    => '0600',
    owner   => $user,
    group   => $user,
    content => template('herqles/config.yml.erb'),
    require => Python::Pip[$pkgname],
    notify  => Exec['hq-worker config reload']
  }

  if $manage_service {

    exec { "hq-worker ${name} install":
      command => "touch ${config_path}/hq-worker/.${name}",
      onlyif  => "test ! -f ${config_path}/hq-worker/.${name}",
      creates => "${config_path}/hq-worker/.${name}",
      path    => [ '/bin', '/usr/bin' ],
      notify  => Service['hq-worker'],
      require => [ File["${config_path}/hq-worker"], File["${config_path}/hq-worker/config.d/${name}.yml"] ]
    }

  }

}
