{
  nixpkgsSrc,
  nixpkgsOldSrc,
}:

self: super: let
  # TODO: helper function, move
  removeMany = itemsToRemove: list: super.lib.foldr super.lib.remove list itemsToRemove;
  inherit (super) callPackage;

  # takes in a *string* name of a glibc package e.g. "glibcInfo"
  #
  # the general idea is to mix the attributes from the old glibc an from the
  # the new glibc in a way that gets us an older version of glibc but is
  # compatible with the new gcc and the changes to nixpkgs. this took a lot of
  # trial and error, and will probably have to be updated as nixpkgs
  # progresses.
  #
  # Originaly used code (for glibc 2.24):
  # https://github.com/matthewbauer/nix-bundle/blob/5e1e68dab10013871481d922038c6be57da92dc7/appimage/glibc_2_24/default.nix
  glibcAdapter = glibcPkg:
    super.${glibcPkg}.overrideAttrs (
      attrs: let
        oldGlibcPkg = (import nixpkgsOldSrc {inherit (super) system;}).${glibcPkg};
        glibcDir = "pkgs/development/libraries/glibc";
        oldGlibcDir = "${nixpkgsOldSrc}/${glibcDir}";
        newGlibcDir = "${nixpkgsSrc}/${glibcDir}";

      in {
        inherit (oldGlibcPkg) name src;

        # TODO: double check other attrs:
        # name, pname
        # meta.maintainer
        # strictDeps
        # buildInputs: bison, python versions
        # linuxHeaders 5.5 -> 6.2
        # makeFlags: OBJCOPY, OBJDUMP
        # preConfigure

        # TODO: modify versions, what's libgcc?
        passthru = attrs.passthru;

        patches =
          oldGlibcPkg.patches
          ++ [
          # TODO: apply patch from super?
            # has to do with new gcc not new glibc
            #"${newGlibcDir}/fix-x64-abi.patch"
            #"${newGlibcDir}/0001-Revert-Remove-all-usage-of-BASH-or-BASH-in-installed.patch"
          ];

        # TODO: anything from super?
        postPatch = oldGlibcPkg.postPatch;

        # TODO: check old and new flags
        # modifications from old glibc
        configureFlags =
          # we can maintain compatiblity with older kernel (see below)
          removeMany [
            "--enable-kernel=3.10.0"
            "--enable-static-pie"
            #"--enable-stack-protector=strong"
            #"--enable-bind-now"
            #"--enable-cet"
            #"--disable-crypt"
          ] (attrs.configureFlags or [])
          ++ [
            #"--enable-obsolete-rpc"
            #"--enable-obsolete-nsl"
            #"--enable-stackguard-randomization"
          ]
          ++ super.lib.optionals
          # (we don't have access to withLinuxHeaders from here)
          (attrs.env.linuxHeaders != null) [
            "--enable-kernel=3.2.0"
          ];

        CFLAGS =
          # TODO: reuse CFLAGS from super attrs
          "-O2 -g"
          # new gcc introduces new warnings which we must disable
          # (see https://github.com/NixOS/nixpkgs/pull/71480)
          + " -Wno-error=array-parameter"
          + " -Wno-error=stringop-overflow"
          + " -Wno-error=use-after-free"
          + " -Wno-error=array-bounds"
          + " -Wno-error=format-overflow"
          # Fix for issue introduced with gcc 11 optimisation:
          # genhooks: No place specified to document hook TARGET_ASM_OPEN_PAREN
          # disabling it here. Alternative is to apply glibc compatibility patch.
          # See:
          # - https://www.gnu.org/software/gcc/gcc-11/changes.html
          # - https://github.com/microsoft/CBL-Mariner/pull/1574/commits/7e51d4af1b77b096351a8656b6b042ff994bf8ca
          # - https://sourceware.org/git/?p=glibc.git;a=commit;h=c0e9ddf59e73
          + " -fno-ipa-modref";
      }
    );
in rec {
  # TODO: check anything else needed?
  glibc = glibcAdapter "glibc";
  glibcLocales = glibcAdapter "glibcLocales";
  glibcInfo = glibcAdapter "glibcInfo";

  linuxdeployqt = callPackage ./linuxdeployqt.nix { inherit (super.qt515) qmake; };

  # for debug
  old = import nixpkgsOldSrc {};
  glibcSuper = super.glibc;

  # Disable flacky test
  # https://github.com/NixOS/nixpkgs/pull/243509
  openldap = super.openldap.overrideAttrs (attrs: {
      preCheck = attrs.preCheck
      + "\nrm -f tests/scripts/test063-delta-multiprovider";
      });

  # TODO: fix dependencies.
  # Alternative workaround - add old derivations (libunistring, libidn2)
  # https://github.com/flatironinstitute/nix-modules/blob/master/stdenv.nix
  # https://github.com/NixOS/nixpkgs/commit/505e94256ef247dc5425068304583f8dc1b2064a
  stdenv = super.stdenv.override {
    allowedRequisites = null;
  };
}
