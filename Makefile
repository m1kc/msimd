all: dmd

dmd:
	dmd *.d -ofmsimd -O -w -wi -unittest
	# -cov

gdc:
	gdc *.d -o msimd -O2 -Wall -funittest

#install:
#	install -D msimd ${DESTDIR}/usr/bin/msimd

clean:
	rm -f msimd *.o
