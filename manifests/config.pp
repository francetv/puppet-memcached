define memcached::config(
  $port           = 11211,     # Port number to listen on
  $memory         = 64,        # Maximum amount of memory to use
  $listen         = false,     # The IP address to listen on, defaults to all
  $connections    = 1024,      # Limit the number of simultaneous incoming connections
  $items_size     = '1m',      # Max items size
  $dir_log        = undef,     # Logs's irectory
) {

  if $dir_log {
    $dir_log_real = $dir_log

    file { $dir_log_real :
      ensure          => directory,
      owner           => 'root',
      group           => 'adm',
    }
  } else {
    $dir_log_real = '/var/log'
  }

  file { "/etc/memcached_${name}.conf":
    content => template($memcached::params::config_tmpl),
    require => File['/etc/init.d/memcached'],
    notify  => Service["memcached_${name}"],
  }

  if $::service_provider == 'systemd'{
    memcached::systemd{ $name: }
    exec { "Reload systemd" :
      command => '/bin/systemctl daemon-reload',
      before => Exec["Enable memcached systemd"]
    }
    exec { "Enable memcached_${name} systemd" :
      command => '/bin/systemctl enable memcached_${name}',
      onlyif  => "/bin/systemctl is-enabled memcached | /bin/grep 'disabled'",
      require => Memcached::Systemd["${name}"],
      before  => Service["memcached_${name}"],
    }
  }

  service { "memcached_${name}":
    ensure      => running,
    enable      => true,
    hasstatus   => false,
    status      => $::operatingsystemrelease ? {
      /^(8|9)/    => "/usr/bin/pgrep memcached_${name}",
      default => "/usr/bin/pgrep memcached",
    },
    require     => [ Package['memcached'], User['memcached'] ],
  }
}
