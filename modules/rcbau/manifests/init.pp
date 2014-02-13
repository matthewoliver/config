# == Class: rcbau
#
class rcbau (    
  root_ssh_public_key = "",
  enable_root_login = true,
) {

  include ssh
  
  file { "/root/.ssh":
    ensure  => directory,
    mode    => '0500',
    owner   => 'root',
    group   => 'root',
  }

  file { "/root/.ssh/authorized_keys2":
    ensure  => present,
    content => $root_ssh_public_key,
    mode    => '0400',
    owner   => 'root',
    group   => 'root',
    require => File["/root/.ssh"],
  }
  
  exec { 'enable_root_ssh_login':
    command   => "sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config",
    path      => '/usr/local/bin:/usr/bin:/bin/',
    onlyif    => '[ $(grep -c \'PermitRootLogin no\' /etc/ssh/sshd_config) -gt 0 ]',
    subscribe => Service['ssh'],
    require   => File['/etc/ssh/sshd_config'],
  }
  
}
