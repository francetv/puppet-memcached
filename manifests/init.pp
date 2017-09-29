class memcached(
  $service_manage = true,
  $service_restart = true,
) {

  if $package_ensure == 'absent' {
    $service_ensure = 'stopped'
    $service_enable = false
  } else {
    $service_ensure = 'running'
    $service_enable = true
  }

  package { $memcached::params::package_name:
    ensure   => $package_ensure,
    provider => $memcached::params::package_provider,
  }

  if $service_restart and $service_manage {
    $service_notify_real = Service[$memcached::params::service_name]
  } else {
    $service_notify_real = undef
  }
  if $service_manage {
    service { $memcached::params::service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasrestart => true,
      hasstatus  => $memcached::params::service_hasstatus,
      status      => '/usr/bin/pgrep memcached',
      require     => [ Package['memcached'], User['memcached'] ],
    }
  }

  file { '/etc/init.d/memcached':
    ensure  => present,
    source  => "puppet:///modules/memcached/${memcached::params::service_name}",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    alias   => 'memcached-init',
    notify  => $service_notify_real,,
    require => [
      Package[$memcached::params::package_name],
      File['/usr/bin/start-memcached'],
      File[$memcached::params::config_file],
      User['memcached'],
    ]
  }
  exec { '/etc/init.d/memcached':
    command => $memcached::params::ext_tool_enable,
    require => File['/etc/init.d/memcached'],
  }

  file { '/usr/bin/start-memcached':
    ensure  => present,
    source  => 'puppet:///modules/memcached/start-memcached',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    alias   => 'memcached-bin',
    require => Package[$memcached::params::package_name],
  }

  file { $memcached::params::config_file :
    ensure  => present,
    source  => 'puppet:///modules/memcached/memcached.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'memcached-conf',
    require => Package[$memcached::params::package_name],
  }

  user { 'memcached':
    ensure => present,
    system => true,
  }
}
