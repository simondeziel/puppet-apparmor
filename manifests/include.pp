#
# == Define: apparmor::include
#
# Install an Apparmor include file
#
# === Parameters
#
# [*ensure*]
#  Enum variable that can be present (default) or absent to control the presence
#  of the include file.
#
# [*default_base*]
#  Default path to use with $source and $local_source. If unset (default),
#  defaults to a distro specific path.
#
# [*content*]
#   Optional content of the Apparmor profile.
#
# [*source*]
#   Optional source path to the Apparmor profile. If unset (default), defaults
#   to "${default_base}/${name}".
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
  Enum[
    'absent',
    'present']     $ensure       = 'present',
  Optional[String] $default_base = $apparmor::profile_default_base,
  Optional[String] $content      = undef,
  Optional[String] $source       = undef,
) {

  include apparmor
  $apparmor_d = $apparmor::apparmor_d

  if $source and $content {
    fail('apparmor::include: source and content parameter cannot be used at the same time')
  }

  if $source {
    $real_source = $source
  } elsif $content {
    $real_source = undef
  } else {
    $real_source = "${default_base}/${name}"
  }

  file { "${apparmor_d}/${name}":
    ensure  => $ensure,
    content => $content,
    source  => $real_source,
  }
}
