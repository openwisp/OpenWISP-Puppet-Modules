class mysql::server($password) {
  package { [ "mysql-server", "mysql-client", "libmysqlclient-dev" ]: ensure => installed }

  service { "mysql":
    enable => true,
    ensure => running,
    require => Package["mysql-server"]
  }

  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p${password} status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password ${password}",
    require => Service["mysql"]
  }
}
