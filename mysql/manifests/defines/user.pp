define mysql::user($password, $priviledges) {
  mysql::grant{ $priviledges: user => $name, password => $password }
}

define mysql::grant($user, $password) {
  if ($name =~ /(?i:grant)/) {
     $cmd = "/usr/bin/mysql -uroot -p${mysql_password} -e \"${name} to ${user}@localhost identified by '${password}';\""
  } 

  if ($name =~ /(?i:revoke)/) {
     $cmd = "/usr/bin/mysql -uroot -p${mysql_password} -e \"${name} from ${user}@localhost;\""
  }

  $priviledge_name = regsubst($name, ' ', '-', 'G')

  exec { "set-${user}-${priviledge_name}":
    unless => "mysql -u${user} -p${password} -e \"show grants;\" && test -f ~/.puppet_mysql_${user}_priviledges && grep -F \"${name}\" ~/.puppet_mysql_${user}_priviledges",
    command => $cmd,
    require => Service["mysql"],
    notify => Exec["track-${user}-${priviledge_name}"]
  }

  exec { "track-${user}-${priviledge_name}":
    command => "echo \"${name}\" >> ~/.puppet_mysql_${user}_priviledges",
    refreshonly => true
  }
}
