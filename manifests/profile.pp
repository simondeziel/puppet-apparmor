#
# == Define: apparmor::profile
#
# Install an Apparmor profile and a local profile to add/override some rules
#
# === Parameters
#
# [*ensure*]
#  Enum variable that can be present (default) to install and load the profile.
#  Can be absent to unload and remove the profile files or disable to unload and
#  leave the profile files in place.
#
# [*default_base*]
#  Default path to use with $source and $local_source. If unset (default),
#  defaults to a distro specific path.
#
# [*source*]
#   Source path to the Apparmor profile. If unset (default), defaults to
#   "${default_base}/${name}".
#
# [*local_only*]
#   Boolean variable than can be true or false (default). If true, only the
#   contents of the local profile will be managed.
#
# [*local_content*]
#   Optional content to put in the local Apparmor profile file. Cannot be used
#   with local_source set non-false.
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
# Simon Deziel <simon@sdeziel.info>
#
# === Copyright
#
# Copyright 2012-2020 Simon Deziel
#
define apparmor::profile (
  Enum[
    'absent',
    'present',
    'disable']            $ensure        = 'present',
  Optional[String]        $default_base  = $apparmor::profile_default_base,
  Optional[String]        $source        = undef,
  Boolean                 $local_only    = false,
  Optional[String]        $local_content = undef,
  Variant[Boolean,String] $local_source  = false,
  Optional[String]        $post_cmd      = undef,
) {

  include apparmor
  $apparmor_d = $apparmor::apparmor_d

  if $ensure == 'present' {
    if $local_source and $local_content {
      fail('apparmor::profile: local_source has to be set to false to use local_content')
    }

    if $local_only {
      $real_source = undef
    } elsif $source {
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

    if $real_local_source or $local_content {
      file { "${apparmor_d}/local/${name}":
        content => $local_content,
        source  => $real_local_source,
        notify  => Exec["aa-enable-${name}"],
        # Make sure the local profile is installed first to avoid
        # calling apparmor_parser without the local profile.
        before  => File["${apparmor_d}/${name}"],
      }
    }

  } elsif $ensure == 'absent' {
    file { ["${apparmor_d}/${name}","${apparmor_d}/local/${name}","${apparmor_d}/disable/${name}"]:
      ensure  => absent,
      require => Exec["aa-disable-${name}"],
    }
  } else {
    # Create the "disable" symlink
    file { "${apparmor_d}/disable/${name}":
      ensure => link,
      target => "${apparmor_d}/${name}",
      notify => Exec["aa-disable-${name}"],
    }
  }

  # (Re)load/remove the profile and run the post command
  if $post_cmd {
    $enable_command  = "apparmor_parser -r -T -W ${apparmor_d}/${name} && ${post_cmd}"
    $disable_command = "apparmor_parser -R ${apparmor_d}/${name} && ${post_cmd}"
  } else {
    $enable_command  = "apparmor_parser -r -T -W ${apparmor_d}/${name}"
    $disable_command = "apparmor_parser -R ${apparmor_d}/${name}"
  }

  Exec {
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    onlyif      => 'aa-status --enabled',
    refreshonly => true,
  }
  exec { "aa-enable-${name}":
    command => $enable_command,
  }
  exec { "aa-disable-${name}":
    command => $disable_command,
  }
}
