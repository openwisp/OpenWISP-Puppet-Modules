class rkhunter::dbinit {
    exec{'init_rkunter_db':
        command => 'rkhunter --propupd',
	path	=> "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        creates => '/var/lib/rkhunter/db/rkhunter.dat',
        require => Package['rkhunter'],
    }
}
