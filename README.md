# boot4u
U-Boot loader for PW-x1

# Build

```sh
apt install gcc-arm-linux-gnueabihf
pip3 install pyelftools
make
```

# Run
 - Create a directory `/path/to/sd/APP/foo`
 - Create index.din `touch /path/to/sd/APP/foo/index.din`
 - Copy and rename the raw executable `cp AppMain.bin /path/to/sd/APP/foo/AppMain.bin`
