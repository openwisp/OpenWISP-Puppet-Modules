define rails($app_name, $release, $repo, $repo_user = "", $repo_pass = "", $path, $adapter, $db, $pool_size, $db_user, $db_password) {
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

  exec { "${app_name} initial export":
    command => "svn export --no-auth-cache --username \"${repo_user}\" --password \"${repo_pass}\" ${repo}/tags/${release} ${app_path}/releases/initial",
    require => File["${app_path}/releases"],
    unless => "test -d ${app_path}/releases/initial"
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

  file { "${app_path}/current":
    ensure => symlink,
    target => "${app_path}/releases/initial",
    require => [ File["${app_path}/releases"], Exec["${app_name} initial export"] ]
  }

  file { "/var/www/${app_name}":
    ensure => symlink,
    target => "${app_path}/current/public"
  }

  exec { "${app_name} bundle":
    command => "bundle install --deployment",
    cwd => "${app_path}/current",
    environment => ["RAILS_ENV=production"],
    unless => "bundle",
    require => [ File["${app_path}/current"], Rvm_gem["bundler"] ]
  }

  mysql::db { "${app_name} db": db_name => $db, user => $db_user, password => $db_password }

  exec { "${app_name} db migrate":
    command => "rake db:migrate",
    cwd => "${app_path}/current",
    unless => "rake db:migrate:status | grep up",
    environment => ["RAILS_ENV=production"],
    require => [ Mysql::Db["${app_name} db"], File["${app_path}/current/config/database.yml"], Exec["${app_name} bundle"] ]
  }
}
