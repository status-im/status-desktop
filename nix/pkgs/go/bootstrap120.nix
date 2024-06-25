{ callPackage }:
callPackage ./binary.nix {
  version = "1.20.13";
  hashes = {
    # Use `print-hashes.sh ${version}` to generate the list below
    darwin-amd64 = "713051aa0da66839f5a31a8ec677a7c61717b6fba62bf47eadb25542df3e9ee7";
    darwin-arm64 = "4b7e8d0260b7376c77a0caea7b19dad6e1426c316671a15bc31036f92af2eb12";
    linux-386 = "4da6f08510a21b829a065d3f99914bfbe1d8b212664cea230485a64e7e6d00d8";
    linux-amd64 = "9a9d3dcae2b6a638b1f2e9bd4db08ffb39c10e55d9696914002742d90f0047b5";
    linux-arm64 = "a2d811cef3c4fc77c01195622e637af0c2cf8b3814a95a0920cf2f83b6061d38";
    linux-armv6l = "d4c6c671423ce6eef3f240bf014115b2673ad6a89e12429b5a331b95952c7279";
    linux-ppc64le = "5f632b83323e16f8c6ceb676cd570b3f13f1826e06a81d92985d1301b643a7d3";
    linux-s390x = "ae6c8f75df9b15c92374cfeae86e97d2744d4d4cdafcb999fea5b63e20c22651";
  };
}
