class captivepages($source = 'file') {
  if $source == 'file' {
    file { "/var/www/captivepages":
      ensure => directory, recurse => true,
      mode => 0655, owner => root, group => root,
      source => "puppet:///files/captivepages/${fqdn}"
    }
  }

  if $source == 'template' {
    file { "/var/www/captivepages":
      ensure => directory,
      mode => 0644, owner => root, group => root
    }

    file { "/var/www/captivepages/assets":
      ensure => directory, recurse => true,
      mode => 0644, owner => root, group => root,
      source => "puppet:///modules/captivepages/assets",
      require => File["/var/www/captivepages"]
    }

    file { "/var/www/captivepages/index.html":
      ensure => present,
      mode => 0644, owner => root, group => root,
      content => template('captivepages/index.html.erb'),
      require => File["/var/www/captivepages"]
    }

    file { "/var/www/captivepages/index_en.html":
      ensure => present,
      mode => 0644, owner => root, group => root,
      content => template('captivepages/index_en.html.erb'),
      require => File["/var/www/captivepages"]
    }
  }
}
