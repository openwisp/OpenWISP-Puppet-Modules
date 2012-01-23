class rvm::system($version='latest') {

  include rvm::dependencies

  exec { 'system-rvm':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "bash -s -- --version ${version} < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )",
    creates => '/usr/local/rvm/bin/rvm',
    require => [
      Class['rvm::dependencies'],
    ],
  }

}
