define memcached::systemd {
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
  create_ini_settings($systemd_setting, $defaults)
}
