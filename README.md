# boot4u
U-Boot loader for PW-x1

# Preparation

1. Install requirements

   ```shellsession
   $ apt install gcc-arm-linux-gnueabihf
   $ pip3 install -r requirements.txt
   ```

2. Put image.jpg in this directory

   - The size must be 480x854 (rotate the picture 90 deg clockwise)

# Build

```sh
make
```

# Run
 - Create a directory `/path/to/sd/APP/foo`
 - Create index.din `touch /path/to/sd/APP/foo/index.din`
 - Copy and rename the raw executable `cp AppMain.bin /path/to/sd/APP/foo/AppMain.bin`
