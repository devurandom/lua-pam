CFLAGS=-Wall -Werror -std=c99 -g -fPIC -Ilibuv/include -I/usr/include -D_XOPEN_SOURCE=700 -DLUV_STACK_CHECK -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
LIBS=-lm -lrt -lpam

all: pam.so pam_util.so

pam.o: pam.c lextlib/lextlib.h
pam.so: pam.o lextlib/lextlib.o

pam_util.o: pam_util.c lextlib/lextlib.h
pam_util.so: pam_util.o lextlib/lextlib.o term_util/term_util.o

#term_util/term_util.a: term_util
#	$(MAKE) $(MAKEFLAGS) -C term_util term_util.a

clean:
	$(RM) *.so *.o

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

%.so: %.o
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $@ $^ $(LIBS)
