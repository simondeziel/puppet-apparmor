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
# Copyright 2012-2017 Simon Deziel
#
class apparmor (
  $package_ensure = 'installed',
  $package_manage = true,
  $service_ensure = 'running',
  $service_manage = true,
) {

  if $package_manage {
    package { 'apparmor':
      ensure => $package_ensure,
    }
  }

  if $service_manage {
    service { 'apparmor':
      ensure => $service_ensure,
    }
  }

  $apparmor_d = '/etc/apparmor.d'
  file { 'apparmor.d':
    ensure  => directory,
    path    => $apparmor_d,
    owner   => '0',
    group   => '0',
    mode    => '0755',
    require => Package['apparmor'],
  }

  file { 'apparmor.d.local':
    ensure  => directory,
    path    => "${apparmor_d}/local",
    owner   => '0',
    group   => '0',
    mode    => '0755',
    require => Package['apparmor'],
  }
}
