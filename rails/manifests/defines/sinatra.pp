define sinatra($app_name, $release, $repo, $repo_user, $repo_pass, $path) {
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

  exec { "${app_name} initial export":
    command => "svn export --no-auth-cache --username \"${repo_user}\" --password \"${repo_pass}\" ${repo}/tags/${release} ${app_path}/releases/${release}",
    require => File["${app_path}/releases"],
    unless => "test -d ${app_path}/releases/${release}",
    notify => Exec["reload-apache2"]
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

  exec { "${app_name} bundle":
    command => "bundle install --deployment",
    cwd => "${app_path}/current",
    environment => ["RAILS_ENV=production"],
    unless => "bundle check",
    require => [ File["${app_path}/current"], Rvm_gem["bundler"] ]
  }
}
