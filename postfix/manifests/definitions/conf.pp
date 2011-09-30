define static_conf {
  file { "/etc/postfix/main.cf":
    source => [ "puppet:///files/postfix/${fqdn}/main.cf" ],
    notify => Exec["set-aliases"],
    require => Package["postfix"],
    mode => 0400, owner => root, group => root;
  }
}

define dynamic_conf {
  file { "/etc/postfix/main.cf":
    content => template("postfix/main.cf.erb"),
    notify => Exec["set-aliases"],
    require => Package["postfix"],
    mode => 0400, owner => root, group => root;
  }
}
