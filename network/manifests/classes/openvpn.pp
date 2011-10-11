class openvpn {
  package { "openvpn": ensure => installed }

  service { "openvpn":
    enable => true,
    ensure => running,
    require => Package["openvpn"]
  }

  file { "/etc/openvpn":
    source => [ "puppet:///files/network/${fqdn}/openvpn",
                "puppet:///files/network/${operatingsystem}/${lsbdistcodename}/openvpn",
                "puppet:///files/network/${operatingsystem}/openvpn",
                "puppet:///files/network/openvpn" ],
    require => Package["openvpn"],
    notify => Service["openvpn"],
    recurse => true,
    mode => 0400, owner => root, group => root;
  }
}
