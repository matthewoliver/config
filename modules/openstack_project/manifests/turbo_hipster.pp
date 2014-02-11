# == Class: openstack_project::turbo_hipster
#
class openstack_project::turbo_hipster (
  $th_repo = 'https://git.openstack.org/stackforge/turbo-hipster',
  $th_repo_destination = '/home/th/turbo-hipster',
  $th_dataset_path = "/var/lib/turbo-hipster/",
  $th_local_dataset_path = "/etc/ansible/roles/turbo-hipster/datasets/",
  $th_user = "th",
  $th_test_user = "nova",
  $th_test_pass = "tester",
  $th_test_host = "%",
  $th_databases = [
    "nova_dataset_20130910_devstack_applied_to_150",
    "nova_dataset_20131007_devstack",
    "nova_dataset_trivial_500",
    "nova_dataset_trivial_6000",
    "nova_datasets_user_001",
    "nova_dataset_user_002",   
  ],
  $zuul_server = "1.2.3.4",
  $zuul_port = 1234,
  $database_engine_package = "mysql-server",
  $database_engine = "mysql",
  $mysql_root_password = "master",
  $pypi_mirror = "http://pypi.python.org",
  $ssh_private_key = "",
  $dataset_host =  "",
  $dataset_path = "",
  $dataset_user = "",
) {
  include openstack_project

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => $sysadmins,
  }

  class { '::turbo_hipster':
    th_repo                  => $th_repo,
    th_repo_destination      => $th_repo_destination,
    th_dataset_path          => $th_dataset_path,
    th_local_dataset_path    => "/etc/ansible/roles/turbo-hipster/datasets/",
    th_user                  => $th_user,
    zuul_server              => $zuul_server,
    zuul_port                => $zuul_port,
    database_engine          => $database_engine,
    pypi_mirror              => $pypi_mirror,
    ssh_private_key          => $ssh_private_key,
    dataset_host             => $dataset_host,
    dataset_path             => $dataset_path,
    dataset_user             => $dataset_user,
  }

  class { '::turbo_hipster::db_migration':
    th_dataset_path         => $th_dataset_path,
    th_test_user            => $th_test_user,
    th_test_pass            => $th_test_pass,
    th_test_host            => $th_test_host,
    th_databases            => $th_databases,
    database_engine         => $database_engine,
    database_engine_package => $database_engine_package,
    mysql_root_password     => $mysql_root_password,
  }
}
