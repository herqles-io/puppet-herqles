define herqles::service {

  if $operatingsystemrelease =~ /^6.*/ {
    if $initd_file == None {
      fail('initd service template must be given')
    }

    validate_string($initd_file)
    file { "/etc/init.d/${name}":
      ensure  => file,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('herqles/service/init.d.erb'),
      require => Python::Pip[$name],
      notify => Service[$name],
    }
    service { $name:
      ensure  => running,
      enable  => true,
      require => File["/etc/init.d/${name}"]
    }

  } elsif $operatingsystemrelease =~ /^7.*/ {
    if $systemd_file == None {
      fail('systemd service template must be given')
    }

    validate_string($systemd_file)
    file { "/etc/systemd/system/${name}.service":
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('herqles/service/service.erb'),
      require => Python::Pip[$name],
      notify  => Exec["${name} systemd reload"],
    }
    exec {"${name} systemd reload":
      command     => "/bin/systemctl daemon-reload",
      refreshonly => true,
      notify      => Service[$name]
    }
    service { $name:
      ensure  => running,
      enable  => true,
      require => File["/etc/systemd/system/${name}.service"]
    }

  }

}
