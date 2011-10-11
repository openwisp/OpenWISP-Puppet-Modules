class rails($path, $adapter, $db, $pool_size, $db_user, $db_password) {
  file { "${$path}/shared/database.yml":
    ensure => file, recurse => true,
    content => template('rails/database.yml.erb'),
    mode => 0640, owner => root, group => root;
  }

  class { mysql::db: db_name => $db, user => $db_user, password => $db_password }
}
