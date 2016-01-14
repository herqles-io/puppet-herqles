define herqles::framework::framework_data (
  $module,
  $pkgname,
  $version='present',
  $repo=undef,
  $install_args=undef,
) {

  validate_string($module)
  validate_string($pkgname)
  validate_string($version)
  if $repo != undef {
    validate_string($repo)
  }

}
