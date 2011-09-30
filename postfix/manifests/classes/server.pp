class postfix::server($aliases_static) {
  package { "postfix": ensure => installed }

  service { "postfix":
    enable => true,
    ensure => running,
    require => Package["postfix"]
  }

  if $aliases_static {
    aliases_static { 'load via file': }
  } else {
    aliases_dynamic { 'load via template': }
  }

  exec { "set-aliases":
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    command => "postalias /etc/aliases",
    require => File["/etc/aliases"]
  }
}
