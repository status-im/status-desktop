{ callPackage }:
callPackage ./binary.nix {
  version = "1.21.11";
  hashes = {
    # Use `print-hashes.sh ${version}` to generate the list below
    darwin-amd64 = "a3efff72f7aba31c85b53ebfd3985d0e3157a87b0e69e178161ba7097c197885";
    darwin-arm64 = "0142f5ac9f9a1bf19b826ee08a8c7955a745f7a2e62d36e0566d29fcac4d88e0";
    linux-386 = "8b00cbc2519c2d052177bf2c8472bf06578d3b0182eeb3406a1d7d4e5d4c59ef";
    linux-amd64 = "54a87a9325155b98c85bc04dc50298ddd682489eb47f486f2e6cb0707554abf0";
    linux-arm64 = "715d9a7ff72e4e0e3378c48318c52c6e4dd32a47c4136f3c08846f89b2ee2241";
    linux-armv6l = "a62bff8297816a387a36bbda2889dd0dbcf0f8ce03bc62162ecd6918d6acecb5";
    linux-loong64 = "19c738e3670efb6581a91d7d93e719080ccf710684938d015ab3e7ca044715be";
    linux-mips = "4240bd1a4ca8ab664ead554b418bd1b1f319b063258763ade44f81a4dd018e61";
    linux-mips64 = "6245001da9e2c39698f97543019f9faf4813f0564e471ec654f4698e0b9f19eb";
    linux-mips64le = "d10166bb6ea6538e24f01ac9bcbbbaee5657d07b9edc11a82cbf569355a36534";
    linux-mipsle = "8ab7e1af86845aa39bc93e1ae7e58f79a0b8df59783129c3b73aa0379f693c4a";
    linux-ppc64 = "2939e56894877c51eb9c579f55588b80c77f38481240042512307ad1db5b3dd8";
    linux-ppc64le = "6f5e18187abc4ff1c3173afbe38ef29f84b6d1ee7173f40075a4134863b209a5";
    linux-riscv64 = "3ee5f9aac2f252838d88bb4cf93560c567814889c74d87ad8a04be16aa5e1b21";
    linux-s390x = "489c363d5da2d3d5709419bda61856582c5ebdc7874ca7ecdebf67d736d329e6";
  };
}
