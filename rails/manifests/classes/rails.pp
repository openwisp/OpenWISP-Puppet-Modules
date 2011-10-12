class rails($path, $adapter, $db, $pool_size, $db_user, $db_password) {
  file { [ "${path}", "${path}/shared", "${path}/shared/config" ]:
    ensure => directory, recurse => true,
    mode => 0644, owner => root, group => root;
  }

  file { "${path}/shared/config/database.yml":
    ensure => file,
    content => template('rails/database.yml.erb'),
    mode => 0644, owner => root, group => root;
  }

  class { mysql::db: db_name => $db, user => $db_user, password => $db_password }
}
