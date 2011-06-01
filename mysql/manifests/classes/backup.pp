/*
== Class: mysql::backup

Enable mysql daily backup script.

The script /usr/local/bin/mysql-backup.sh will be run every night. It runs
mysqldump --all-databases. Backups will be stored in /var/backups/mysql.

Attributes:
- $mysqldump_retention: defines if backup rotate on a weekly, monthly or yearly
  basis. Accepted values: "week", "month", "year". Defaults to "week".
$subversion_backupdir = "/var/backups/subversion"

*/
class mysql::backup {

  include mysql::params

  if $mysqldump_retention {} else { $mysqldump_retention = "week" }

  $data_dir = $mysql::params::data_dir
  $backup_dir = $mysql::params::backup_dir

  if !defined(Group["mysql-admin"]) {
    group { "mysql-admin": ensure => present,}
  }

  file { "${backup_dir}":
    ensure  => directory,
    owner   => "root",
    group   => "mysql-admin",
    mode    => 750,
    require => Group["mysql-admin"]
  }

  file { "/usr/local/bin/mysql-backup.sh":
    ensure  => present,
    content => template("mysql/mysql-backup.sh.erb"),
    owner   => "root",
    group   => "root",
    mode    => 555,
  }

  cron { "mysql-backup":
    command => "/usr/local/bin/mysql-backup.sh ${mysqldump_retention}",
    user    => "root",
    hour    => 2,
    minute  => 0,
    require => [File["${backup_dir}"], File["/usr/local/bin/mysql-backup.sh"]],
  }

}
