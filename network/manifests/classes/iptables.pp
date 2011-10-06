class iptables {
  package { "iptables": ensure => installed }
  package { "iptables-persistent": ensure => installed }

  file { "/etc/iptables/rules":
    source => [ "puppet:///files/network/${fqdn}/iptables" ],
    notify => Exec['update-rules'],
    mode => 0400, owner => root, group => root;
  }

  exec { 'update-rules':
    command => "/etc/init.d/iptables-persistent start",
    refreshonly => true,
    require => [ Package["iptables-persistent"], File["/etc/iptables/rules"] ]
  }
}
