define deb {
  if !defined(File["/root/installed_debs"]){
    file { "/root/installed_debs":
      ensure => directory, recurse => true,
      source => [ "puppet:///files/packages/${fqdn}/debs",
      "puppet:///files/packages/${operatingsystem}/${lsbdistcodename}/debs",
      "puppet:///files/packages/${operatingsystem}/debs",
      "puppet:///files/packages/debs" ],
      mode => 0640, owner => root, group => root;
    }
  }

  file { "/root/installed_debs/${name}":
    ensure => file,
    source => [ "puppet:///files/packages/${fqdn}/debs/${name}",
    "puppet:///files/packages/${operatingsystem}/${lsbdistcodename}/debs/${name}",
    "puppet:///files/packages/${operatingsystem}/debs/${name}",
    "puppet:///files/packages/debs/${name}" ],
    mode => 0640, owner => root, group => root,
    before => Exec["install deb ${name}"]
  }

  exec{ "install deb ${name}":
    command => "dpkg -i /root/installed_debs/${name}",
    onlyif => "test -z \"`dpkg -l | grep \`echo ${name} | cut -d_ -f1\` | grep \`echo ${name} | cut -d_ -f2\``\""
  }
}
