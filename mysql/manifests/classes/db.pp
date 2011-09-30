class mysql::db($db_name, $user, $password) {
  exec { "create-${db_name}-db":
    unless => "/usr/bin/mysql -u${user} -p${password} ${db_name}",
    command => "/usr/bin/mysql -uroot -p$mysql_password -e \"create database ${db_name}; grant all on ${db_name}.* to ${user}@localhost identified by '$password';\"",
    require => Service["mysql"]
  }
}
