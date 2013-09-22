sudo sysctl -w vm.mmap_min_addr=0 #icky workaround to run MS-DOS
wine ~/bin/devpac8x/DEVPAC8X.COM "$@"
