# modules/rkhunter/manifests/init.pp - manage rkhunter
# Copyright (C) 2007 admin@immerda.ch
# 

class rkhunter {
  case $operatingsystem {
    gentoo: { include rkhunter::gentoo }
    centos: { include rkhunter::centos }
    default: { include rkhunter::base }
  }
}
