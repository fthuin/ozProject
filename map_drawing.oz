functor
import
   Module
   System
export  
   SetMap
   SetSpeed
   SetDelay
   GetParams
   DrawMap
   DrawPlayerAtPosition
   MovePlayer
define
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   ImageLibrary = {QTk.loadImageLibrary "ImageLibrary.ozf"}

   % Constants
   CANVAS_OFFSET_BUG = 3
   TILE_SIZE = 80
   GRASS = 0
   ROAD = 1
   
   % Params
   Speed
   Map
   DelayParam
   TurnDuration

   % Local variables
   MapHeight
   MapWidth
   
   MapCanvasHandle
   PlayerHandle
   MapWindow

   % Private methods
   proc {Debug Msg}
      {System.show Msg}
   end
   
   fun {GetImage Name}
      {ImageLibrary get(name:Name image:$)}
   end

   fun {TurnDuration}
      (10-Speed)*DelayParam
   end

   % Coordinates from position helpers
   fun {XCoord XPosition}
      (XPosition*TILE_SIZE)+CANVAS_OFFSET_BUG
   end

   fun {YCoord YPosition}
      (YPosition*TILE_SIZE)+CANVAS_OFFSET_BUG
   end

   % Animations helpers
   fun {GetCoords Handle}
      {Handle getCoords(1:$)}
   end

   fun {GetXPos Handle}
      {FloatToInt {GetCoords Handle}.1}
   end

   fun {GetYPos Handle}
      {FloatToInt {GetCoords Handle}.2.1}
   end

   proc {SetXPos Handle X}
      {Handle setCoords(X {GetYPos Handle})}
   end

   proc {SetYPos Handle Y}
      {Handle setCoords({GetXPos Handle} Y)}
   end

   proc {IncrementXPos Handle Inc}
      {SetXPos Handle {GetXPos Handle}+Inc}
   end

   proc {IncrementYPos Handle Inc}
      {SetYPos Handle {GetYPos Handle}+Inc}
   end

   % Public methods

   % Setters
   proc {SetMap M}
      Map       = M
      MapHeight = {Width Map}
      MapWidth  = {Width Map.1}
   end

   proc {SetSpeed S}    Speed = S       end
   proc {SetDelay D}    DelayParam = D  end

   fun {GetParams}
      params(delay:DelayParam speed:Speed map:Map)
   end
   
   proc {DrawMap}
      proc {CreateMapCanvas} MapCanvas in
	 MapCanvas = canvas(width:MapWidth*TILE_SIZE height:MapHeight*TILE_SIZE handle:MapCanvasHandle)
	 MapWindow = {QTk.build lr(MapCanvas)}
      end

      fun {AddTileAt Type X Y} ImageName in
	 ImageName = if Type==GRASS then texture_grass elseif Type==ROAD then texture_road end
	 create(image {XCoord X} {YCoord Y} anchor:nw image:{GetImage ImageName})
      end
   
      proc {DrawRow RowRecord RowNumber}
	 proc {RecDrawRow TilesList X}
	    case TilesList
	    of nil then skip
	    [] H|T then
	       {MapCanvasHandle {AddTileAt H X RowNumber}}
	       {RecDrawRow T X+1} 
	    end
	 end
      in
	 {RecDrawRow {Record.toList RowRecord} 0}
      end
      
      proc {Draw}
	 proc {RecDraw RowsList RowNumber}
	    case RowsList
	    of nil then skip
	    [] Row|RemainingRows then
	       {DrawRow Row RowNumber}
	       {RecDraw RemainingRows RowNumber+1}
	    end
	 end
      in
	 {RecDraw {Record.toList Map} 0}
      end
   in
      {CreateMapCanvas}
      {Draw}
      {MapWindow show}
      {Debug map_drawn}
   end

   proc {DrawPlayerAtPosition Pos}
      {MapCanvasHandle create(image {XCoord Pos.x} {YCoord Pos.y} image:{GetImage sacha_down_3} anchor:nw handle:PlayerHandle)}
      {Debug player_positioned_at(Pos)}
   end

   proc {MovePlayer Direction}
      IMAGE_STEPS    = 4
      STEPS_BY_MOVE  = 8
      STEP_DURATION  = {TurnDuration} div STEPS_BY_MOVE
      STEP_INCREMENT = TILE_SIZE div STEPS_BY_MOVE
      
      proc {MoveImageOneStep}
	 case Direction
	 of up    then {IncrementYPos PlayerHandle ~STEP_INCREMENT}
	 [] right then {IncrementXPos PlayerHandle  STEP_INCREMENT}
	 [] down  then {IncrementYPos PlayerHandle  STEP_INCREMENT}
	 [] left  then {IncrementXPos PlayerHandle ~STEP_INCREMENT}
	 end
      end
      
      proc {SetImageForStep Step} ImageName in
	 ImageName = {VirtualString.toAtom "sacha_"#Direction#"_"#(Step mod IMAGE_STEPS)}
	 {PlayerHandle set(image:{GetImage ImageName})}
      end
      
      proc {Anim Step}
	 if Step==STEPS_BY_MOVE then skip
	 else
	    {SetImageForStep Step}
	    {MoveImageOneStep}
	    {Debug anim}
	    {Debug STEP_DURATION}
	    {Debug {TurnDuration}}    
	    {Delay STEP_DURATION}
	    {Debug anim}
	    {Anim Step+1} 
	 end
      end
   in
      {Anim 0}
   end
end