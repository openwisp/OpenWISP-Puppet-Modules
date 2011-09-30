class postfix::server($static_conf = true) {
  package { "postfix": ensure => installed }

  service { "postfix":
    enable => true,
    ensure => running,
    require => Package["postfix"]
  }

  if $static_conf {
    static_conf { 'load via file': }
  } else {
    dynamic_conf { 'load via template': }
  }

  file { "/etc/aliases":
    source => [ "puppet:///files/postfix/${fqdn}/aliases",
                "puppet:///files/postfix/${operatingsystem}/${lsbdistcodename}/aliases",
                "puppet:///files/postfix/${operatingsystem}/aliases",
                "puppet:///files/postfix/aliases",
                "puppet:///modules/postfix/${operatingsystem}/${lsbdistcodename}/aliases",
                "puppet:///modules/postfix/${operatingsystem}/aliases",
                "puppet:///modules/postfix/aliases" ],
    require => Package["postfix"],
    notify => Exec["set-aliases"],
    mode => 0400, owner => root, group => root;
  }

  exec { "set-aliases":
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    command => "postalias /etc/aliases",
    require => File["/etc/aliases"],
    refreshonly => true
  }
}
