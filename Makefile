SRC = src/lz4jsoncat.c
TARGET = bin/lz4jsoncat

PKG_CONFIG ?= pkg-config
CFLAGS := -g -O2 -Wall
LDLIBS := $(shell $(PKG_CONFIG) --cflags --libs liblz4)

$(TARGET): $(SRC)
	mkdir -p bin
	$(CC) $(CFLAGS) $(SRC) $(LDLIBS) -o $(TARGET)

clean:
	rm -rf bin

.PHONY: clean
