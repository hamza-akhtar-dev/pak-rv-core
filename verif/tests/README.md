
This direcotry contains all the tests compatible on pak-rv-core. 

### build
To build test do `make clean; make` in the test dir. 

### custome build
Make sure to replicate the same direcory structure as basic_test and copy all the relevent files such as Makefile, linker etc in your test dir, after compilation make sure to copy the `test.mem` file in `TESTBUILD_DIR` so, that testbench can read it.