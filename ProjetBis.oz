declare
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
PLAYER_START_POS = 0#0

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

Map2=  map(r(1 1 1 1 1 1 1)
	   r(1 1 1 0 0 1 1)
	   r(1 1 1 0 0 1 1)
	   r(0 0 0 0 0 1 1)
	   r(0 0 0 1 1 1 1)
	   r(0 0 0 1 1 1 1)
	   r(0 0 0 0 0 0 1))

% Parameters to ask
PlayerName      = greg
StartingPokemoz = CHARMANDOZ

% Game state
Brock        = player(name:brock   position:2#2 pokemoz:[BULBASOZ]) % TODO: Add random starting position + random number of enemy trainers.
James        = player(name:james   position:4#4 pokemoz:[OZTIRTLE])
Ritchie      = player(name:ritchie position:6#6 pokemoz:[OZTIRTLE])
Player       = player(name:PlayerName position:PLAYER_START_POS pokemoz:[StartingPokemoz])
MapInfo      = map_info(map:Map height:{Width Map} width:{Width Map.1})
Game         = game(map_info:MapInfo player:Player enemy_trainers:[Brock James Ritchie])

MapInfo2      = map_info(map:Map2 height:{Width Map2} width:{Width Map.1})
Game2         = game(map_info:MapInfo player:Player enemy_trainers:[Brock James Ritchie])

% Images helper
ImageLibary = {QTk.loadImageLibrary BASE_PATH#"ImagesLibrary.ozf"}

fun {GetImage Name}
   {ImageLibary get(name:Name image:$)}
end

% Initialize game

% 1. Build map from raw map.
% 2. Add enemy trainers.
% 3. Add player.


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

MapWindow
MapCanvas
MapCanvasHandle

proc {CreateMapCanvas Game}
   MapCanvas = canvas(bg:green width:Game.map_info.width*TILE_SIZE height:Game.map_info.height*TILE_SIZE handle:MapCanvasHandle)
   MapWindow = {QTk.build lr(MapCanvas)}
end

proc {Draw Game}

   fun {AddTileAt Type X Y} ImageName in
      ImageName = if Type==GRASS then texture_grass else texture_road end
      create(image X*TILE_SIZE Y*TILE_SIZE anchor:nw image:{GetImage ImageName})
   end
   
   proc {DrawRow RowRecord RowNumber}
      proc {RecDrawRow TilesList X}
	 case TilesList
	 of nil then skip
	 [] H|T then Temp in
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
   {DrawMap Game.map_info.map}
end


% DRAW GAME
proc {DrawGame Game}
   {CreateMapCanvas Game}
   {Draw Game}
   {MapWindow show}

   
   Interface = lr(
		  {PokemozArea Game.player.pokemoz.1} % TODO: Handle multiple Pokemoz.
		  )
   
   Window = {QTk.build Interface}
in
   {Window show}
end


{DrawGame Game}
{MapCanvasHandle create(image 0 0 anchor:nw image:{GetImage sacha_down_1})}

% {MapCanvasHandle create(image 40 40 anchor:nw image:{QTk.newImage photo(file:"/Users/Greg/Desktop/ozProject/grass3.gif")})}

% GAME LOOP
% proc {GameLoop GameState Instruction}
   % Modify game state.
   % - Check for enemy trainer(s) and resolve fight.
   % - Call DrawGame
   % - Check for wild pokemoz and resolve fight.
   % - Call DrawGame
   % - Check for win condition.
   % - Call draw game.
   % Recursively call itself with next instruction.
% end

% FIGHT
% Compute the resulting Pokemoz after a fight.
% Params: StartPokemozA = attacking pockemoz.
%         StartPokemozB = defending pockemoz.
%         EndPokemozA   = unbound variable.
%         EndPokemozB   = unbound variable.
% Effect: Bind EndPokemozA and EndPokemozB to new pokemoz after fight is resolved.
% proc {PokemozFight PokemozA PokemozD EndPokemozA EndPokemozD}
   % Loop until either one Pokemoz is dead.
     % Attacker attacks
     % Defender attacks
   % Apply experience gain.
% end