define herqles::framework::framework (
  $framework_config={}
) {

  require ::herqles

  $install_path = $herqles::install_path
  $config_path = $herqles::config_path
  $user = $herqles::user
  $manage_service = $herqles::manage_service
  $datacenter = $herqles::datacenter

  $module = getparam(Herqles::Framework::Framework_data[$name], "module")
  $pkgname = getparam(Herqles::Framework::Framework_data[$name], "pkgname")
  $version = getparam(Herqles::Framework::Framework_data[$name], "version")
  $repo = getparam(Herqles::Framework::Framework_data[$name], "repo")
  $install_args = getparam(Herqles::Framework::Framework_data[$name], "install_args")

  $config = merge($framework_config, { 'module' => $module, 'datacenter' => $datacenter })

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

  file { "${config_path}/hq-framework/config.d/${name}.yml":
    ensure  => present,
    mode    => '0600',
    owner   => $user,
    group   => $user,
    content => template('herqles/config.yml.erb'),
    require => Python::Pip[$pkgname]
  }

  if $manage_service {

    exec { "herqles-framework ${name} install":
      command => "touch ${config_path}/hq-framework/.${name}",
      onlyif  => "test ! -f ${config_path}/hq-framework/.${name}",
      creates => "${config_path}/hq-framework/.${name}",
      path    => [ '/bin', '/usr/bin' ],
      notify  => Service['hq-framework'],
      require => [ File["${config_path}/hq-framework"], File["${config_path}/hq-framework/config.d/${name}.yml"] ]
    }

  }

}
