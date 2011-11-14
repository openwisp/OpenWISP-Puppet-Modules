class zabbix_agent {
  package { "zabbix-agent": ensure => installed }

  service { "zabbix-agent":
    enable => true,
    ensure => running,
    require => Package["zabbix-agent"]
  }

  file { "/etc/zabbix/zabbix_agentd.conf":
    source => [ "puppet:///files/network/${fqdn}/zabbix_agentd.conf",
                "puppet:///files/network/${operatingsystem}/${lsbdistcodename}/zabbix_agentd.conf",
                "puppet:///files/network/${operatingsystem}/zabbix_agentd.conf",
                "puppet:///files/network/zabbix_agentd.conf" ],
    require => Package["zabbix-agent"],
    notify => Service["zabbix-agent"],
    mode => 0640, owner => root, group => zabbix;
  }
}
