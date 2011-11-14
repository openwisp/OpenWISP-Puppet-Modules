define preseed_package($ensure, $seeds) {
  file { [ "/var/local", "/var/local/preseed" ]:
    ensure => directory, mode => 0600,
    owner => root, group => root
  }

  file { "/var/local/preseed/$name.preseed":
    ensure => file,
    content => template("packages/preseed.erb"),
    mode => 0600, owner => root, group => root,
    require => File["/var/local/preseed"]
  }

  package { "$name":
    ensure => $ensure,
    responsefile => "/var/local/preseed/$name.preseed",
    require => File["/var/local/preseed/$name.preseed"]
  }
}
