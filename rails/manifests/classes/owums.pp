class owums($path = '/var/rails', $db_password, $pool_size = '10') {
  package { "libmagickwand-dev": ensure => installed }

  class { rails:
      path => "${$path}/${$name}",
      adapter => 'mysql',
      db => $name,
      pool_size => $pool_size,
      db_user => $name,
      db_password => $db_password
  }
}
