class owmw($repo, $repo_type = "svn", $release, $repo_user, $repo_pass, $path = '/var/rails', $capistrano_enabled = true, $svn2git = '0', $owmw_pull = '0' ) {
  sinatra { "${name} app":
      app_name => $name,
      repo => $repo,
      repo_type => $repo_type,
      release => $release,
      repo_user => $repo_user,
      repo_pass => $repo_pass,
      path => $path,
      owmw_pull => $owmw_pull, 
      svn2git => $svn2git
  }

  file { "${path}/${name}/shared/config/settings.rb":
    ensure => file,
    source => [ "puppet:///files/rails/${fqdn}/owmw_config.rb",
                "puppet:///files/rails/${operatingsystem}/${lsbdistcodename}/owmw_config.rb",
                "puppet:///files/rails/${operatingsystem}/owmw_config.rb",
                "puppet:///files/rails/owmw_config.rb",
                "puppet:///modules/rails/${operatingsystem}/${lsbdistcodename}/owmw_config.rb",
                "puppet:///modules/rails/${operatingsystem}/owmw_config.rb",
                "puppet:///modules/rails/owmw_config.rb" ],
    require => Sinatra["${name} app"],
    mode => 0666, owner => root, group => www-data;
  }

  file { "${path}/${name}/current/config/settings.rb":
    ensure => symlink,
    target => "${path}/${name}/shared/config/settings.rb",
    require => [ File["${path}/${name}/shared/config/settings.rb"] ]
  }
}
