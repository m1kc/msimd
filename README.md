# msimd [![Build Status](https://travis-ci.org/m1kc/msimd.png?branch=master)](https://travis-ci.org/m1kc/msimd)

An experimental mSIM server written in D.

## Building and running

Requirements:

* D compiler (dmd)
* make

To build msimd, just type:

    make
    
To run:

    ./main
    
msimd uses port 3215 by default. Override it with the `--port` option:

    ./main --port 8080
