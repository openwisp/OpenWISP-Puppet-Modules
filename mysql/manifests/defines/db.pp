define mysql::db($db_name, $user, $password) {
  exec { "create-${db_name}-db":
    unless => "/usr/bin/mysql -u${user} -p${password} -e \"use ${db_name};\"",
    command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"create database if not exists ${db_name}; grant all on ${db_name}.* to ${user}@localhost identified by '${password}';\"",
    require => Service["mysql"]
  }
}
