#
# == Class: apparmor
#
# Install the Apparmor package and make sure /etc/apparmor.d/local exists.
#
# Note that custom Ubuntu profiles are availables at:
#   https://github.com/simondeziel/aa-profiles
# and should be copied/cloned to the "files" directory unless you want to
# use your own custom modules in that same directory.
#
# === Parameters
#
# None.
#
# === Variables
#
# None.
#
# === Examples
#
# include apparmor
#
# === Authors
#
# Simon Deziel <simon.deziel@gmail.com>
#
# === Copyright
#
# Copyright 2012 Simon Deziel
#
class apparmor {

  package { 'apparmor':
    ensure => present,
  }

  $apparmor_d = '/etc/apparmor.d'
  file { 'apparmor.d':
    ensure  => directory,
    path    => $apparmor_d,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['apparmor'],
  }

  file { 'apparmor.d.local':
    ensure  => directory,
    path    => "${apparmor_d}/local",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['apparmor'],
  }
}
