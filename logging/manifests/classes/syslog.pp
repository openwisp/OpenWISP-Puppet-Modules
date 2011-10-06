class syslog {
  package { "syslog-ng": ensure => installed }

  file { "/etc/syslog-ng/syslog-ng.conf":
    source => [ "puppet:///files/logging/${fqdn}/syslog-ng.conf",
                "puppet:///files/logging/${operatingsystem}/${lsbdistcodename}/syslog-ng.conf",
                "puppet:///files/logging/${operatingsystem}/syslog-ng.conf",
                "puppet:///files/logging/syslog-ng.conf" ],
    require => Package['syslog-ng'],
    notify => Service['syslog-ng'],
    mode => 0400, owner => root, group => root;
  }

  service { "syslog-ng":
    ensure => running,
    enable => true
  }
}
