class phabricator::install {
  # Repositories
  ensure_resource('package', 'git', {
    ensure => installed,
  })

  vcsrepo { 'arcanist':
    ensure   => latest,
    provider => git,
    path     => "${phabricator::params::base_dir}/arcanist",
    source   => 'https://github.com/phacility/arcanist.git',
  }
  vcsrepo { 'libphutil':
    ensure   => latest,
    provider => git,
    path     => "${phabricator::params::base_dir}/libphutil",
    source   => 'https://github.com/phacility/libphutil.git',
  }
  vcsrepo { 'phabricator':
    ensure   => latest,
    provider => git,
    path     => "${phabricator::params::base_dir}/phabricator",
    source   => 'https://github.com/phacility/phabricator.git',
  }

  file { '/usr/bin/arc':
    ensure => link,
    target => "${phabricator::params::base_dir}/arcanist/bin/arc",
  }

  # XHPAST
  ensure_resource('package', ['g++', 'make'], {
    ensure => installed,
  })
  exec { 'build_xhpast':
    command     => "${phabricator::params::base_dir}/libphutil/scripts/build_xhpast.sh",
    refreshonly => true,
    require     => [
      Class['php::cli'],
      Package['g++'],
      Package['make'],
    ],
    subscribe   => [
      Vcsrepo['libphutil'],
    ],
  }

  # PHP
  file { '/etc/php5':
    ensure => directory,
  }
  file { '/etc/php5/cli':
    ensure  => directory,
    require => File['/etc/php5'],
  }
  php::ini { '/etc/php5/cli/php.ini':
    ensure              => present,
    serialize_precision => '17',
    expose_php          => 'Off',
    memory_limit        => '-1',
    error_reporting     => 'E_ALL & ~E_DEPRECATED & ~E_STRICT',
    error_log           => "${phabricator::config::logs_dir}/php/cli-error.log",
    require             => File['/etc/php5/cli'],
  }
  class { 'php::cli':
    ensure  => installed,
    inifile => '/etc/php5/cli/php.ini',
  }
  php::module { ['apc', 'curl', 'gd', 'json', 'mysql']: }

  # Configuration
  file { "${phabricator::params::base_dir}/phabricator/conf/custom":
    ensure  => directory,
    require => Vcsrepo['phabricator'],
  }
  file { 'phabricator_config':
    ensure  => present,
    path    => "${phabricator::params::base_dir}/phabricator/conf/custom/config.conf.php",
    content => template('phabricator/config.php.erb'),
    owner   => $phabricator::params::phabricator_user,
    group   => $phabricator::params::phabricator_group,
    require => File["${phabricator::params::base_dir}/phabricator/conf/custom"],
  }
  file { 'phabricator_environment':
    ensure  => present,
    path    => "${phabricator::params::base_dir}/phabricator/conf/local/ENVIRONMENT",
    content => 'custom/config',
    owner   => $phabricator::params::phabricator_user,
    group   => $phabricator::params::phabricator_group,
    require => Vcsrepo['phabricator'],
  }
}
