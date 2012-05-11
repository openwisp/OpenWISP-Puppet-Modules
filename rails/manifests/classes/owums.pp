class owums($release, $repo, $repo_type = "svn", $path = '/var/rails', $db_password, $pool_size = '10') {
  package { "${name} dependencies":
    name => ["libmagickwand-dev", "lame", "festival", "festvox-italp16k", "festvox-rablpc16k", "librsvg2-bin"],
    ensure => installed
  }

  rails { "${name} app":
      app_name => $name,
      repo => $repo,
      repo_type => $repo_type,
      release => $release,
      path => $path,
      adapter => 'mysql',
      db => $name,
      pool_size => $pool_size,
      db_user => $name,
      db_password => $db_password
  }

  file { "${path}/${name}/current/tmp/fleximage":
    ensure => directory, require => Rails["${name} app"],
    mode => 0770, owner => root, group => www-data;
  }

  file { "${path}/${name}/current/tmp/stat_exports":
    ensure => directory, require => Rails["${name} app"],
    mode => 0770, owner => root, group => www-data;
  }

  file { "${path}/${name}/current/public/documents":
    ensure => directory, recurse => true,
    source => [ "puppet:///files/rails/${fqdn}/owums_documents/",
                "puppet:///files/rails/${operatingsystem}/${lsbdistcodename}/owums_documents/",
                "puppet:///files/rails/${operatingsystem}/owums_documents/",
                "puppet:///files/rails/owums_documents/",
                "puppet:///modules/rails/${operatingsystem}/${lsbdistcodename}/owums_documents/",
                "puppet:///modules/rails/${operatingsystem}/owums_documents/",
                "puppet:///modules/rails/owums_documents/" ],
    require => Rails["${name} app"],
    mode => 0640, owner => root, group => www-data;
  }

  file { "${name} init script":
    path =>"/etc/init.d/${name}-daemons",
    ensure => file, 
    content => template('rails/init_script.erb'),
    mode => 0751, owner => root, group => root;
  }

  # If we are changing releases, we must stop daemons!
  exec { "${name}-daemons stopped":
    command => "/etc/init.d/${name}-daemons stop",
    unless  => "echo '${release}' | grep `cat ${path}/${name}/current/VERSION`",
    require => [ File["${name} init script"] ],
    before  => [ Rails["${name} app"], Service["${name}-daemons running"] ]
  }

  service { "${name}-daemons running":
    name => "${name}-daemons",
    enable => true,
    ensure => running,
    require => [ Package["${name} dependencies"], File["${name} init script"], Rails["${name} app"], Exec["${name} db seed"] ]
  }

  exec { "${name} db seed":
    command => "bundle exec rake db:seed && touch ../.seeds_run_by_puppet",
    cwd => "${path}/${name}/current",
    unless => "test -f ${path}/${name}/releases/.seeds_run_by_puppet",
    environment => ["RAILS_ENV=production"],
    require => [ Rails["${name} app"] ]
  }
}
