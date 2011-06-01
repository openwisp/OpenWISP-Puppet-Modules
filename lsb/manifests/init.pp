class lsb {
  case $operatingsystem {
    debian: { include lsb::debian }
    centos: { include lsb::centos }
  }
}
