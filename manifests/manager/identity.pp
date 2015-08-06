class herqles::manager::identity (
  $driver,
  $driver_config={}
) {

  validate_string($driver)
  validate_hash($driver_config)

  if $driver == 'LDAP' {

    require ::herqles::ldap

    $output_driver = {
      driver => 'cmtmanager.identity.ldap_driver'
    }

  } elsif $driver == 'Other' {
    if !has_key($driver_config, 'driver') {
      fail('The identity driver key is not given in the driver_config')
    }
    validate_string($driver_config['driver'])

    $output_driver = {}

  } else {
    fail('Driver must be LDAP or Other (SQL coming soon)')
  }

  $output = merge($driver_config, $output_driver)

}
