declare
DEBUG = true
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
BASE_PATH = "/Users/Greg/Desktop/ozProject/"

% Constants
ATTACK_DAMAGE
LEVELS_HP_AND_HP_NEEDED
POKEMOZ_BASE_LEVEL  = 5
POKEMOZ_BASE_XP     = 0
GRASS               = 0
ROAD                = 1

DELAY            = 200
TILE_SIZE        = 80
PLAYER_START_POS = pos(x:0 y:0)

BULBASOZ   = pokemoz(name:bulbasoz   type:grass level:POKEMOZ_BASE_LEVEL health:20 xp:POKEMOZ_BASE_XP)
OZTIRTLE   = pokemoz(name:oztirtle   type:water level:POKEMOZ_BASE_LEVEL health:20 xp:POKEMOZ_BASE_XP)
CHARMANDOZ = pokemoz(name:charmandoz type:fire  level:POKEMOZ_BASE_LEVEL health:20 xp:POKEMOZ_BASE_XP)

% Game parameters
WildPokemozProba = 5
Speed            = 5
AutoFight        = false

Map=   map(r(1 1 1 0 0 0 0)
	   r(1 1 1 0 0 1 1)
	   r(1 1 1 0 0 1 1)
	   r(0 0 0 0 0 1 1)
	   r(0 0 0 1 1 1 1)
	   r(0 0 0 1 1 0 0)
	   r(0 0 0 0 0 0 0))

% Parameters to ask
PlayerName      = greg
StartingPokemoz = CHARMANDOZ

% Game state
Brock        = player(name:brock   position:pos(x:2 y:2) pokemoz:[BULBASOZ]) % TODO: Add random starting position + random number of enemy trainers.
James        = player(name:james   position:pos(x:4 y:4) pokemoz:[OZTIRTLE])
Ritchie      = player(name:ritchie position:pos(x:5 y:5) pokemoz:[OZTIRTLE])
Player       = player(name:PlayerName position:PLAYER_START_POS pokemoz:[StartingPokemoz])
MapInfo      = map_info(map:Map height:{Width Map} width:{Width Map.1})
Game         = game(map_info:MapInfo player:Player enemy_trainers:[Brock James Ritchie])

% Drawing references
PlayerImage
MapWindow
MapCanvas
MapCanvasHandle

Drawings = drawings(player:PlayerImage
		    map:mapRefs(window:MapWindow canvas_handle:MapCanvasHandle)
		   )

% Debug helper
proc {Debug String}
   if DEBUG then {Browse String} else skip end
end

