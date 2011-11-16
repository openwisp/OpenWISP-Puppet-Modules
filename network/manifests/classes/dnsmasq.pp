class dnsmasq {
  package { "dnsmasq": ensure => installed }

  service { "dnsmasq":
    enable => true,
    ensure => running,
    require => [ Package["dnsmasq"], Exec["enable-dnsmasq"] ]
  }

  exec { "enable-dnsmasq": 
    command => "sed -ie 's/ENABLE=false/ENABLE=true/' /etc/default/dnsmasq",
    refreshonly => true
  } 

  file { "/etc/dnsmasq.d/":
    ensure => directory, recurse => true,
    source => [ "puppet:///files/network/${fqdn}/dnsmasq",
                "puppet:///files/network/${operatingsystem}/${lsbdistcodename}/dnsmasq",
                "puppet:///files/network/${operatingsystem}/dnsmasq",
                "puppet:///files/network/dnsmasq" ],
    require => Package["dnsmasq"],
    notify => Service["dnsmasq"],
    mode => 0644, owner => root, group => root;
  }
}
