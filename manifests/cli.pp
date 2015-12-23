class herqles::cli (
  $manager_url,
  $framework_url,
  $username=undef,
  $password=undef,
  $manage_config=true,
  $version='present',
  $plugins={}
) {

  require ::herqles

  $install_path = $herqles::install_path
  $user         = $herqles::user

  python::pip { 'hq-cli':
    ensure     => $version,
    pkgname    => 'hq-cli',
    url        => 'git+https://github.com/herqles-io/hq-cli.git',
    virtualenv => "${install_path}/venv",
    owner      => $user,
  }

  $base_config = {
    manager_url => $manager_url,
    framework_url => $framework_url
  }

  if $username != undef {
    $user_config = merge($base_config, { username => $username })
  } else {
    $user_config = $base_config
  }

  if $passowrd != undef {
    $config = merge($user_config, { password => $passowrd })
  } else {
    $config = $user_config
  }

  file { '/usr/local/bin/herq':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('herqles/herq.erb'),
  }

  if $manage_config {
    file { "/home/${user}/.herq/":
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0775',
    }

    file { "/home/${user}/.herq/plugins":
      ensure  => directory,
      owner   => $user,
      group   => $user,
      mode    => '0775',
      purge   => true,
      recurse => true
    }

    file { "/home/${user}/.herq/config.yaml":
      ensure  => file,
      mode    => '0644',
      owner   => $user,
      group   => $user,
      content => template('herqles/config.yml.erb'),
    }

  }

  create_resources(herqles::cli::plugin, $plugins)

}
