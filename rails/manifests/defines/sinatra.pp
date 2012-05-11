define sinatra($app_name, $release, $repo, $repo_type, $repo_user, $repo_pass, $path) {
  $app_path = "${path}/${app_name}"

  if !defined(File[$path]) {
    file { $path:
      ensure => directory, recurse => false,
      mode => 0644, owner => root, group => root;
    }
  }

  file { [ "${app_path}", "${app_path}/shared", "${app_path}/shared/config", "${app_path}/releases" ]:
    ensure => directory, recurse => false,
    mode => 0644, owner => root, group => root,
    require => File[$path]
  }

  file { [ "${app_path}/shared/log" ]:
    ensure => directory, recurse => false, 
    mode => 0664, owner => root, group => www-data,
    require => File[$app_path]
  }

  file { [ "${app_path}/shared/log/sinatra.log" ]:
    ensure => present,
    mode => 0664, owner => root, group => www-data,
    require => File["${app_path}/shared/log"]
  }

  if $repo_type == "svn" {
    exec { "${app_name} initial export":
      command => "svn export --no-auth-cache --username \"${repo_user}\" --password \"${repo_pass}\" ${repo}/tags/${release} ${app_path}/releases/${release}",
      require => File["${app_path}/releases"],
      unless => "test -d ${app_path}/releases/${release}",
      notify => Exec["reload-apache2"]
    }
  } elsif $repo_type == "git" {
    exec { "${app_name} initial export":
      command => "git clone ${repo} ${app_path}/releases/${release} && cd ${app_path}/releases/${release} && git checkout ${release} && rm -rf .git",
      require => File["${app_path}/releases"],
      unless => "test -d ${app_path}/releases/${release}",
      notify => Exec["reload-apache2"]
    }
  }

  exec { "${app_name} clean logs":
    command => "rm -rf ${app_path}/releases/${release}/log",
    unless => "test -L ${app_path}/current/log",
    require => [ Exec["${app_name} initial export"] ]
  }

  file { "${app_path}/current/log":
    ensure => symlink,
    target => "${app_path}/shared/log",
    require => [ Exec["${app_name} initial export"], Exec["${app_name} clean logs"] ]
  }

  file { "${app_path}/current":
    ensure => symlink,
    target => "${app_path}/releases/${release}",
    require => [ File["${app_path}/releases"], Exec["${app_name} initial export"] ],
    notify => Exec["reload-apache2"]
  }

  file { "/var/www/${app_name}":
    ensure => symlink,
    target => "${app_path}/current/public",
    notify => Exec["reload-apache2"]
  }

  if $rvm_installed == "true" {
    exec { "${app_name} bundle":
      command => "bundle install --deployment",
      cwd => "${app_path}/current",
      environment => ["RAILS_ENV=production"],
      unless => "bundle check",
      require => [ File["${app_path}/current"], Rvm_gem["bundler"] ]
    }
  }
}
