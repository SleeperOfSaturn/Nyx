( ... ):

{
  boot.kernelPatches = [
    {
      name = "rust-1.98-x86-softfloat";
      patch = ../patches/rust-1.98-kernel-abi.patch;
    }
  ];
}
