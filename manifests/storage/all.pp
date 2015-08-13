#
# configures all storage types
# on the same node
#
#  [*storage_local_net_ip*] ip address that the swift servers should
#    bind to. Required
#
#  [*devices*] The path where the managed volumes can be found.
#    This assumes that all servers use the same path.
#    Optional. Defaults to /srv/node/
#
#  [*object_port*] Port where object storage server should be hosted.
#    Optional. Defaults to 6000.
#
#  [*allow_versions*] Boolean to enable the versioning in swift container
#    Optional. Default to false.
#
#  [*container_port*] Port where the container storage server should be hosted.
#    Optional. Defaults to 6001.
#
#  [*account_port*] Port where the account storage server should be hosted.
#    Optional. Defaults to 6002.
#
#  [*object_pipeline*]
#    (optional) Specify the object pipeline
#    Defaults to undef
#
# [*incoming_chmod*] Incoming chmod to set in the rsync server.
#   Optional. Defaults to 0644 for maintaining backwards compatibility.
#   *NOTE*: Recommended parameter: 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r'
#   This mask translates to 0755 for directories and 0644 for files.
#
# [*outgoing_chmod*] Outgoing chmod to set in the rsync server.
#   Optional. Defaults to 0644 for maintaining backwards compatibility.
#   *NOTE*: Recommended parameter: 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r'
#   This mask translates to 0755 for directories and 0644 for files.
#
#  [*container_pipeline*]
#    (optional) Specify the container pipeline
#    Defaults to undef
#
#  [*allow_versions*]
#    (optional) Enable/Disable object versioning feature
#    Defaults to false
#
#  [*mount_check*]
#    (optional) Whether or not check if the devices are mounted
#    to prevent accidentally writing to the root device
#    Defaults to false
#
#  [*account_pipeline*]
#    (optional) Specify the account pipeline
#    Defaults to undef
#
#  [*log_facility*]
#    (optional) Syslog log facility
#    Defaults to 'LOG_LOCAL2'
#
#  [*log_level*]
#    (optional) Log level.
#    Defaults to 'INFO'.
#
#  [*log_udp_host*]
#    (optional) If not set, the UDP receiver for syslog is disabled.
#    Defaults to undef.
#
#  [*log_udp_port*]
#    (optional) Port value for UDP receiver, if enabled.
#    Defaults to undef.
#
class swift::storage::all(
  $storage_local_net_ip,
  $devices            = '/srv/node',
  $object_port        = '6000',
  $container_port     = '6001',
  $account_port       = '6002',
  $object_pipeline    = undef,
  $container_pipeline = undef,
  $allow_versions     = false,
  $mount_check        = false,
  $account_pipeline   = undef,
  $log_facility       = 'LOG_LOCAL2',
  $log_level          = 'INFO',
  $log_udp_host       = undef,
  $log_udp_port       = undef,
  $incoming_chmod     = '0644',
  $outgoing_chmod     = '0644',
) {
  if ($incoming_chmod == '0644') {
    warning('The default incoming_chmod set to 0644 may yield in error prone directories and will be changed in a later release.')
  }

  if ($outgoing_chmod == '0644') {
    warning('The default outgoing_chmod set to 0644 may yield in error prone directories and will be changed in a later release.')
  }

  class { '::swift::storage':
    storage_local_net_ip => $storage_local_net_ip,
  }

  Swift::Storage::Server {
    devices              => $devices,
    storage_local_net_ip => $storage_local_net_ip,
    mount_check          => $mount_check,
    log_level            => $log_level,
    log_udp_host         => $log_udp_host,
    log_udp_port         => $log_udp_port,
  }

  swift::storage::server { $account_port:
    type             => 'account',
    config_file_path => 'account-server.conf',
    pipeline         => $account_pipeline,
    log_facility     => $log_facility,
    incoming_chmod   => $incoming_chmod,
    outgoing_chmod   => $outgoing_chmod,
  }

  swift::storage::server { $container_port:
    type             => 'container',
    config_file_path => 'container-server.conf',
    pipeline         => $container_pipeline,
    log_facility     => $log_facility,
    allow_versions   => $allow_versions,
    incoming_chmod   => $incoming_chmod,
    outgoing_chmod   => $outgoing_chmod,
  }

  swift::storage::server { $object_port:
    type             => 'object',
    config_file_path => 'object-server.conf',
    pipeline         => $object_pipeline,
    log_facility     => $log_facility,
    incoming_chmod   => $incoming_chmod,
    outgoing_chmod   => $outgoing_chmod,
  }
}
