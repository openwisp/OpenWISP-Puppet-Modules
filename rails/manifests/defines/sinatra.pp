define sinatra($app_name, $path) {
  $app_path = "${path}/${app_name}"

  if !defined(File[$path]) {
    file { $path:
      ensure => directory, recurse => false,
      mode => 0644, owner => root, group => root;
    }
  }

  file { [ "${app_path}", "${app_path}/shared", "${app_path}/shared/config" ]:
    ensure => directory, recurse => false,
    mode => 0644, owner => root, group => root,
    require => File[$path]
  }

  file { "/var/www/${app_name}":
    ensure => symlink,
    target => "${app_path}/current/public"
  }
}
