# covermymeds-herqles

# What This Module Affects
* Installs and configures Herqles Manager
* Installs and configures Herqles Framework
* Installs and configures Herqles Worker
* Installs and configures Herqles CLI

# Requirements
* puppetlabs/stdlib 4.x
* stankevich/python 1.9.x

# Optional Requirements
* rodjek/logrotate 1.1.x

# Supported OS
* RedHat 6 & 7
* CentOS 6 & 7

# Usage

### Base Configuration

```puppet
class { '::herqles'
  datacenter => 'aws-east'
}

class { '::herqles::database':
  driver   => 'postgres',
  host     => 'sql.example.com',
  port     => 5432,
  database => 'herqles',
  username => 'herqles',
  password => 'password'
}

class { '::herqles::rabbitmq':
  hosts        => ['rabbit1.example.com', 'rabbit2.example.com'],
  username     => 'herqles',
  password     => 'password',
  virtual_host => 'herqles'
}

class { '::herqles::ldap':
  host          => 'dc.exmaple.com',
  domain        => 'example.com',
  base_dn       => 'DC=example,DC=com',
  bind_username => 'bind_user',
  bind_password => 'bind_password'
}
```

**LDAP only needs to be defined if using LDAP identity or assignment**


### Install Herqles Manager

```puppet
include ::herqles::manager

class { '::herqles::manager::identity':
  driver => 'LDAP'
}

class { '::herqles::manager::assignment':
  driver => 'SQL',
  driver_config => { 'admin_username': 'admin' }
}
```

**If the assignment used contains an admin_username the user must exist in the identity used
or the identity must be able to create users**

### Install Herqles Framework

See reference for detailed information

```puppet
class { '::herqles::framework':
  frameworks => {}
}

herqles::framework::framework { 'my-awesome-framework': }
```

### Install Herqles Worker

See reference for detailed information

```puppet
class { '::herqles::worker':
  workers => {}
}

herqles::worker::worker { 'my-awesome-worker': }
```

# Reference

## Classes

* herqles : Main class for installation and management
* herqles::rabbitmq: Herqles RabbitMQ Config
* herqles::database: Herqles Database Config
* herqles::ldap: Herqles LDAP Config
* herqles::manager::identity: Herqles Identity Config
* herqles::manager::assignment: Herqles Assignment Config
* herqles::framework: Herqles Framework installation and configuration
* herqles::manager: Herqles Manager installation and configuration
* herqles::worker: Herqles Worker installtion and configuration

### Parameters

#### herqles

#####`datacenter`
String, the datacenter to set workers and frameworks as

#####`manage_python`
Boolean, should this module manage the installation of python2.7

Default: True

#####`manage_user`
Boolean, should this module manage the herqles user

Default: True

#####`manage_service`
Boolean, should this module manage the herqles services

**If disabled workers will not be restarted when adding a new worker**

Default: True

#####`rotate_logs`
Boolean, should this module manage rotating logs

Default: True

#####`user`
String, the user that herqles uses

Default: herqles

#####`install_path`
String, the path to install herqles in

Default: /var/lib/herqles

#####`config_path`
String, the path for herqles configs

Default: /etc/herqles

#####`log_path`
String, the path to install herqles in

Default: /var/log/herqles


#### herqles::rabbitmq

#####`hosts`
List, rabbitmq hosts to user

#####`username`
String, username for rabbitmq

#####`password`
String, password for rabbitmq

#####`virtual_host`
String, the virtual host to use


#### herqles::database

#####`driver`
String, the python sql driver to use

* postgres
* mysql

#####`host`
String, the SQL host to connect to

#####`port`
Integer, the port to use

#####`database`
String, the SQL database name

#####`username`
String, the SQL username

#####`password`
String, the SQL password

#####`pool_size`
Integer, the SQL pool size

Default: 20


#### herqles::ldap

#####`host`
String, the LDAP server to connect to

#####`domain`
String, the LDAP domain to user

#####`base_dn`
String, the base dn to use when searching for users

#####`bind_username`
String, the LDAP bind username

#####`bind_password`
String, the LDAP bind password


#### herqles::manager::identity

If using a custom driver please use Other and add the driver in the driver_config

#####`driver`
String, the identity driver to use

* LDAP
* SQL (Coming Soon)
* Other

#####`driver_config`
Hash, additional driver configuration

Default: { }


#### herqles::manager::assignment

If using a custom driver please use Other and add the driver in the driver_config

#####`driver`
String, the assignment driver to use

* LDAP
* SQL
* Other

#####`driver_config`
Hash, additional driver configuration

Default: { }

#### herqles::manager

#####`version`
String, the version of the manager to install

Default: present


#### herqles::framework

This class should be defined using Hiera for ease of use

#####`frameworks`
Hash, Herqles frameworks

Example

```yaml
herqles::framework::frameworks:
  my-awesome-framework:
    module: 'my.awesome.framework'
    pkgname: 'my-awesomeframework'
    version: '1.2'
```

#####`version`
String, the version of the framework to install

Default: present


#### herqles::worker

This class should be defined using Hiera for ease of use

#####`workers`
Hash, Herqles workers

See herqles::worker::worker_data defined type

Example

```yaml
herqles::worker::workers:
  my-awesome-worker:
    module: 'hqcodedeployer.worker'
    pkgname: 'my-awesomeworker'
    version: '1.2'
```

#####`version`
String, the version of the worker to install

Default: present

## Defined Types

* herqles::component: Installs and configures Herqles componenets
* herqles::service: Controls Herqles Services
* herqles::worker::worker_data: Holds worker configurations
* herqles::worker::worker: Installs and configures Herqles Workers
* herqles::framework::framework_data: Holds framework configurations
* herqles::framework::framework: Installs and configures Herqles Frameworks

### Parameters

#### herqles::component

#####`pkgname`
String, the python package name

#####`config`
Hash, the component configuration

#####`repo`
URL, the repo to install the python package from

Default: None

#####`version`
String, the version of the python package to install

Default: present

#####`install_args`
List, additional arguments used during install

Default: [ ]


#### herqles::worker::worker_data

#####`module`
String, the worker python module path

#####`pkgname`
String, the worker python package to install

#####`version`
String, the version of the package to install

Default: Present

#####`repo`
String, the repository to install from

Default: None

#####`install_args`
List, optional arguments to install the python package

Default: [ ]


#### herqles::worker::worker

#####`worker_config`
Hash, the configuration for this worker

Default: { }


#### herqles::framework::framework_data

#####`module`
String, the framework python module path

#####`pkgname`
String, the framework python package to install

#####`version`
String, the version of the package to install

Default: present

#####`repo`
String, the repository to install from

Default: None

#####`install_args`
List, optional arguments to install the python package

Default: [ ]


#### herqles::framework::framework

#####`framework_config`
Hash, the configuration for this framework

Default: { }