class xhprof {

  apt::ppa { 'ppa:brianmercer/php5-xhprof':
    ensure => present,
  }

  php::module { 'xhprof': }

}
