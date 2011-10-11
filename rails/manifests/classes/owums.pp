class owums($path = '/var/rails', $db_password, $pool_size = '10') {
  package { "libmagickwand-dev": ensure => installed }
  package { "lame": ensure => installed }
  package { "festival": ensure => installed }
  package { "festvox-italp16k": ensure => installed }
  package { "festvox-rablpc16k": ensure => installed }
  package { "librsvg2-bin": ensure => installed }

  class { rails:
      path => "${$path}/${$name}",
      adapter => 'mysql',
      db => $name,
      pool_size => $pool_size,
      db_user => $name,
      db_password => $db_password
  }
}
