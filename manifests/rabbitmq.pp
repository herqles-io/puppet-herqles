class herqles::rabbitmq (
  $hosts,
  $username,
  $password,
  $virtual_host
) {

  validate_array($hosts)
  validate_string($username)
  validate_string($password)
  validate_string($virtual_host)

  $output = {
    hosts        => $hosts,
    username     => $username,
    password     => $password,
    virtual_host => $virtual_host
  }

}
