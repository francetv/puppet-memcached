# == Class: memcached::params
#
class memcached::params {
  case $::osfamily {
    'Debian': {
      $package_name      = 'memcached'
      $package_provider  = undef
      $service_name      = 'memcached'
      $service_hasstatus = false
      $dev_package_name  = 'libmemcached-dev'
      $config_file       = '/etc/memcached.conf'
      $config_tmpl       = "${module_name}/memcached.conf.erb"
      $init_file         = 'memcached-init-debian'
      $user              = 'nobody'
      $logfile           = '/var/log/memcached.log'
      $use_registry      = false
      $use_svcprop       = false
      $ext_tool_enable   = "/usr/sbin/update-rc.d ${service_name} enable"
    }
    /RedHat|Suse/: {
      $package_name      = 'memcached'
      $package_provider  = undef
      $service_name      = 'memcached'
      $service_hasstatus = true
      $dev_package_name  = 'libmemcached-devel'
      $config_file       = '/etc/sysconfig/memcached'
      $config_tmpl       = "${module_name}/memcached_sysconfig.erb"
      $init_file         = 'memcached-init'
      $user              = 'memcached'
      $logfile           = '/var/log/memcached.log'
      $use_registry      = false
      $use_svcprop       = false
      $ext_tool_enable   = "/usr/sbin/chkconfig ${service_name} on"
    }
    /windows/: {
      $package_name      = 'memcached'
      $package_provider  = 'chocolatey'
      $service_name      = 'memcached'
      $service_hasstatus = true
      $dev_package_name  = 'libmemcached-devel'
      $config_file       = undef
      $config_tmpl       = "${module_name}/memcached_windows.erb"
      $init_file         = 'memcached-init-debian'
      $user              = 'BUILTIN\Administrators'
      $logfile           = undef
      $use_registry      = true
      $use_svcprop       = false
      $ext_tool_enable   = undef
    }
    'Solaris': {
      $package_name      = 'memcached'
      $package_provider  = undef
      $service_name      = 'memcached'
      $service_hasstatus = false
      $dev_package_name  = 'libmemcached'
      $config_file       = undef
      $config_tmpl       = "${module_name}/memcached_svcprop.erb"
      $init_file         = 'memcached-init-debian'
      $user              = 'nobody'
      $logfile           = '/var/log/memcached.log'
      $use_registry      = false
      $use_svcprop       = true
      $ext_tool_enable   = undef
    }
    'FreeBSD': {
      $package_name      = 'memcached'
      $package_provider  = undef
      $service_name      = 'memcached'
      $service_hasstatus = false
      $dev_package_name  = 'libmemcached'
      $config_file       = '/etc/rc.conf.d/memcached'
      $config_tmpl       = "${module_name}/memcached_freebsd_rcconf.erb"
      $init_file         = 'memcached-init-debian'
      $user              = 'nobody'
      $logfile           = '/var/log/memcached.log'
      $use_registry      = false
      $use_svcprop       = false
      $ext_tool_enable   = undef
    }
    default: {
      case $::operatingsystem {
        'Amazon': {
          $package_name      = 'memcached'
          $package_provider  = undef
          $service_name      = 'memcached'
          $service_hasstatus = true
          $dev_package_name  = 'libmemcached-devel'
          $config_file       = '/etc/sysconfig/memcached'
          $config_tmpl       = "${module_name}/memcached_sysconfig.erb"
          $user              = 'memcached'
          $logfile           = '/var/log/memcached.log'
          $use_registry      = false
          $use_svcprop       = false
          $ext_tool_enable   = undef
        }
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}