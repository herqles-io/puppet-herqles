class herqles::database (
  $driver,
  $host,
  $port,
  $database,
  $username,
  $password,
  $pool_size=20,
) {

  validate_string($driver)
  validate_string($host)
  validate_integer($port)
  validate_string($database)
  validate_string($username)
  validate_string($password)
  validate_integer($pool_size)

  $install_path = $herqles::install_path
  $user = $herqles::user

  if $driver == 'postgres' {
    include ::postgresql::globals
    include ::postgresql::client
    include ::postgresql::lib::devel

    Class['::postgresql::globals']
    -> Class['::postgresql::client']
    -> Class['::postgresql::lib::devel']

    python::pip { 'psycopg2==2.6':
      ensure     => 'present',
      virtualenv => "${install_path}/venv",
      owner      => $user,
      require    => [ Class['::postgresql::globals'], Class['::postgresql::client'], Class['::postgresql::lib::devel'] ]
    }
  } elsif $driver == 'mysql' {

    python::pip { 'pymysql==0.6.6':
      ensure     => 'present',
      virtualenv => "${install_path}/venv",
      owner      => $user,
    }

  } else {
    fail('Database driver must be postgres or mysql')
  }

  $output = {
    driver    => $driver,
    host      => $host,
    port      => $port,
    database  => $database,
    username  => $username,
    password  => $password,
    pool_size => $pool_size
  }

}
