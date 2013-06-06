define mysql::initializetable($db_name, $user, $password, $cmd) {
  exec { "initialize-key-${db_name}-db":
    unless => "test -f /opt/initialized_table",
    command => "/usr/bin/mysql -u${user} -p${password} -e \" use ${db_name}; ${cmd}\"",
    require => Service["mysql"]
  }
  exec { "touch file for gestpay initialization":
    unless => "test -f /opt/initialized_table",
    command => "touch /opt/initialized_table",
    require => [ Exec["initialize-key-${db_name}-db"] ]
  }
}
