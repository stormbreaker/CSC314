

OBJS=playmusic.o  assembly.o

LFLAGS=

CFLAGS=-I. -O3

SFLAGS=


playmusic: $(OBJS)
	gcc -o playmusic $(OBJS) -lm -pg

.S.o:
	gcc  $(SFLAGS) -c $< 

.c.o:
	gcc $(CFLAGS) -c $<

clean:
	rm -f *.o *~ playmusic tmp.data
