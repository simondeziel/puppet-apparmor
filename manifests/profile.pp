#
# == Define: apparmor::profile
#
# Install an Apparmor profile and a local profile to add/override some rules
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
# [*local_source*]
#   Tri-state variable that can be true, false (default) or a source path to the
#   local Apparmor profile. If true, uses "${default_base}/local/${name}" as the
#   source path to the local Apparmor profile. If false, do not install a local
#   profile. If set to something else, use it as the source path.
#
# [*post_cmd*]
#   The command to run after installing a profile (usually to restart a daemon).
#   If unset (default), no command is run after installing the profile.
#
# === Variables
#
# [*lsbdistrelease*]
#   The LSB distribution release number (normally provided as a fact).
#
# === Examples
#
# apparmor::profile { 'usr.sbin.nsd':
#   $local_source => true,
#   $post_cmd     => 'service nsd3 restart',
# }
#
# apparmor::profile { 'usr.sbin.ssmtp': }
#
# apparmor::profile { 'usr.sbin.apt-cacher-ng':
#   source => 'puppet:///modules/bar/apt-cacher-ng/aa-profile',
# }
#
# === Authors
#
# Simon Deziel <simon.deziel@gmail.com>
#
# === Copyright
#
# Copyright 2012 Simon Deziel
#
define apparmor::profile (
  $default_base = "puppet:///modules/apparmor/aa-profiles/${::lsbdistrelease}",
  $source       = undef,
  $local_source = false,
  $post_cmd     = undef,
) {

  include apparmor
  $apparmor_d = $apparmor::apparmor_d

  if $source {
    $real_source = $source
  } else {
    $real_source = "${default_base}/${name}"
  }

  file { "${apparmor_d}/${name}":
    source => $real_source,
    notify => Exec["aa-enable-${name}"],
  }

  # Remove the "disable" symlink if any
  file { "${apparmor_d}/disable/${name}":
    ensure => absent,
    notify => Exec["aa-enable-${name}"],
  }

  if ($local_source == true) {
    $real_local_source = "${default_base}/local/${name}"
  } elsif ($local_source == false) {
    $real_local_source = undef
  } else {
    $real_local_source = $local_source
  }

  if $real_local_source {
    file { "${apparmor_d}/local/${name}":
      source => $real_local_source,
      notify => Exec["aa-enable-${name}"],
      # Make sure the local profile is installed first to avoid
      # calling apparmor_parser without the local profile.
      before => File["${apparmor_d}/${name}"],
    }
  }

  # (Re)load the profile and run the post command
  if $post_cmd {
    $command = "apparmor_parser -r -T -W ${apparmor_d}/${name} && ${post_cmd}"
  } else {
    $command = "apparmor_parser -r -T -W ${apparmor_d}/${name}"
  }
  exec { "aa-enable-${name}":
    command     => $command,
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    refreshonly => true,
  }
}
