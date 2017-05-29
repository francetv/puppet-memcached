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
    content => template('memcached/memcached.conf.erb'),
    require => File['/etc/init.d/memcached'],
    notify  => Service['memcached'],
  }

  if $::operatingsystemrelease =~ /^8/ {
    $systemd_setting = {
      'Unit' => {
        'Description'   => 'memcached daemon',
        'After'         => 'network.target',
      },
      'Service' => {
        'ExecStart'   => "/usr/share/memcached/scripts/systemd-memcached-wrapper /etc/memcached_${name}.conf",
      },
      'Install' => {
        'WantedBy'   => 'multi-user.target',
      }
    }
    $defaults = { 'path' => "/lib/systemd/system/memcached_${name}.service" }
    create_ini_settings($systemd_setting,  $defaults)
    exec { "Enable memcached_${name}" :
      command => "/bin/systemctl enable memcached_${name}",
      require => Ftven::Tools::Memcached::Systemd["memcached_${name}"],
      notify  => Service["memcached_${name}"],
    }
    service { "memcached_${name}":
      ensure      => running,
      enable      => true,
      hasstatus   => false,
      status      => "/usr/bin/pgrep memcached_${name}",
      require     => [ Package['memcached'], User['memcached'] ],
    }
  }
}
