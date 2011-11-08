class rsyncd {
  package { "rsync": ensure => installed }

  service { "rsync":
    enable => true,
    ensure => running,
    require => [ Package["rsync"], Exec["enable-rsync"] ]
  }

  exec { "enable-rsync": 
    command => "sed -ie 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync",
    onlyif => "test -z `grep RSYNC_ENABLE=true /etc/default/rsync`"
  } 

  file { "/etc/rsyncd.conf":
    ensure => file,
    source => [ "puppet:///files/rsyncd/${fqdn}/rsyncd.conf",
                "puppet:///files/rsyncd/${operatingsystem}/${lsbdistcodename}/rsyncd.conf",
                "puppet:///files/rsyncd/${operatingsystem}/rsyncd.conf",
                "puppet:///files/rsyncd/rsyncd.conf" ],
    require => Package["rsync"],
    notify => Service["rsync"],
    mode => 0644, owner => root, group => root;
  }

  file { "/etc/rsyncd.secrets":
    ensure => file,
    source => [ "puppet:///files/rsyncd/${fqdn}/rsyncd.secrets",
                "puppet:///files/rsyncd/${operatingsystem}/${lsbdistcodename}/rsyncd.secrets",
                "puppet:///files/rsyncd/${operatingsystem}/rsyncd.secrets",
                "puppet:///files/rsyncd/rsyncd.secrets" ],
    require => Package["rsync"],
    notify => Service["rsync"],
    mode => 0600, owner => root, group => root;
  }
}
