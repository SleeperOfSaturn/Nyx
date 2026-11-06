{ ... }:

{
  fileSystems."/mnt/shared" = {
    device = "/dev/disk/by-uuid/01DC6EFDC8E3B620";
    fsType = "ntfs-3g";

    options = [
      "uid=1000"
      "gid=1000"
      "umask=000"
      "noatime"
      "nofail"
      "x-gvfs-show"
    ];
  };
}
