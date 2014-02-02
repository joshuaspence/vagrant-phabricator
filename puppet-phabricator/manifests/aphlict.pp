class phabricator::aphlict {

  include 'phabricator::params'

  user { $phabricator::params::aphlict_user:
    ensure  => present,
    comment => 'Aphlict Notifications Server',
    gid     => $phabricator::params::phabricator_group,
    home    => '/usr/sbin/nologin',
    shell   => '/bin/false',
  }

  class { 'nodejs':
    manage_repo => true,
  }

  # Create an upstart script for `aphlict`.
  file { '/etc/init.d/aphlict':
    ensure  => present,
    content => template('phabricator/upstart/phd.erb'),
    mode    => '0755',
  }

}
