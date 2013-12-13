class memcached {
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

    file { '/etc/init.d/memcached':
        ensure  => present,
        source  => 'puppet:///modules/memcached/memcached-init',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        alias   => 'memcached-init',
        require => Package['memcached'],
    }

    file { '/usr/bin/start-memcached':
        ensure => present,
        source => 'puppet:///modules/memcached/start-memcached',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        alias  => 'memcached-bin',
    }

    # todo: can be removed? Do we need this? Should just be using memcached_*.conf.
    file { '/etc/memcached.conf':
        ensure => present,
        source => 'puppet:///modules/memcached/memcached.conf',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        alias  => 'memcached-conf',
    }

    user { 'memcached':
        ensure => present,
        system => true,
    }

    service { 'memcached':
        ensure      => running,
        enable      => true,
        hasstatus   => false,
        status      => '/usr/bin/pgrep memcached',
        require     => [
            Package['memcached'],
            File['memcached-init'],
            File['memcached-bin'],
            File['memcached-conf'],
            User['memcached'],
        ]
    }
}
