# PokemOz Project

In this directory, you can find all the .oz files you need to run the
Pokemoz Project.

We give you a makefile to make the compilation way simplier, open a
console from here and type the following command lines :

$ make compileImages
$ make

If the project is already built, you can just type this command line in
the console :

$ make run

If the project is already built and you want to add parameters to the
program, you can type :

ozengine ./game.oza [options] [params]

The following options are accepted :

-m, --map FILEPATH (a file containing a map)
-p, --probability INT (probability to find a wild pokemoz in tall grass)
-s, --speed INT (speed of your pokemoz trainer)
-a, --autofight BOOL (choice of an automatic game or not)
-h, -?, --help (a help about the arguments)
