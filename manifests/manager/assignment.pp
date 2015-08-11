class herqles::manager::assignment (
  $driver,
  $driver_config={}
) {

  validate_string($driver)
  validate_hash($driver_config)

  if $driver == 'LDAP' {

    require ::herqles::ldap

    $output_driver = {
      driver => 'hqmanager.assignment.ldap_driver'
    }

  } elsif $driver == 'SQL' {

    if !has_key($driver_config, 'admin_username') {
      fail('SQL Assignment Driver Config does not have admin_username')
    }

    validate_string($driver_config['admin_username'])

    $output_driver = {
      driver => 'hqmanager.assignment.sql_driver'
    }

  } elsif $driver == 'Other' {

    if !has_key($driver_config, 'driver') {
      fail('The assignment driver key is not given in the driver_config')
    }
    validate_string($driver_config['driver'])

    $output_driver = {}

  } else {
    fail('Driver must be LDAP, SQL or Other')
  }

  $output = merge($driver_config, $output_driver)

}