% Images helper
ImageLibrary = {QTk.loadImageLibrary BASE_PATH#"ImagesLibrary.ozf"}

fun {GetImage Name}
   {ImageLibrary get(name:Name image:$)}
end

fun {PlayerImagePosition}
   pos(x:Game.player.position.x*TILE_SIZE y:Game.player.position.y*TILE_SIZE)
end

% Time helpers
fun {TurnDuration}
   (10-Speed)*DELAY
end

% Animations

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

proc {AnimPlayer Direction}
   IMAGE_STEPS    = 4
   STEPS_BY_MOVE  = 8
   STEP_DURATION  = {TurnDuration} div STEPS_BY_MOVE
   STEP_INCREMENT = TILE_SIZE div STEPS_BY_MOVE
   
   proc {MoveImageOneStep}
      case Direction
      of up    then {IncrementYPos Drawings.player ~STEP_INCREMENT}
      [] right then {IncrementXPos Drawings.player STEP_INCREMENT}
      [] down  then {IncrementYPos Drawings.player STEP_INCREMENT}
      [] left  then {IncrementXPos Drawings.player ~STEP_INCREMENT}
      end
   end

   proc {SetImageForStep Step} ImageName in
      ImageName = {VirtualString.toAtom "sacha_"#Direction#"_"#(Step mod IMAGE_STEPS)}
      {Drawings.player set(image:{GetImage ImageName})}
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

 
% Return a widget that represents a pokemoz' state.
fun {PokemozArea Pokemoz}
   fun {Label Text}
      label(init:Text glue:w font:{QTk.newFont font(weight:bold)})
   end
   fun {Value Text}
      label(init:Text glue:e)
   end

   TitleLabel  = label(init:"My pokemoz" font:{QTk.newFont font(size:20 weight:bold)})

   % Column of labels
   NameLabel   = {Label "Name:"}
   TypeLabel   = {Label "Type:"}
   LevelLabel  = {Label "Level:"}
   HealthLabel = {Label "Health:"}
   XPLabel     = {Label "XP:"}
   Labels = td(glue:e NameLabel TypeLabel LevelLabel HealthLabel XPLabel)

   % Column of values
   Name   = {Value {AtomToString Pokemoz.name}}
   Type   = {Value {AtomToString Pokemoz.type}}
   Level  = {Value {IntToString Pokemoz.level}}
   Health = {Value {IntToString Pokemoz.health}}
   XP     = {Value {IntToString Pokemoz.xp}}
   Values = td(glue:w Name Type Level Health XP)
in
   td(TitleLabel lr(Labels Values))
end


proc {DrawMap Game}
   proc {CreateMapCanvas} MapCanvas in
      MapCanvas = canvas(bg:green width:Game.map_info.width*TILE_SIZE height:Game.map_info.height*TILE_SIZE handle:MapCanvasHandle)
      MapWindow = {QTk.build lr(MapCanvas)}
   end

   fun {AddTileAt Type X Y} ImageName in
      ImageName = if Type==GRASS then texture_grass else texture_road end
      create(image X*TILE_SIZE Y*TILE_SIZE anchor:nw image:{GetImage ImageName})
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
	 
   proc {DrawMap Map}
      proc {RecDrawMap RowsList RowNumber}
	 case RowsList
	 of nil then skip
	 [] Row|RemainingRows then
	    {DrawRow Row RowNumber}
	    {RecDrawMap RemainingRows RowNumber+1}
	 end
      end
   in
      {RecDrawMap {Record.toList Map} 0}
   end
in
   {CreateMapCanvas}
   {DrawMap Game.map_info.map}
   {MapWindow show}
   {Debug map_drawn}
end


% DRAW GAME
InstructionsStream
InstructionsPort = {NewPort InstructionsStream}

proc {DrawAuxiliaryInterface}
   Interface = lr({PokemozArea Game.player.pokemoz.1})
   Window = {QTk.build Interface}
in
   {Window show}
   {Debug auxialiary_interface_drawn}
end

proc {GameLoop InstructionsStream}
   case InstructionsStream
   of H|T then
      {Debug instruction_received}
      {Browse H}
      {AnimPlayer H}
      {GameLoop T}
   end
end

proc {InitGame}
   proc {BindKeyboardActions}
      {Drawings.map.window bind(event:"<Up>"    action:proc{$} {Send InstructionsPort up}     end)}
      {Drawings.map.window bind(event:"<Left>"  action:proc{$} {Send InstructionsPort left}   end)}
      {Drawings.map.window bind(event:"<Down>"  action:proc{$} {Send InstructionsPort down}   end)}
      {Drawings.map.window bind(event:"<Right>" action:proc{$} {Send InstructionsPort right}  end)}
      {Drawings.map.window bind(event:"<space>" action:proc{$} {Send InstructionsPort finish} end)}
   end
   
   proc {PositionPlayer}
      {Drawings.map.canvas_handle create(image PLAYER_START_POS.x*TILE_SIZE PLAYER_START_POS.y*TILE_SIZE image:{GetImage sacha_down_3} anchor:nw handle:Drawings.player)} 
   end
in
   {BindKeyboardActions}
   {Debug keyboard_action_bound}
   {PositionPlayer}
   {Debug player_positionned}
   {Debug game_initialized}
end


% Startup
{DrawMap Game}
{DrawAuxiliaryInterface}
{InitGame}
{GameLoop InstructionsStream}