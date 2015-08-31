# Class: xinetd
#
# This module manages xinetd
#
# Sample Usage:
#   xinetd::service {"rsync":
#       port        => "873",
#       server      => "/usr/bin/rsync",
#       server_args => "--daemon --config /etc/rsync.conf",
#  }
#
class xinetd (
  $logger = 'info',
  $ensure = present
) inherits xinetd::params {
  # validate parameters
  validate_re($logger, '^(emerg|alert|crit|err|warning|notice|info|debug)$')
  validate_re($ensure, '^(present|absent)$')

  # package management
  package {
    $package_name :
      ensure => $ensure ;
  }

  case $ensure {
    present : {
      # create configuration and directories
      file {
        $cfgddir :
          ensure => directory,
          mode => '0755',
          purge => true,
          force => true,
          recurse => true ;

        $cfgfile :
          content => template('xinetd/xinetd.conf.erb') ;
      }

      # define service
      service {
        $service_name :
          ensure => running,
          enable => true,
          require => [Package[$package_name], File[$cfgfile]],
          restart => "/sbin/service ${service_name} reload",
      }

      # realize all defined xinetd services
      Xinetd::Service <||>
    }

    absent : {
      # remove configuration and directories
      file {
        [$cfgddir, $cfgfile] :
          ensure => absent,
          recurse => true,
          force => true,
          require => Package[$package_name] ;
      }
    }
  }
}
