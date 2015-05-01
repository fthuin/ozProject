functor
import
   Pickle
   Module
   Lib at 'lib.ozf'
export
   Init
   DrawMap
   DrawPlayerAtPosition
   DrawHospitalAtPosition
   DrawPikachuAtPosition
   DrawBrockAtPosition
   DrawMistyAtPosition
   DrawJamesAtPosition
   MovePlayer
   IsRoad
   LoadMapFromFile
define
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   ImageLibrary = {QTk.loadImageLibrary "ImageLibrary.ozf"}

   % Constants
   CANVAS_OFFSET_BUG = 3
   TILE_SIZE = 80
   GRASS = 0
   ROAD  = 1

   % Params
   Map
   Speed
   DelayParam
   InstructionsPort

   % Local variables
   MapHeight
   MapWidth

   % Handles
   MapCanvasHandle
   PlayerHandle
   BrockHandle
   MistyHandle
   JamesHandle
   MapWindow

   % Private methods

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

   % Bind keys
   proc {BindKeyboardActions}
      {MapWindow bind(event:"<Up>"    action:proc{$} {Send InstructionsPort up}     end)}
      {MapWindow bind(event:"<Left>"  action:proc{$} {Send InstructionsPort left}   end)}
      {MapWindow bind(event:"<Down>"  action:proc{$} {Send InstructionsPort down}   end)}
      {MapWindow bind(event:"<Right>" action:proc{$} {Send InstructionsPort right}  end)}
      {MapWindow bind(event:"<space>" action:proc{$} {Send InstructionsPort finish} end)}
      {Lib.debug keyboard_actions_bound}
   end

   % Public methods

   proc {Init M P S D}
      Map               = M
      Speed             = S
      DelayParam        = D
      InstructionsPort  = P
      MapHeight         = {Width Map}
      MapWidth          = {Width Map.1}
   end

   proc {DrawMap}
      proc {CreateMapCanvas} MapCanvas in
	       MapCanvas = canvas(width:MapWidth*TILE_SIZE height:MapHeight*TILE_SIZE handle:MapCanvasHandle)
         MapWindow = {QTk.build lr(MapCanvas)}
      end

      fun {AddTileAt Type X Y} ImageName in
        ImageName = if Type==GRASS then textures_grass elseif Type==ROAD then textures_road end
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
      {BindKeyboardActions}
      {Lib.debug map_drawn}
   end

   proc {DrawImageAtPosition Image Pos Handle}
     {MapCanvasHandle create(image {XCoord Pos.x} {YCoord Pos.y} handle:Handle image:{GetImage Image} anchor:nw)}
   end

   proc {DrawPlayerAtPosition Pos}
      {DrawImageAtPosition sacha_down3 Pos PlayerHandle}
      {Lib.debug player_positioned_at(Pos)}
   end

   proc {DrawBrockAtPosition Pos}
     {DrawImageAtPosition characters_brock_small Pos BrockHandle}
     {Lib.debug brock_positioned_at(Pos)}
   end

   proc {DrawMistyAtPosition Pos}
     {DrawImageAtPosition characters_misty_small Pos MistyHandle}
     {Lib.debug misty_positioned_at(Pos)}
   end

   proc {DrawJamesAtPosition Pos}
     {DrawImageAtPosition characters_james_small Pos JamesHandle}
     {Lib.debug james_positioned_at(Pos)}
   end

   proc {DrawHospitalAtPosition Pos}
     {DrawImageAtPosition various_hospital Pos _}
     {Lib.debug hospital_positioned_at(Pos)}
   end

   proc {DrawPikachuAtPosition Pos}
     {DrawImageAtPosition various_pikachu Pos _}
     {Lib.debug pikachu_positioned_at(Pos)}
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
        ImageName = {VirtualString.toAtom "sacha_"#Direction#(Step mod IMAGE_STEPS)}
        {PlayerHandle set(image:{GetImage ImageName})}
      end

      proc {Anim Step}
        if Step==STEPS_BY_MOVE then skip
        else
          {SetImageForStep Step}
          {MoveImageOneStep}
          {Delay STEP_DURATION}
          {Anim Step+1}
        end
      end
    in
      {Anim 0}
    end

    fun {IsRoad Position}
      Map.(Position.y+1).(Position.x+1) == ROAD
    end

    proc {LoadMapFromFile Path Map}
       Map = {Pickle.load Path}
    end

end
