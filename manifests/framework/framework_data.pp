define herqles::framework::framework_data (
  $module,
  $pkgname,
  $version='present',
  $repo=undef,
  $install_args=[]
) {

  validate_string($module)
  validate_string($pkgname)
  validate_string($version)
  if $repo != undef {
    validate_string($repo)
  }
  validate_array($install_args)

}
