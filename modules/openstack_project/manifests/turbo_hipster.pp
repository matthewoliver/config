# == Class: openstack_project::turbo_hipster
#
class openstack_project::turbo_hipster (
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
) {
  include openstack_project

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => $sysadmins,
  }
}
