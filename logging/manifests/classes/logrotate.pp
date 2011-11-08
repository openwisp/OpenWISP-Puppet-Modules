class logrotate {
  package { "logrotate": ensure => installed }

  file { "/etc/logrotate.d":
    source => [ "puppet:///files/logging/${fqdn}/logrotate",
                "puppet:///files/logging/${operatingsystem}/${lsbdistcodename}/logrotate",
                "puppet:///files/logging/${operatingsystem}/logrotate",
                "puppet:///files/logging/logrotate" ],
    require => Package['logrotate'],
    recurse => true,
    owner => root, group => root, mode => 755
  }
}
