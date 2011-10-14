class rails($app_name, $path, $adapter, $db, $pool_size, $db_user, $db_password) {
  package { "subversion": ensure => installed }
  package { "git-core": ensure => installed }

  $app_path = "${path}/${app_name}"

  file { [ "${path}", "${app_path}", "${app_path}/shared", "${app_path}/shared/config" ]:
    ensure => directory, recurse => true,
    mode => 0644, owner => root, group => root;
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

  class { mysql::db: db_name => $db, user => $db_user, password => $db_password }
}
