class owm($repo, $repo_type = "svn", $release, $path = '/var/rails', $db_password, $pool_size = '10') {
  package { "${name} dependencies":
    name   => ["libarchive-dev"],
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

  file { [ "${path}/${name}/shared/private" ]:
    ensure => directory,
    mode => 0664, owner => root, group => www-data,
    require => [ Rails["${name} app"] ]
  }

  exec { "${name} clean private":
    command => "rm -rf ${path}/${name}/releases/${release}/private",
    unless => "test -L ${path}/${name}/current/private",
    require => [ Rails["${name} app"] ]
  }

  file { "${path}/${name}/current/private":
    ensure => symlink,
    target => "${path}/${name}/shared/private",
    require => [ Exec["${name} clean private"] ]
  }

  file { "${path}/${name}/shared/config/gmaps_api_key.yml":
    ensure => file,
    source => [ "puppet:///files/rails/${fqdn}/owm_google_maps_api_key.yml",
                "puppet:///files/rails/${operatingsystem}/${lsbdistcodename}/owm_google_maps_api_key.yml",
                "puppet:///files/rails/${operatingsystem}/owm_google_maps_api_key.yml",
                "puppet:///files/rails/owm_google_maps_api_key.yml",
                "puppet:///modules/rails/${operatingsystem}/${lsbdistcodename}/owm_google_maps_api_key.yml",
                "puppet:///modules/rails/${operatingsystem}/owm_google_maps_api_key.yml",
                "puppet:///modules/rails/owm_google_maps_api_key.yml" ],
    mode => 0644, owner => root, group => root;
  }

  file { "${path}/${name}/current/config/gmaps_api_key.yml":
    ensure  => symlink,
    target  => "${path}/${name}/shared/config/gmaps_api_key.yml",
    require => [ Exec["${name} initial export"], File["${path}/${name}/shared/config/gmaps_api_key.yml"] ]
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
    require => [ File["${name} init script"], Rails["${name} app"] ]
  }

  exec { "${name} db seed":
    command => "bundle exec rake db:seed && touch ../.seeds_run_by_puppet",
    cwd => "${path}/${name}/current",
    unless => "test -f ${path}/${name}/releases/.seeds_run_by_puppet",
    environment => ["RAILS_ENV=production"],
    require => [ Rails["${name} app"] ]
  }
}
