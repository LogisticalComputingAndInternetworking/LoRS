SHAREDOPT = 
LIBDIR = /usr/lib
INCDIR = /usr/include
AR = ar
CC = gcc
INCS =  -Iinclude/ -I.
FLAGS = -Wall

all: src/ecgi.o src/ecgitk.o libecgi.a
	make -C html2h/

shared: libecgi.so
	cp libecgi.so /usr/lib

libecgi.a: src/ecgi.o src/ecgitk.o
	ar rs libecgi.a src/ecgi.o src/memfile.o src/ecgitk.o

libecgi.so: src/ecgi.o src/ecgitk.o
	gcc $(SHAREDOPT) src/ecgi.o src/memfile.o src/ecgitk.o -o libecgi.so

install:
	cp libecgi.a $(LIBDIR)
	cp ecgi.h $(INCDIR)
	cp include/memfile.h $(INCDIR)
	cp ecgitk.h $(INCDIR)
	make -C html2h/ install
	cp libecgi.so $(LIBDIR)

tests:	all
	$(CC) tests/test.c -o tests/test.cgi $(INCS) $(FLAGS) libecgi.a
	$(CC) tests/testload.c -o tests/testload libecgi.a $(INCS) $(FLAGS)

src/ecgi.o: src/ecgi.c ecgi.h src/memfile.o
	$(CC) -c src/ecgi.c $(INCS) $(FLAGS) -o src/ecgi.o

src/memfile.o:  src/memfile.c include/memfile.h
	$(CC) -o src/memfile.o -c src/memfile.c $(INCS) $(FLAGS)

src/ecgitk.o: src/ecgitk.c ecgitk.h
	$(CC) -c src/ecgitk.c $(INCS) $(FLAGS) -o src/ecgitk.o

clean:
	rm -f src/* *.a *.so -f tests/test.cgi tests/testload
	make -C html2h/ clean

zip: clean
	rm -f ../ecgi-0.6.2.zip
	(cd ..; zip -r ecgi-0.6.2.zip ecgi-0.6.2*)
