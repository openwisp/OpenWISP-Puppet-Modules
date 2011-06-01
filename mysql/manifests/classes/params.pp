class mysql::params {

  $mycnf = $operatingsystem ? {
    /RedHat|Fedora|CentOS/ => "/etc/my.cnf",
    default => "/etc/mysql/my.cnf",
  }

  $mycnfctx = "/files/${mycnf}"

  $data_dir = $mysql_data_dir ? {
    "" => "/var/lib/mysql",
    default => $mysql_data_dir,
  }

  $backup_dir = $mysql_backupdir ? {
    "" => "/var/backups/mysql",
    default => $mysql_backupdir,
  }

}
