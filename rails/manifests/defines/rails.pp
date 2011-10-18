define rails($app_name, $path, $adapter, $db, $pool_size, $db_user, $db_password) {
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

  file { [ "${app_path}", "${app_path}/shared", "${app_path}/shared/config" ]:
    ensure => directory, recurse => false,
    mode => 0644, owner => root, group => root,
    require => File[$path]
  }

  file { "${app_path}/shared/config/database.yml":
    ensure => file,
    content => template('rails/database.yml.erb'),
    mode => 0644, owner => root, group => root;
  }

  file { "/var/www/${app_name}":
    ensure => symlink,
    target => "${app_path}/current/public"
  }

  mysql::db { "${app_name} db": db_name => $db, user => $db_user, password => $db_password }
}
