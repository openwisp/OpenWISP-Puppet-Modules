class owums($path = '/var/rails', $db_password, $pool_size = '10') {
  package { "dependencies":
    name => ["libmagickwand-dev", "lame", "festival", "festvox-italp16k", "festvox-rablpc16k", "librsvg2-bin"],
    ensure => installed
  }

  class { rails:
      app_name => $name,
      path => $path,
      adapter => 'mysql',
      db => $name,
      pool_size => $pool_size,
      db_user => $name,
      db_password => $db_password
  }

  file { "init_script":
    path =>"/etc/init.d/${name}-daemons",
    ensure => file, 
    content => template('rails/init_script.erb'),
    mode => 0751, owner => root, group => root;
  }

  service { "${name}-daemons":
    enable => true,
    ensure => running,
    require => [ Package["dependencies"], File["init_script"] ]
  }
}
