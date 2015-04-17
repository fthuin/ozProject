all: lib map interface game run

lib:
	ozc -c lib.oz

map:
	ozc -c map.oz

interface:
	ozc -c interface.oz

game:
	ozc -c game.oz -o game.oza

run:
	ozengine ./game.oza

compileImages:
	ozc -c compile_images.oz -o compile_images.oza
	ozengine ./compile_images.oza

clean:
	rm ./*.ozf
	rm ./*.oza
