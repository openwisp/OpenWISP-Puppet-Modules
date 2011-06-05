class rkhunter::base {
  package { 'rkhunter':
    ensure => present,
  }

  file {"/etc/rkhunter.conf":
    source => [ "puppet:///files/rkhunter/${fqdn}/rkhunter.conf",
                "puppet:///files/rkhunter/${operatingsystem}/${lsbdistcodename}/rkhunter.conf",
                "puppet:///files/rkhunter/${operatingsystem}/rkhunter.conf",
                "puppet:///files/rkhunter/rkhunter.conf",
                "puppet:///modules/rkhunter/${operatingsystem}/${lsbdistcodename}/rkhunter.conf",
                "puppet:///modules/rkhunter/${operatingsystem}/rkhunter.conf",
                "puppet:///modules/rkhunter/rkhunter.conf" ],
    require => Package['rkhunter'],
    mode => 0400, owner => root, group => root;
  }
  case $operatingsystem {
    debian: {
      case $lsbdistcodename {
        'etch': { info("no need to init the database") }
        default: { include rkhunter::dbinit }
      }
    }
    default: { include rkhunter::dbinit }
  }
}
