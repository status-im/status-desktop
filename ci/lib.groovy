def parentOrCurrentBuild() {
  def c = currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)
  if (c == null) { return currentBuild }
  return c.getUpstreamRun()
}

def timestamp() {
  /* we use parent if available to make timestmaps consistent */
  def now = new Date(parentOrCurrentBuild().timeInMillis)
  return now.format('yyMMdd-HHmmss', TimeZone.getTimeZone('UTC'))
}

def gitCommit() {
  return env.GIT_COMMIT.take(6)
}

def pkgFilename(type, ext, arch=null) {
  /* the grep removes the null arch */
  return [
    "StatusIm", timestamp(), gitCommit(), type, arch,
  ].grep().join('-') + ".${ext}"
}

return this
