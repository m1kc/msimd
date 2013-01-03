TARGET=msimd
SOURCES=$(wildcard *.d)
OBJECTS=$(SOURCES:%.d=%.o)

all: dmd

dmd:
	dmd $(SOURCES) -of$(TARGET) -O -w -wi -unittest # -cov

gdc:
	gdc $(SOURCES) -o $(TARGET) -O2 -Wall -funittest

#install:
#	install -D $(TARGET) ${DESTDIR}/usr/bin/$(TARGET)

clean:
	rm -f $(TARGET) $(TARGET).o $(OBJECTS)
