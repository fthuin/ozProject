all: lib gameIntro characters map interface game run

lib:
	ozc -c lib.oz

gameIntro:
	ozc -c gameIntro.oz

characters:
	ozc -c characters.oz

map:
	ozc -c map.oz

interface:
	ozc -c interface.oz

fight:
	ozc -c fight.oz

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
