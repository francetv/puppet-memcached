class memcached(
  $service_ensure = 'running',
  $service_manage = true
) {
  if $::osfamily == 'RedHat' {
    include epel
    include remi
    package { 'memcached':
      ensure  => installed,
      require => Class['remi'],
    }
  }
  else {
    package { 'memcached':
      ensure  => installed,
    }
  }

  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      file { '/etc/init.d/memcached':
        ensure  => present,
        source  => 'puppet:///modules/memcached/memcached-init-debian',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        alias   => 'memcached-init',
        notify  => Service['memcached'],
        require     => [
          Package['memcached'],
          File['/usr/bin/start-memcached'],
          File['/etc/memcached.conf'],
        ]
      }

      exec { '/etc/init.d/memcached':
        command => '/usr/sbin/update-rc.d memcached enable',
        require => File['/etc/init.d/memcached'],
      }
    }
    default: {
      file { '/etc/init.d/memcached':
        ensure  => present,
        source  => 'puppet:///modules/memcached/memcached-init',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        alias   => 'memcached-init',
        require => Package['memcached'],
        notify  => Service['memcached'],
        require     => [
          Package['memcached'],
          File['/usr/bin/start-memcached'],
          File['/etc/memcached.conf'],
          User['memcached'],
        ]
      }

      exec { '/etc/init.d/memcached':
        command => '/usr/sbin/chkconfig memcached on',
        require => File['/etc/init.d/memcached'],
      }
    }
  }

  file { '/usr/bin/start-memcached':
    ensure  => present,
    source  => 'puppet:///modules/memcached/start-memcached',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    alias   => 'memcached-bin',
    require => Package['memcached'],
  }

  file { '/etc/memcached.conf':
    ensure  => present,
    source  => 'puppet:///modules/memcached/memcached.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'memcached-conf',
    require => Package['memcached'],
  }

  user { 'memcached':
    ensure => present,
    system => true,
  }

  if ($service_manage) {
    if $service_ensure == 'running' {
      $ensure_real = 'running'
      $enable_real = true
    } else {
      $ensure_real = 'stopped'
      $enable_real = false
    }
    service { 'memcached':
      ensure     => $ensure_real,
      enable     => $enable_real,
      hasstatus   => false,
      status      => '/usr/bin/pgrep memcached',
      require     => [ Package['memcached'], User['memcached'] ],
    }
  }
}
