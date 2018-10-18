#
# == Define: apparmor::include
#
# Install an Apparmor include file
#
# === Parameters
#
# [*default_base*]
#  Default path to use with $source and $local_source. If unset (default),
#  defaults to a distro specific path.
#
# [*source*]
#   Source path to the Apparmor profile. If unset (default), defaults to
#   "${default_base}/${name}".
#
# === Variables
#
# [*lsbdistrelease*]
#   The LSB distribution release number (normally provided as a fact).
#
# === Examples
#
# apparmor::profile { 'abstractions/libpam-systemd':
#   source => 'puppet:///modules/bar/abstractions/libpam-systemd',
#   notify => Exec['aa-enable-usr.bin.bar'],
# }
#
# === Authors
#
# Simon Deziel <simon.deziel@gmail.com>
#
# === Copyright
#
# Copyright 2012-2017 Simon Deziel
#
define apparmor::include (
  $default_base = "puppet:///modules/apparmor/profiles/${::lsbdistrelease}",
  $source       = undef,
) {

  include apparmor
  $apparmor_d = $apparmor::apparmor_d

  if ($source) {
    $real_source = $source
  } else {
    $real_source = "${default_base}/${name}"
  }

  file { "${apparmor_d}/${name}":
    source => $real_source,
  }
}
