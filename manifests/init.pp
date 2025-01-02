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
# Simon Deziel <simon@sdeziel.info>
#
# === Copyright
#
# Copyright 2012-2020 Simon Deziel
#
class apparmor (
  Boolean $package_manage       = true,
  String  $service_ensure       = 'running',
  Boolean $service_manage       = true,
  String  $profile_default_base = "puppet:///modules/apparmor/aa-profiles/${facts['os']['distro']['release']['full']}",
  Hash    $profiles             = {},
) {

  if $package_manage {
    ensure_packages('apparmor')
    Package['apparmor'] -> File['apparmor.d','apparmor.d.local']
  }

  if $service_manage {
    service { 'apparmor':
      ensure  => $service_ensure,
      require => File['apparmor.d','apparmor.d.local'],
    }
  }

  $apparmor_d = '/etc/apparmor.d'
  file { 'apparmor.d':
    ensure => directory,
    path   => $apparmor_d,
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

  file { 'apparmor.d.local':
    ensure => directory,
    path   => "${apparmor_d}/local",
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

  create_resources('apparmor::profile',$profiles)
}
