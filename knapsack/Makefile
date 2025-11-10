
OPTIONS := -g -m32 -Wall -Werror -fno-pie -no-pie

knapsack.out: knapsack.o main.o
	gcc $(OPTIONS) -o knapsack.out knapsack.o main.o

knapsack.o: knapsack.s
	gcc $(OPTIONS) -c -o knapsack.o knapsack.s

main.o: main.c
	gcc $(OPTIONS) -c -o main.o main.c

clean:
	rm -f *.o *.out
