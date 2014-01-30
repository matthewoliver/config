# == Class: turbo-hipster
#
class 'turbo-hipster' (
  $th_repo = 'https://git.openstack.org/stackforge/turbo-hipster',
  $th_repo_destination = '/opt/turbo-hipster',
  $th_repo_branch = "master",
  $th_dataset_path = "/var/lib/turbo-hipster/",
  $th_local_dataset_path = "/etc/ansible/roles/turbo-hipster/datasets/",
  $th_user = "th",
  $th_test_user = "nova",
  $th_test_pass = "tester",
  $th_test_host = "%",
  $th_databases = [],
  $zuul_server = "",
  $zuul_port = 1234,
  $database_engine_package = "mysql-server",
  $database_engine = "mysql",
  $database_engine_bind = '0.0.0.0',
  $database_engine_port = '3306',
  $mysql_root_password,
) {

  class { 'mysql::server':
    package_name = $database_engine_package,
    config_hash => {
      'root_password'  => $mysql_root_password,
      'default_engine' => 'InnoDB',
      'bind_address'   => $database_engine_bind,
      'port'           => $database_engine_port,
    }
  }

  include mysql::python
  include pip

  # define th_database so we can use an array to define all TH databases. 
  define th_database {
    mysql::db { "${title}":
      user     => $th_test_user,
      password => $th_test_pass,
      host     => $th_test_host,
      grant    => ['all'],
      charset  => 'utf8',
      require  => [
        Class['mysql::server'],
      ],
    }
  }
  th_database { $th_databases: }
  
  user { $th_user:
    ensure     => present,
    home       => '/home/$th_user',
    shell      => '/bin/bash',
    gid        => $th_user,
    managehome => true,
    require    => Group[$th_user],
  }

  group { $th_user:
    ensure => present,
  }

  vcsrepo { $th_repo_destination:
    ensure   => latest,
    provider => git,
    revision => $th_repo_branch,
    source   => $th_repo,
  }

  file { '/var/cache/pip':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  exec { 'install_th_dependencies' :
    command     => 'pip install $th_repo_destination',
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Vcsrepo[$th_repo_destination],
    require     => [ 
      Class['pip'],
      File['/var/cache/pip'],
    ],
  }

  file { '/etc/turbo-hipster':
    ensure => directory,
  }

  file { '/etc/turbo-hipster/start_turbo-hipster.sh':
    ensure => present,
    source  => 'puppet:///modules/turbo-hipster/makenetnamespace.sh',
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    require => File['/etc/turbo-hipster'],
  }

  file { '/etc/turbo-hipster/config.json':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => File['/etc/turbo-hipster'],
    content => template('turbo-hipster/config.json.erb'),
  }

  file { '/var/log/turbo-hipster':
    ensure => directory,
    mode   => '0755',
    owner  => $th_user,
    group  => $th_user,
  }

  file { '$th_local_dataset_path/git':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
#    require => ,
  }

  file { '$th_local_dataset_path/jobs':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
#    require => ,
  }

  exec { 'install_turbo-hipster':
    command  => 'python $th_repo_destination/setup.py install',
    path      => '/usr/local/bin:/usr/bin:/bin/',
    refeshonly => true,
    suscribe   => Vcsrepo[$th_repo_destination],
    require    => Exec['install_th_dependencies'],
  }

  exec { 'start_turbo-hipster':
    command   => '/etc/turbo-hipster/start_turbo-hipster.sh',
    path      => '/usr/local/bin:/usr/bin:/bin/',
    refeshonly => true,
    suscribe   => Vcsrepo[$th_repo_destination],
    require   => [ 
      File['/etc/turbo-hipster/start_turbo-hipster.sh'],
      File['/var/log/turbo-hipster'],
    ],
  }

}
