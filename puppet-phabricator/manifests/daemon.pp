class phabricator::daemon {

  require 'phabricator::config'
  require 'phabricator::install'

  # TODO: Daemons are currently running as root.
  user { $phabricator::params::phd_user:
    ensure  => present,
    comment => 'Phabricator Daemons',
    gid     => $phabricator::params::phabricator_group,
    home    => '/usr/sbin/nologin',
    shell   => '/bin/false',
  }

  # Create an upstart script for `phd`.
  file { '/etc/init.d/phd':
    ensure  => present,
    content => template('phabricator/upstart/phd.erb'),
    mode    => '0755',
  }

  service { 'phd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File['/etc/init.d/phd'],
    subscribe  => [
      File['phabricator_config'],
      File['phabricator_environment'],
      Vcsrepo['libphutil'],
      Vcsrepo['phabricator'],
    ],
  }
}
