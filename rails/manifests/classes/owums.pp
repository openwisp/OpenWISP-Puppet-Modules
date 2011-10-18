class owums($path = '/var/rails', $db_password, $pool_size = '10', capistrano_enabled = true) {
  package { "${name} dependencies":
    name => ["libmagickwand-dev", "lame", "festival", "festvox-italp16k", "festvox-rablpc16k", "librsvg2-bin"],
    ensure => installed
  }

  rails { "${name} app":
      app_name => $name,
      path => $path,
      adapter => 'mysql',
      db => $name,
      pool_size => $pool_size,
      db_user => $name,
      db_password => $db_password
  }

  file { "${name} init script":
    path =>"/etc/init.d/${name}-daemons",
    ensure => file, 
    content => template('rails/init_script.erb'),
    mode => 0751, owner => root, group => root;
  }

  service { "${name}-daemons":
    enable => true,
    ensure => running,
    require => [ Package["${name} dependencies"], File["${name} init script"] ]
  }
}
