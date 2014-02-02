class phabricator::config {

  include 'phabricator::params'

  file { $phabricator::params::repo_dir:
    ensure => directory,
    owner  => $phabricator::params::phabricator_user,
    group  => $phabricator::params::phabricator_group,
  }

  user { $phabricator::params::phabricator_user:
    ensure  => present,
    comment => 'Phabricator',
    gid     => $phabricator::params::phabricator_group,
  }

  group { $phabricator::params::phabricator_group:
    ensure => present,
  }

}
