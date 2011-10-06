class logrotate($name = "NONE", $log = "NONE", $options = [], $postrotate = "NONE") {
  # $options should be an array containing 1 or more logrotate directives (e.g. missingok, compress)

  package { "logrotate": ensure => installed }

  file { "/etc/logrotate.d":
    ensure => directory,
    owner => root, group => root, mode => 755,
    require => Package['logrotate'],
  }

  if ($name != "NONE" and $log != "NONE") {
    file { "/etc/logrotate.d/${name}":
      owner => root,
      group => root,
      mode => 644,
      content => template("logging/logrotate.erb"),
      require => File["/etc/logrotate.d"]
    }
  }
}
