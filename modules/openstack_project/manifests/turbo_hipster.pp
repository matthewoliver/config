# == Class: openstack_project::turbo_hipster
#
class openstack_project::turbo_hipster (
  $th_repo = 'https://git.openstack.org/stackforge/turbo-hipster',
  $th_repo_destination = '/home/th/turbo-hipster',
  $th_dataset_path = "/var/lib/turbo-hipster/",
  $th_local_dataset_path = "/etc/ansible/roles/turbo-hipster/datasets/",
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
  $zuul_server = "",
  $zuul_port = 1234,
  $database_engine_package = "mysql-server",
  $database_engine_package = "mysql",
  $mysql_root_password = "master",
) {
  include openstack_project

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => $sysadmins,
  }

  class { '::turbo_hipster':
    $th_repo = 'https://git.openstack.org/stackforge/turbo-hipster',
    $th_repo_destination = '/home/turbo-hipster/turbo-hipster',
    $th_dataset_path = "/var/lib/turbo-hipster/",
    $th_local_dataset_path = "/etc/ansible/roles/turbo-hipster/datasets/",
    $th_user = "turbo-hipster",
    $th_lxc_dir = "/var/lib/lxc",
    $th_test_user = "nova",
    $th_test_pass = "tester",
    $th_test_host = "%",
    $zuul_server = "",
    $zuul_port = 1234,
    $database_engine = "mysql"
  }
}
