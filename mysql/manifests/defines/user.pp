define mysql::user($password, $grant) {
  exec { "create-user-${name}":
    unless => "mysql -u${name} -p${password} && test -f ~/.puppet_mysql_${name}_grants && grep -F \"${grant}\" ~/.puppet_mysql_${name}_grants",
    command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"grant ${grant} to ${name}@localhost identified by '${password}';\"",
    require => Service["mysql"],
    notify => Exec["mysql-${name}-grants"]
  }

  exec { "mysql-${name}-grants":
    command => "echo \"${grant}\" > ~/.puppet_mysql_${name}_grants",
    refreshonly => true
  }
}
