class {'apt':
  always_apt_update => true,
}

class { 'phabricator': }

node 'phabricator' {
  class { 'phabricator::aphlict': }
  class { 'phabricator::daemon': }
  class { 'phabricator::database': }
  class { 'phabricator::web': }
}

package { ['curl', 'htop', 'vim']:
  ensure => installed,
}
