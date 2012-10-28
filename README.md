# msimd

An experimental mSIM server written in D.

## Building and running

Requirements:

* D compiler (dmd)

To build msimd, just type:

    make
    
To run:

    ./main
    
msimd uses port 3215 by default. Override it with the `--port` option:

    ./main --port 8080
