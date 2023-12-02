CC=g++
FLAGS=-ggdb -Wall -g


all: asm85.cpp imagestore.cpp instructions.cpp symboltable.cpp scanner.cpp
	$(CC) $(FLAGS) imagestore.cpp -c
	$(CC) $(FLAGS) instructions.cpp -c
	$(CC) $(FLAGS) scanner.cpp -c
	$(CC) $(FLAGS) symboltable.cpp -c
	$(CC) $(FLAGS) asm85.cpp imagestore.o instructions.o scanner.o symboltable.o -o asm85

clean:
	rm -f asm85 *.o
	rm -rf asm85.dSYM
