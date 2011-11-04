class owgm($repo, $release, $path = '/var/rails', $db_password, $pool_size = '10') {
  rails { "${name} app":
      app_name => $name,
      repo => $repo,
      release => $release,
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
    require => [ File["${name} init script"], Rails["${name} app"] ]
  }

  exec { "${name} db seed":
    command => "rake db:seed && touch .seeds_run_by_puppet",
    cwd => "${path}/${name}/current",
    unless => "test -f ${path}/${name}/current/.seeds_run_by_puppet",
    environment => ["RAILS_ENV=production"],
    require => [ Rails["${name} app"] ]
  }
}
