
OPTIONS := -g -m32 -Wall -Werror -fno-pie -no-pie

combs.out: combs.o main.o
	gcc $(OPTIONS) -o combs.out combs.o main.o
	
main.o: main.c combs.h
	gcc $(OPTIONS) -g -Wall -m32 -c -o main.o main.c
	
combs.o: combs.s
	gcc $(OPTIONS) -g -Wall -m32 -c -o combs.o combs.s
	
clean:
	rm *.o *.out
