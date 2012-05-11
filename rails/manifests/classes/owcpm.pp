class owcpm($repo, $repo_type = "svn", $release, $repo_user, $repo_pass, $path = '/var/rails', $db_password, $pool_size = '10', $owmw_enabled = 'false', $owmw_url = '', $owmw_user = '', $owmw_password = '') {
  rails { "${name} app":
      app_name => $name,
      repo => $repo,
      repo_type => $repo_type,
      release => $release,
      repo_user => $repo_user,
      repo_pass => $repo_pass,
      path => $path,
      adapter => 'mysql',
      db => $name,
      pool_size => $pool_size,
      db_user => $name,
      db_password => $db_password
  }

  file { "${name} init script":
    path =>"/etc/init.d/${name}-daemons",
    ensure => file, 
    content => template('rails/init_script.erb'),
    mode => 0751, owner => root, group => root;
  }

  file { "${name} ios workaround":
    ensure => directory, recurse => true,
    path =>"/var/www/ios-workaround/",
    source => "puppet:///modules/rails/ios-workaround",
    mode => 0640, owner => root, group => www-data;
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
    require => [ File["${name} init script"], Rails["${name} app"] ],
    subscribe => File["/etc/iptables/rules"]
  }

  exec { "${name} db seed":
    command => "bundle exec rake db:seed && touch ../.seeds_run_by_puppet",
    cwd => "${path}/${name}/current",
    unless => "test -f ${path}/${name}/releases/.seeds_run_by_puppet",
    environment => ["RAILS_ENV=production"],
    require => [ Rails["${name} app"], Service["${name}-daemons running"] ]
  }

  if $owmw_enabled == "true" {
    file { "${name} owmw config":
      path =>"${path}/${name}/shared/config/owmw.yml",
      ensure => file,
      content => template('rails/owmw.yml.erb'),
      mode => 0644, owner => root, group => root
    }

    file { "${path}/${name}/current/config/owmw.yml":
      ensure  => symlink,
      target  => "${path}/${name}/shared/config/owmw.yml",
      require => [ Exec["${name} initial export"], File["${path}/${name}/shared/config/owmw.yml"] ]
    }
  }
}
