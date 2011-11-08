define mysql::user($password, $grant) {
  exec { "create-user-${name}":
    unless => "/usr/bin/mysql -u${name} -p${password}",
    command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"grant ${grant} to ${name}@localhost identified by '${password}';\"",
    require => Service["mysql"]
  }
}
