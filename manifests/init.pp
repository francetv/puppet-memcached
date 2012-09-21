class memcached() {
    # use memcache from rpmforge-extras repo
    class { "rpmforge":
        testing => 1
    }

    package { "memcached":
        ensure  => installed,
        require => Class['rpmforge'],
    }
    
    file { "/etc/init.d/memcached":
        ensure => present,
        source => "puppet:///modules/memcached/memcached-init",
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        alias  => 'memcached-init',
    }
    
    file { "/usr/bin/start-memcached":
        ensure => present,
        source => "puppet:///modules/memcached/start-memcached",
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        alias  => 'memcached-bin',
    }
    
    service { "memcached":
        ensure   => running,
        enable   => true,
        require  => [
            Package['memcached'],
            File["memcached-init"],
            File["memcached-bin"],
        ]
    }
}
