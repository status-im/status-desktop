{ callPackage }:
callPackage ./binary.nix {
  version = "1.22.3";
  hashes = {
    # Use `print-hashes.sh ${version}` to generate the list below
    darwin-amd64 = "610e48c1df4d2f852de8bc2e7fd2dc1521aac216f0c0026625db12f67f192024";
    darwin-arm64 = "02abeab3f4b8981232237ebd88f0a9bad933bc9621791cd7720a9ca29eacbe9d";
    linux-386 = "fefba30bb0d3dd1909823ee38c9f1930c3dc5337a2ac4701c2277a329a386b57";
    linux-amd64 = "8920ea521bad8f6b7bc377b4824982e011c19af27df88a815e3586ea895f1b36";
    linux-arm64 = "6c33e52a5b26e7aa021b94475587fce80043a727a54ceb0eee2f9fc160646434";
    linux-armv6l = "f2bacad20cd2b96f23a86d4826525d42b229fd431cc6d0dec61ff3bc448ef46e";
    linux-loong64 = "41e9328340544893482b2928ae18a9a88ba18b2fdd29ac77f4d33cf1815bbdc2";
    linux-mips = "cf4d5faff52e642492729eaf396968f43af179518be769075b90bc1bf650abf6";
    linux-mips64 = "3bd009fe2e3d2bfd52433a11cb210d1dfa50b11b4c347a293951efd9e36de945";
    linux-mips64le = "5913b82a042188ef698f7f2dfd0cd0c71f0508a4739de9e41fceff3f4dc769b4";
    linux-mipsle = "441afebca555be5313867b4577f237c7b5c0fff4386e22e47875b9f805abbec5";
    linux-ppc64 = "f3b53190a76f4a35283501ba6d94cbb72093be0c62ff735c6f9e586a1c983381";
    linux-ppc64le = "04b7b05283de30dd2da20bf3114b2e22cc727938aed3148babaf35cc951051ac";
    linux-riscv64 = "d4992d4a85696e3f1de06cefbfc2fd840c9c6695d77a0f35cfdc4e28b2121c20";
    linux-s390x = "2aba796417a69be5f3ed489076bac79c1c02b36e29422712f9f3bf51da9cf2d4";
  };
}
