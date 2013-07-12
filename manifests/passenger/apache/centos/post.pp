class rvm::passenger::apache::centos::post(
  $ruby_version,
  $version,
  $rvm_prefix = '/usr/local/',
  $mininstances = '1',
  $maxpoolsize = '6',
  $poolidletime = '300',
  $maxinstancesperapp = '0',
  $spawnmethod = 'smart-lv2',
  $gempath,
  $binpath
) {
  if $version >= '4.0.0' { $passenger_subdir = 'buildout' }
  elsif $version >= '3.9.0' { $passenger_subdir = 'libout' }
  else { $passenger_subdir = 'ext' }

  exec {
    'passenger-install-apache2-module':
      environment => ["HOME=/tmp"],
      command   => "${rvm::passenger::apache::binpath}rvm ${rvm::passenger::apache::ruby_version} exec passenger-install-apache2-module -a",
      creates   => "${rvm::passenger::apache::gempath}/passenger-${rvm::passenger::apache::version}/${passenger_subdir}/apache2/mod_passenger.so",
      logoutput => 'on_failure',
      require   => [Rvm_gem['passenger'], Package['httpd','httpd-devel','mod_ssl']];
  }

  file {
    '/etc/httpd/conf.d/passenger.conf':
      ensure  => file,
      content => template('rvm/passenger-apache-centos.conf.erb'),
      require => Exec['passenger-install-apache2-module'];
  }
}
