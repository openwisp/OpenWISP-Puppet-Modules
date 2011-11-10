class radius {
  package { "freeradius": ensure => installed }
  package { "freeradius-utils": ensure => installed }
  package { "freeradius-mysql": ensure => installed }

  service { "freeradius":
    enable => true,
    ensure => running,
    status => "lsof -u freerad",
    require => Package["freeradius"]
  }

  file { "/etc/freeradius":
    source => [ "puppet:///files/radius/${fqdn}/freeradius",
                "puppet:///files/radius/${operatingsystem}/${lsbdistcodename}/freeradius",
                "puppet:///files/radius/${operatingsystem}/freeradius",
                "puppet:///files/radius/freeradius" ],
    require => Package["freeradius"],
    notify => Service["freeradius"],
    recurse => true, ignore => 'certs',
    mode => 0640, owner => freerad, group => freerad;
  }

  file { "/etc/freeradius/certs":
    ensure => directory,
    mode => 0640, owner => freerad, group => freerad;
  }

  file { "/etc/freeradius/certs/dh":
    ensure => file,
    source => [ "puppet:///files/radius/${fqdn}/freeradius/certs/dh",
                "puppet:///files/radius/${operatingsystem}/${lsbdistcodename}/freeradius/certs/dh",
                "puppet:///files/radius/${operatingsystem}/freeradius/certs/dh",
                "puppet:///files/radius/freeradius/certs/dh" ],
    require => File['/etc/freeradius/certs'],
    mode => 0640, owner => freerad, group => freerad;
  }

  file { "/etc/freeradius/certs/ca.pem":
    ensure => link,
    target => '/etc/ssl/certs/ca.pem',
    require => File['/etc/freeradius/certs'],
    mode => 0640, owner => freerad, group => freerad;
  }

  file { "/etc/freeradius/certs/random":
    ensure => link,
    target => '/dev/urandom',
    require => File['/etc/freeradius/certs'],
    mode => 0640, owner => freerad, group => freerad;
  }

  file { "/etc/freeradius/certs/server.key":
    ensure => link,
    target => '/etc/ssl/private/ssl-cert-snakeoil.key',
    require => File['/etc/freeradius/certs'],
    mode => 0640, owner => freerad, group => freerad;
  }

  file { "/etc/freeradius/certs/server.pem":
    ensure => link,
    target => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    require => File['/etc/freeradius/certs'],
    mode => 0640, owner => freerad, group => freerad;
  }
}
