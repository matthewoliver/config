# == Class: turbo-hipster
#
class turbo_hipster (
  $th_repo = 'https://git.openstack.org/stackforge/turbo-hipster',
  $th_repo_destination = '/opt/turbo-hipster',
  $th_repo_branch = "master",
  $th_dataset_path = "/var/lib/turbo-hipster/",
  $th_local_dataset_path = "/etc/ansible/roles/turbo-hipster/datasets/",
  $th_user = "th",
  $zuul_server = "",
  $zuul_port = 1234,
  $database_engine = "mysql",
  $pypi_mirror = "http://pypi.python.org",
) {

  include pip
  
  user { "$th_user":
    ensure     => present,
    home       => "/home/$th_user",
    shell      => '/bin/bash',
    gid        => $th_user,
    managehome => true,
    require    => Group[$th_user],
  }

  group { "$th_user":
    ensure => present,
  }

  vcsrepo { "$th_repo_destination":
    ensure   => latest,
    provider => git,
    revision => $th_repo_branch,
    source   => $th_repo,
  }

  define pip_conf {
    file { "${title}/.pip":
      ensure  => directory,
      mode    => '0755',
    }

    file { "${title}/.pip/pip.conf":
      ensure  => present,
      mode    => '0644',
      require => File['/etc/turbo-hipster'],
      content => template('turbo_hipster/pip.conf.erb'),
    }
  }

  pip_conf {  ['/root/', "/home/$th_user/"]:
    require => User["$th_user"], 
  }

  file { '/var/cache/pip':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  exec { 'install_th_dependencies' :
    command     => "pip install $th_repo_destination",
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
    source  => 'puppet:///modules/turbo_hipster/start_turbo-hipster.sh',
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    require => File['/etc/turbo-hipster'],
  }

# This config in the future will need to be split config.json and config.json.d/ so each plugin can contain place each piece of their configuration. 
  file { '/etc/turbo-hipster/config.json':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => File['/etc/turbo-hipster'],
    content => template('turbo_hipster/config.json.erb'),
  }

  file { '/etc/init.d/turbo-hipster':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('turbo_hipster/init_turbo-hipster.erb'),
  }

  file { '/var/log/turbo-hipster':
    ensure => directory,
    mode   => '0755',
    owner  => $th_user,
    group  => $th_user,
  }

  file { '/var/lib/turbo-hipster':
    ensure  => directory,
    mode    => '0755',
    owner   => $th_user,
    group   => $th_user,
    require => User[$th_user],
  }

  file { '/var/lib/turbo-hipster/git':
    ensure  => directory,
    mode    => '0755',
    owner   => $th_user,
    group   => $th_user,
    require => File['/var/lib/turbo-hipster'],
  }

  file { '/var/lib/turbo-hipster/jobs':
    ensure  => directory,
    mode    => '0755',
    owner   => $th_user,
    group   => $th_user,
    require => File['/var/lib/turbo-hipster'],
  }

  exec { 'install_turbo-hipster':
    command   => "python setup.py install",
    cwd       => "$th_repo_destination",
    path      => '/usr/local/bin:/usr/bin:/bin/',
    subscribe => Vcsrepo[$th_repo_destination],
    require   => Exec['install_th_dependencies'],
  }

  exec { 'start_turbo-hipster':
    command   => '/etc/turbo-hipster/start_turbo-hipster.sh',
    path      => '/usr/local/bin:/usr/bin:/bin/',
    subscribe => Vcsrepo[$th_repo_destination],
    require   => [
      File['/etc/turbo-hipster/start_turbo-hipster.sh'],
      File['/var/log/turbo-hipster'],
    ],
  }

  cron { 'Start Turbo-Hipster at boot':
    command => '/etc/turbo-hipster/start_turbo-hipster.sh',
    user    => 'root',
    special => 'reboot',
    require => File['/etc/turbo-hipster/start_turbo-hipster.sh'], 
  }

}
