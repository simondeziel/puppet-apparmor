#
# == Class: apparmor
#
# Install the Apparmor package and make sure /etc/apparmor.d/local exists.
#
# Note that custom Ubuntu profiles are availables at:
# https://github.com/simondeziel/aa-profiles
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
# Copyright 2012-2015 Simon Deziel
#
class apparmor {

  package { 'apparmor':
    ensure => present,
  }

  service { 'apparmor':
    ensure => running,
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
