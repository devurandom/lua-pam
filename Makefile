ifeq ($(LUA_VERSION),)
LUA_VERSION=5.2
endif

ifeq ($(LUA_CPPFLAGS),)
LUA_CPPFLAGS=-I/usr/include/lua$(LUA_VERSION)
endif

ifeq ($(LUA_LIBS),)
LUA_LIBS=-llua$(LUA_VERSION)
endif

ifneq ($(DEBUG),)
EXTRA_CFLAGS+= -g -O0
endif

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
NO_UNDEFINED = -undefined,error
else
NO_UNDEFINED = --no-undefined
endif

CFLAGS=-Wall -Werror -pedantic -std=c99 -fPIC -D_XOPEN_SOURCE=700 $(EXTRA_CFLAGS)
CPPFLAGS=$(LUA_CPPFLAGS)
LDFLAGS=-Wl,$(NO_UNDEFINED) $(LUA_LDFLAGS)
LIBS=$(LUA_LIBS) -lpam

.PHONY: all
all: pam.so

pam.o: pam.c lextlib/lextlib.h
pam.so: pam.o lextlib/lextlib.o

.PHONY: clean
clean:
	$(RM) *.so *.o

.SUFFIXES: .o .so
.o.so:
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $@ $^ $(LIBS)
