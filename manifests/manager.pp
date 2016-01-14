class herqles::manager (
  $version='present'
) {

  require ::herqles::rabbitmq
  require ::herqles::database
  require ::herqles::manager::identity
  require ::herqles::manager::assignment

  ensure_packages([ 'openldap-devel' ])

  $log_path = $herqles::log_path
  $manage_service = $herqles::manage_service

  $config_base = {
    rabbitmq   => $herqles::rabbitmq::output,
    sql        => $herqles::database::output,
    identity   => $herqles::manager::identity::output,
    assignment => $herqles::manager::assignment::output,
    paths      => {
      logs => $log_path,
      pid  => '/var/run/herqles/hq-manager.pid'
    }
  }

  if defined(Class['herqles::ldap']) {

    $config = merge($config_base, { ldap => $herqles::ldap::output })

  } else {
    $config = $config_base
  }

  herqles::component { 'hq-manager':
    pkgname      => 'hq-manager',
    repo         => 'git+https://github.com/herqles-io/hq-manager.git',
    install_args => '--process-dependency-links',
    version      => $version,
    config       => $config
  }

}
