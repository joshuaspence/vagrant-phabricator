class phabricator::web {

  require 'phabricator::config'
  require 'phabricator::install'

  package { 'imagemagick':
    ensure => installed,
  }

  class { 'python':
    pip => true,
  }
  python::pip { 'Pygments': }

  class { 'nginx':
    worker_processes     => 'auto',
    confd_purge          => true,
    vhost_purge          => true,
    configtest_enable    => true,
    server_tokens        => 'off',
    client_max_body_size => '20M',
    http_cfg_append      => {
      'charset'           => 'UTF-8',

      'gzip_vary'         => 'on',
      'gzip_proxied'      => 'any',
      'gzip_min_length'   => '256',
      'gzip_comp_level'   => '4',
      'gzip_buffers'      => '16 8k',
      'gzip_http_version' => '1.1',
      'gzip_types'        => join([
        'text/plain',
        'text/css',
        'application/json',
        'application/x-javascript',
        'text/xml',
        'application/xml',
        'application/xml+rss',
        'text/javascript',
      ], ' '),

      'tcp_nopush'        => 'on',
    },
  }
  nginx::resource::vhost { $phabricator::params::server_name:
    ensure               => present,
    index_files          => ['index.php'],
    www_root             => "${phabricator::params::base_dir}/phabricator/webroot",
    use_default_location => false,
    rewrite_rules        => [
      '^/(.*)$ /index.php?__path__=/$1 last',
    ],
  }
  nginx::resource::location { "${phabricator::params::server_name}/":
    ensure        => present,
    location      => '/',
    vhost         => $phabricator::params::server_name,
    www_root      => "${phabricator::params::base_dir}/phabricator/webroot",
    index_files   => [],
    rewrite_rules => [
      '^/(.*)$ /index.php?__path__=/$1 last',
    ],
  }
  nginx::resource::location { "${phabricator::params::server_name}/rsrc/":
    ensure              => present,
    location            => '^~ /rsrc/',
    vhost               => $phabricator::params::server_name,
    location_custom_cfg => {
      try_files => '$uri $uri/ =404',
    },
  }
  nginx::resource::location { "${phabricator::params::server_name}/favicon.ico":
    ensure              => present,
    location            => '= /favicon.ico',
    vhost               => $phabricator::params::server_name,
    location_custom_cfg => {
      try_files => '$uri =204',
    },
  }
  nginx::resource::location { "${phabricator::params::server_name}/index.php":
    ensure              => present,
    location            => '/index.php',
    vhost               => $phabricator::params::server_name,
    fastcgi             => 'php_pool',
    location_cfg_append => {
      'fastcgi_index' => 'index.php',
    },
  }
  nginx::resource::upstream { 'php_pool':
    ensure  => present,
    members => ['unix:/var/run/php5-fpm.socket'],
  }

  php::module::ini { 'apc':
    settings => {
      'apc.stat' => '1',
    },
  }
  class { 'xhprof': }

  php::fpm::conf { 'www':
    ensure => present,
    user   => 'www-data',
    group  => 'www-data',
    listen => '/var/run/php5-fpm.socket',
    env    => ['PATH'],
  }
  class { 'php::fpm::daemon': }

  Vcsrepo['arcanist'] ~> Service['php5-fpm']
  Vcsrepo['libphutil'] ~> Service['php5-fpm']
  Vcsrepo['phabricator'] ~> Service['php5-fpm']
}
