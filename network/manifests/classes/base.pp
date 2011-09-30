class network {
  package { "bridge-utils": ensure => installed }
  package { "resolvconf": ensure => installed }
  package { "vlan": ensure => installed }

  file { "/etc/network/interfaces":
    source => [ "puppet:///files/network/${fqdn}/interfaces" ],
    require => [ Package["bridge-utils"], Package["resolvconf"], Package["vlan"] ],
    notify => Exec['restart-ifaces'],
    mode => 0400, owner => root, group => root;
  }

  exec { "restart-ifaces":
    command => "/etc/init.d/networking restart",
    require => [ Package["bridge-utils"], Package["resolvconf"], Package["vlan"] ],
    refreshonly => true;
  }
}
