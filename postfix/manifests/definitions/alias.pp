define aliases_static {
  file { "/etc/aliases":
    source => [ "puppet:///files/postfix/${fqdn}/main.cf" ],
    notify => Exec["set-aliases"],
    require => Package["postfix"],
    mode => 0400, owner => root, group => root;
  }
}

define aliases_dynamic {
  file { "/etc/aliases":
    content => template("puppt:///templates/postfix/main.cf"),
    notify => Exec["set-aliases"],
    require => Package["postfix"],
    mode => 0400, owner => root, group => root;
  }
}
