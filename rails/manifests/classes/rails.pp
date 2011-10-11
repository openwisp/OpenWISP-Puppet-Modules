class rails($path, $adapter, $db, $pool_size, $db_user, $db_password) {
  file { "${$path}/shared/config":
    ensure => directory, recurse => true,
    content => template('rails/database.yml.erb'),
    mode => 0640, owner => root, group => root;
  }

  file { "${$path}/shared/config/database.yml":
    ensure => file,
    content => template('rails/database.yml.erb'),
    mode => 0640, owner => root, group => root;
  }

  class { mysql::db: db_name => $db, user => $db_user, password => $db_password }
}
