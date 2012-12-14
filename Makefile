ifeq ($(LUA_VERSION),)
LUA_VERSION=5.2
endif

CFLAGS=-Wall -Werror -std=c99 -g -fPIC -I/usr/include/lua$(LUA_VERSION) -D_XOPEN_SOURCE=700
LDFLAGS=-Wl,--no-undefined
LIBS=-llua$(LUA_VERSION) -lpam

all: pam.so pam_util.so

pam.o: pam.c lextlib/lextlib.h
pam.so: pam.o lextlib/lextlib.o

pam_util.o: pam_util.c lextlib/lextlib.h
pam_util.so: pam_util.o lextlib/lextlib.o lua-term/term.o

clean:
	$(RM) *.so *.o

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

%.so: %.o
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $@ $^ $(LIBS)
