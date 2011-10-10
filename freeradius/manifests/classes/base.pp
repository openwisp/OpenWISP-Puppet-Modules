class radius {
  package { "freeradius": ensure => installed }
  package { "freeradius-utils": ensure => installed }

  service { "freeradius":
    enable => true,
    ensure => running,
    require => Package["freeradius"]
  }

  file { "/etc/freeradius":
    source => [ "puppet:///files/radius/${fqdn}/freeradius",
                "puppet:///files/radius/${operatingsystem}/${lsbdistcodename}/freeradius",
                "puppet:///files/radius/${operatingsystem}/freeradius",
                "puppet:///files/radius/freeradius" ],
    require => Package["freeradius"],
    notify => Service["freeradius"],
    mode => 0400, owner => root, group => root;
  }
}
