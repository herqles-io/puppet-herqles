define herqles::cli::plugin (
  $pkgname,
  $repo=None,
  $version='present',
  $install_args=[],
  $module,
  $base_config={}
) {

  require ::herqles

  $manage_config = $herqles::cli::manage_config

  $install_path = $herqles::install_path
  $user = $herqles::user

  if !defined(Python::Pip[$pkgname]) {
    python::pip { $pkgname:
      ensure       => $version,
      pkgname      => $pkgname,
      url          => $repo,
      virtualenv   => "${install_path}/venv",
      owner        => $user,
      install_args => $install_args,
    }
  }


  if $manage_config {
    $config = merge($base_config, { module => $module })

    file { "/home/${user}/.herq/plugins/${name}.yaml":
      ensure  => file,
      mode    => '0644',
      owner   => $user,
      group   => $user,
      content => template('herqles/config.yml.erb'),
    }
  }

}
