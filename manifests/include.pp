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
# Simon Deziel <simon@sdeziel.info>
#
# === Copyright
#
# Copyright 2012-2020 Simon Deziel
#
define apparmor::include (
  Optional[String] $default_base = $apparmor::profile_default_base,
  Optional[String] $content      = undef,
  Optional[String] $source       = undef,
) {

  include apparmor
  $apparmor_d = $apparmor::apparmor_d

  if $source {
    $real_source = $source
  } elsif $content {
    $real_source = undef
  } else {
    $real_source = "${default_base}/${name}"
  }

  file { "${apparmor_d}/${name}":
    content => $content,
    source  => $real_source,
  }
}
