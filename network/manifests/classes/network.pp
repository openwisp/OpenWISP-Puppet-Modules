class network {
  package { "bridge-utils": ensure => installed }
  package { "vlan": ensure => installed }

  file { "/etc/network/interfaces":
    source => [ "puppet:///files/network/${fqdn}/interfaces" ],
    require => [ Package["bridge-utils"], Package["vlan"], File["/etc/resolv.conf"] ],
    notify => [ Exec['restart-ifaces'] ],
    mode => 0644, owner => root, group => root;
  }

  file { "/etc/resolv.conf":
    source => [ "puppet:///files/network/${fqdn}/resolv.conf",
                "puppet:///files/network/${operatingsystem}/${lsbdistcodename}/resolv.conf",
                "puppet:///files/network/${operatingsystem}/resolv.conf",
                "puppet:///files/network/resolv.conf",
                "puppet:///modules/network/${operatingsystem}/${lsbdistcodename}/resolv.conf",
                "puppet:///modules/network/${operatingsystem}/resolv.conf",
                "puppet:///modules/network/resolv.conf" ],
    mode => 0644, owner => root, group => root;
  }

  exec { "restart-ifaces":
    command => "/etc/init.d/networking restart",
    require => [ Package["bridge-utils"], Package["vlan"] ],
    refreshonly => true;
  }
}
