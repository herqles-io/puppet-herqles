class herqles::ldap (
  $host,
  $domain,
  $base_dn,
  $bind_username,
  $bind_password
) {

  require ::herqles

  validate_string($host)
  validate_string($domain)
  validate_string($base_dn)
  validate_string($bind_username)
  validate_string($bind_password)

  ensure_packages([ 'openldap-devel' ])

  python::pip { 'python-ldap==2.4.19':
    ensure       => 'present',
    virtualenv   => "${::herqles::install_path}/venv",
    owner        => $::herqles::user,
    require      => Package['openldap-devel']
  }

  $output = {
    host          => $host,
    domain        => $domain,
    base_dn       => $base_dn,
    bind_username => $bind_username,
    bind_password => $bind_password
  }

}
