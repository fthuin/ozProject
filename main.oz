functor
import
   % OZ modules
   Application
   System
   % Module
   
   % Custom modules
   MapDrawing at 'map_drawing.ozf'
define
   {System.show game_started}

   Map =  map(r(1 1 1 0 0 0 0)
	      r(1 1 1 0 0 1 1)
	      r(1 1 1 0 0 1 1)
	      r(0 0 0 0 0 1 1)
	      r(0 0 0 1 1 1 1)
	      r(0 0 0 1 1 0 0)
	      r(0 0 0 0 0 0 0))
   MapHeight = {Width Map}
   MapWidth  = {Width Map.1}

   % Map configuration
   {MapDrawing.setSpeed 5}
   {MapDrawing.setDelay 200}
   {MapDrawing.setMap Map}
   {MapDrawing.drawMap}

   StartingPos = pos(x:MapWidth-1 y:MapHeight-1)
   {MapDrawing.drawPlayerAtPosition StartingPos}

   {MapDrawing.movePlayer left}
   {MapDrawing.movePlayer left}
   {MapDrawing.movePlayer up}
   {MapDrawing.movePlayer right}
   
   {System.show {MapDrawing.getParams}}
   {Application.exit 0}
end