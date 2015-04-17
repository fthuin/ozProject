all:
	ozc -c map_drawing.oz
	ozc -c main.oz -o main.oza
	ozengine ./main.oza

compileImages:
	ozc -c compile_images.oz -o compile_images.oza
	ozengine ./compile_images.oza