define mysql::user($user, $password, $grant) {
  exec { "create-${user}":
    unless => "/usr/bin/mysql -u${user} -p${password}",
    command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"grant ${grant} to ${user}@localhost identified by '${password}';\"",
    require => Service["mysql"]
  }
}
