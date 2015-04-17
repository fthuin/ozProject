all: map main run

main:
	ozc -c main.oz -o main.oza

map:
	ozc -c map_drawing.oz

run:
	ozengine ./main.oza

compileImages:
	ozc -c compile_images.oz -o compile_images.oza
	ozengine ./compile_images.oza
