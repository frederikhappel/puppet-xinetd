# Define: xinetd::service
#
# sets up a xinetd service
# all parameters match up with xinetd.conf(5) man page
#
# Parameters:
#   $cps         - optional
#   $flags       - optional
#   $per_source  - optional
#   $port        - required - determines the service port
#   $server      - required - determines the program to execute for this service
#   $server_args - optional
#   $disable     - optional - defaults to "no"
#   $socket_type - optional - defaults to "stream"
#   $protocol    - optional - defaults to "tcp"
#   $user        - optional - defaults to "root"
#   $group       - optional - defaults to "root"
#   $instances   - optional - defaults to "UNLIMITED"
#   $wait        - optional - based on $protocol will default to "yes" for udp and "no" for tcp
#
# Actions:
#   setups up a xinetd service by creating a file in /etc/xinetd.d/
#
# Requires:
#   $server must be set
#
# Sample Usage:
#   # setup tftp service
#   xinetd::service {"tftp":
#       port        => "69",
#       server      => "/usr/sbin/in.tftpd",
#       server_args => "-s $base",
#       socket_type => "dgram",
#       protocol    => "udp",
#       cps         => "100 2",
#       flags       => "IPv4",
#       per_source  => "11",
#   } # xinetd::service
#
define xinetd::service (
  $cps = undef,
  $flags = undef,
  $per_source = undef,
  $port = undef,
  $server,
  $server_args = undef,
  $disabled = false,
  $socket_type = 'stream',
  $protocol = 'tcp',
  $user = 'root',
  $group = 'root',
  $instances = 'UNLIMITED',
  $log_on_failure = undef,
  $log_on_success = undef,
  $wait = undef,
  $ensure = present
) {
  # validate parameters
  validate_string(
    $cps, $flags, $user, $group, $instances, $per_source,
    $log_on_failure, $log_on_success,
  )
  if ($port != undef) {
    validate_ip_port($port)
  }
  validate_absolute_path($server)
  validate_bool($disabled)
  if ($wait != undef) {
    validate_bool($wait)
  }
  validate_re($socket_type, '^(stream|dgram|raw|seqpacket)$')
  validate_re($protocol, '^(udp|tcp)$')
  validate_re($ensure, '^(present|absent)$')

  # define variables
  $cfgfile = "${xinetd::params::cfgddir}/${name}"

  if $wait != undef {
    $mywait = $wait
  } else {
    $mywait = $protocol ? {
      udp => true,
      default => false
    }
  }

  # create service configuration
  file {
    $cfgfile :
      ensure => $ensure,
      content => template('xinetd/service.erb'),
      notify => Service[$xinetd::params::service_name] ;
  }
}
