define rails($app_name, $release, $repo, $repo_type,  $repo_user = "", $repo_pass = "", $path, $adapter, $db, $pool_size, $db_user, $db_password) {
  $app_path = "${path}/${app_name}"

  if !defined(Package["rails pkg dependencies"]) {
    package{ "rails pkg dependencies":
      name => ["subversion", "git-core"],
      ensure => installed
    }
  }

  if !defined(File[$path]) {
    file { $path:
      ensure => directory, recurse => false,
      mode => 0644, owner => root, group => root;
    }
  }

  file { [ "${app_path}", "${app_path}/shared", "${app_path}/shared/config", "${app_path}/releases" ]:
    ensure => directory, recurse => false,
    mode => 0644, owner => root, group => root,
    require => File[$path]
  }

  file { [ "${app_path}/shared/log" ]:
    ensure => directory, recurse => false, 
    mode => 0664, owner => root, group => www-data,
    require => File[$app_path]
  }

  file { [ "${app_path}/shared/log/production.log" ]:
    mode => 0664, owner => root, group => www-data,
    require => File["${app_path}/shared/log"]
  }

  if $repo_type == "svn" {
    exec { "${app_name} initial export":
      command => "svn export --no-auth-cache --username \"${repo_user}\" --password \"${repo_pass}\" ${repo}/tags/${release} ${app_path}/releases/${release}",
      require => File["${app_path}/releases"],
      unless => "test -d ${app_path}/releases/${release}",
      notify => Exec["reload-apache2"]
    }
  } elsif $repo_type == "git" {
    exec { "${app_name} initial export":
      command => "git clone ${repo} ${app_path}/releases/${release} && cd ${app_path}/releases/${release} && git checkout ${release} && rm -rf .git",
      require => File["${app_path}/releases"],
      unless => "test -d ${app_path}/releases/${release}",
      notify => Exec["reload-apache2"]
    }
  }

  file { "${app_path}/shared/config/database.yml":
    ensure => file,
    content => template('rails/database.yml.erb'),
    mode => 0644, owner => root, group => root;
  }

  file { "${app_path}/current/config/database.yml":
    ensure => symlink,
    target => "${app_path}/shared/config/database.yml",
    require => [ Exec["${app_name} initial export"], File["${app_path}/shared/config/database.yml"] ]
  }

  exec { "${app_name} clean logs":
    command => "rm -rf ${app_path}/releases/${release}/log",
    unless => "test -L ${app_path}/current/log",
    require => [ Exec["${app_name} initial export"] ]
  }

  file { "${app_path}/current/log":
    ensure => symlink,
    target => "${app_path}/shared/log",
    require => [ Exec["${app_name} initial export"], Exec["${app_name} clean logs"] ]
  }

  file { [ "${app_path}/current/tmp/cache", "${app_path}/current/tmp/pids", "${app_path}/current/tmp/sessions", "${app_path}/current/tmp/sockets" ]:
    ensure  => directory, recurse  => false,
    mode    =>  0644, owner => root, group => root,
    require => File[$app_path]
  }

  file { "${app_path}/current":
    ensure => symlink,
    target => "${app_path}/releases/${release}",
    require => [ File["${app_path}/releases"], Exec["${app_name} initial export"] ],
    notify => Exec["reload-apache2"]
  }

  file { "/var/www/${app_name}":
    ensure => symlink,
    target => "${app_path}/current/public",
    notify => Exec["reload-apache2"]
  }

  mysql::db { "${app_name} db": db_name => $db, user => $db_user, password => $db_password }
  
  if $rvm_installed == "true" {
    exec { "${app_name} bundle":
      command => "bundle install --deployment",
      cwd => "${app_path}/current",
      environment => ["RAILS_ENV=production"],
      unless => "bundle check",
      require => [ File["${app_path}/current"], Rvm_gem["bundler"] ]
    }

    exec { "${app_name} db migrate":
      command => "bundle exec rake db:migrate",
      cwd => "${app_path}/current",
      unless => "bundle exec rake db:migrate:status | grep up",
      environment => ["RAILS_ENV=production"],
      require => [ Mysql::Db["${app_name} db"], File["${app_path}/current/config/database.yml"], Exec["${app_name} bundle"] ]
    }
  }

}
