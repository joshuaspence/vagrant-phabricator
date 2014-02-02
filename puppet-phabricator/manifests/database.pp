class phabricator::database {

  require 'phabricator::install'

  class { 'mysql::server':
    override_options => {
      'mysqld' => {
        'sql-mode' => 'STRICT_ALL_TABLES',
      },
    },
    restart          => true,
  }

  exec { 'storage-upgrade':
    command   => "${phabricator::params::base_dir}/phabricator/bin/storage upgrade --force",
    unless    => "${phabricator::params::base_dir}/phabricator/bin/storage status",
    require   => [
      Class['mysql::server'],
    ],
    subscribe => Vcsrepo["${phabricator::params::base_dir}/phabricator"],
  }
}
