declare
DEBUG = true
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
BASE_PATH = "/Users/Greg/Desktop/ozProject/"
CANVAS_OFFSET_BUG = 3 % Canvas seems to start 3 pixels outside the window on the TOP-LEFT corner for no reasong.
% Constants
ATTACK_DAMAGE
LEVELS_HP_AND_HP_NEEDED
POKEMOZ_MIN_LEVEL   = 5
POKEMOZ_MAX_LEVEL   = 10
POKEMOZ_BASE_XP     = 0
GRASS               = 0
ROAD                = 1

DELAY            = 100
TILE_SIZE        = 80

TYPE_GRASS = grass
TYPE_WATER = water
TYPE_FIRE  = fire

BULBASOZ   = pokemoz(name:bulbasoz   type:TYPE_GRASS level:POKEMOZ_MIN_LEVEL health:20 xp:POKEMOZ_BASE_XP)
OZTIRTLE   = pokemoz(name:oztirtle   type:TYPE_WATER level:POKEMOZ_MIN_LEVEL health:20 xp:POKEMOZ_BASE_XP)
CHARMANDOZ = pokemoz(name:charmandoz type:TYPE_FIRE  level:POKEMOZ_MIN_LEVEL health:20 xp:POKEMOZ_BASE_XP)

WildPokemozList = [pokemoz(name:caterpie   type:TYPE_GRASS)
		   pokemoz(name:vulpix     type:TYPE_FIRE)
		   pokemoz(name:oddish     type:TYPE_GRASS)]

WildPokemozCount = {Length WildPokemozList}       

% Game parameters
WildPokemozProba = 50 
Speed            = 5

AutoFightRun    = run
AutoFigthChoose = choose
AutoFightCombat = combat
AutoFight       = AutoFightCombat

Map=   map(r(1 1 1 0 0 0 0)
	   r(1 1 1 0 0 1 1)
	   r(1 1 1 0 0 1 1)
	   r(0 0 0 0 0 1 1)
	   r(0 0 0 1 1 1 1)
	   r(0 0 0 1 1 0 0)
	   r(0 0 0 0 0 0 0))

MAP_HEIGHT   = {Width Map}
MAP_WIDTH    = {Width Map.1}
STARTING_POS = pos(x:MAP_WIDTH-1 y:MAP_HEIGHT-1) % Player starts bottom-right corner.
WINNING_POS  = pos(x:MAP_WIDTH-1 y:0)            % Player must reach top-right corner to win.

% Parameters to ask
PlayerName      = greg
StartingPokemoz = CHARMANDOZ

% Game state
Brock        = player(name:brock   position:pos(x:2 y:2) pokemoz:[BULBASOZ]) % TODO: Add random starting position + random number of enemy trainers.
James        = player(name:james   position:pos(x:4 y:4) pokemoz:[OZTIRTLE])
Ritchie      = player(name:ritchie position:pos(x:5 y:5) pokemoz:[CHARMANDOZ])

Player       = player(name:PlayerName pokemoz:[StartingPokemoz])
MapInfo      = map_info(map:Map height:{Width Map} width:{Width Map.1})
Game         = game(map_info:MapInfo player:Player enemy_trainers:[Brock James Ritchie])
GameState    = game_state(turn:0 player_position:STARTING_POS pokemoz:[StartingPokemoz])

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

% Coordinates helper
fun {XCoord XPosition}
   (XPosition*TILE_SIZE)+CANVAS_OFFSET_BUG
end

fun {YCoord YPosition}
   (YPosition*TILE_SIZE)+CANVAS_OFFSET_BUG
end

% Images helper
ImageLibrary = {QTk.loadImageLibrary BASE_PATH#"ImagesLibrary.ozf"}

fun {GetImage Name}
   {ImageLibrary get(name:Name image:$)}
end

fun {PlayerImagePosition}
   pos(x:{XCoord Game.player.position.x} y:{YCoord Game.player.position.y})
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

% Player position
fun {CoordToPosition Coord}
   fun {SingleCoordToPos Coord}
      ({FloatToInt Coord}-CANVAS_OFFSET_BUG) div TILE_SIZE
   end
in
   pos(x:{SingleCoordToPos Coord.1} y:{SingleCoordToPos Coord.2.1})
end

fun {PlayerPosition}
   {CoordToPosition {GetCoords Drawings.player}}
end

fun {TileAtPosition Position}
   Map.(Position.y+1).(Position.x+1)
end

fun {IsOnGrass}
   {TileAtPosition {PlayerPosition}}==GRASS
end

proc {AnimPlayer Direction}
   IMAGE_STEPS    = 4
   STEPS_BY_MOVE  = 8
   STEP_DURATION  = {TurnDuration} div STEPS_BY_MOVE
   STEP_INCREMENT = TILE_SIZE div STEPS_BY_MOVE
   
   proc {MoveImageOneStep}
      case Direction
      of up    then {IncrementYPos Drawings.player ~STEP_INCREMENT}
      [] right then {IncrementXPos Drawings.player  STEP_INCREMENT}
      [] down  then {IncrementYPos Drawings.player  STEP_INCREMENT}
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
   Level  = {Value {IntToString  Pokemoz.level}}
   Health = {Value {IntToString  Pokemoz.health}}
   XP     = {Value {IntToString  Pokemoz.xp}}
   Values = td(glue:w Name Type Level Health XP)
in
   td(TitleLabel lr(Labels Values))
end


proc {DrawMap Game}
   proc {CreateMapCanvas} MapCanvas in
      MapCanvas = canvas(bg:yellow width:Game.map_info.width*TILE_SIZE height:Game.map_info.height*TILE_SIZE handle:MapCanvasHandle)
      MapWindow = {QTk.build lr(MapCanvas)}
   end

   fun {AddTileAt Type X Y} ImageName in
      ImageName = if Type==GRASS then texture_grass else texture_road end
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

% Random helper

fun {Rand I}
   ({OS.rand $} mod I) + 1
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

fun {CheckVictoryCondition}
   {PlayerPosition} == WINNING_POS
end

fun {PlayerCanMoveInDirection Direction}
   case Direction
   of up    then {PlayerPosition}.y \= 0
   [] right then {PlayerPosition}.x \= MAP_WIDTH-1
   [] down  then {PlayerPosition}.y \= MAP_HEIGHT-1
   [] left  then {PlayerPosition}.x \= 0
   end
end

% Gameplay
fun {MaxHealth Level}
   Level * 4
end

fun {WildPokemozLevel Turn}
   ComputedLevel = 5 + {Rand ((Turn div 10) + 1)}
in
   if ComputedLevel > POKEMOZ_MAX_LEVEL then POKEMOZ_MAX_LEVEL else ComputedLevel end
end

fun {NewWildPokemoz Type Level}
   pokemoz(name:Type.name type:Type.type level:Level health:{MaxHealth Level} xp:0)
end

fun {IsAttackSuccess AttackerPokemoz DefenderPokemoz}
   SuccessProba = (6 + AttackerPokemoz.level - DefenderPokemoz.level) * 9
in
   {Rand 100} >= SuccessProba
end

fun {Damage AType DType}
   if AType==DType then 2
   else
      case AType#DType
      of TYPE_GRASS#TYPE_WATER  then 3
      [] TYPE_GRASS#TYPE_FIRE   then 1
      [] TYPE_FIRE#TYPE_GRASS   then 3
      [] TYPE_FIRE#TYPE_WATER   then 1
      [] TYPE_WATER#TYPE_FIRE   then 3
      [] TYPE_WATER#TYPE_GRASS  then 1
      end
   end
end


% pokemoz(name:charmandoz type:fire  level:POKEMOZ_BASE_LEVEL health:20 xp:POKEMOZ_BASE_XP)

% Returns true if attacker won, false otherwise.
% Bind resulting variables to resulting pokemoz.
proc {PokemozFight Attacker Defender ResultingAttacker ResultingDefender}   
   proc {RecursivePokemozFight Attacker Defender ResultingAttacker ResultingDefender Round}
      NewDefenderHealth
      NewDefender
   in
      case Attacker#Defender
      of pokemoz(name:NA type:TA level:LA xp:XA health:HA)#pokemoz(name:ND type:TD level:LD xp:XD health:HD) then

	 {Debug fight_round(Round)}
	 {Debug attack(Attacker)}
	 {Debug defense(Defender)}
	 
	 NewDefenderHealth = if {IsAttackSuccess Attacker Defender} then {Max 0 HD-{Damage TA TD}} else HD end 
	 NewDefender = pokemoz(name:ND type:TD level:LD xp:XD health:NewDefenderHealth)
	 
	 if NewDefenderHealth==0 then % Fight is over.
	    {Debug fight_over(winner:Attacker looser:NewDefender)}
	    if (Round mod 2)==0 then % Current attacker is original attacker.
	       ResultingAttacker = Attacker
	       ResultingDefender = NewDefender
	    % true
	    else % Current attacker is original defender.
	       ResultingAttacker = NewDefender
	       ResultingDefender = Attacker
	    % false
	    end
	 else
	    {RecursivePokemozFight NewDefender Attacker ResultingAttacker ResultingDefender Round+1} % Switch attack turn
	 end
      end
   end  
in
   {RecursivePokemozFight Attacker Defender ResultingAttacker ResultingDefender 0}
end


proc {FightWildPokemon GameState}
   WildPokemozType = {List.nth WildPokemozList {Rand WildPokemozCount}}
   Level = {WildPokemozLevel GameState.turn}
   WildPokemoz = {NewWildPokemoz WildPokemozType Level}

   EndWildPokemoz
   EndPlayerPokemoz
in
   {Debug encounter(WildPokemoz)}
   {PokemozFight GameState.pokemoz.1 WildPokemoz EndPlayerPokemoz EndWildPokemoz}
   % case AutoFight
   % of AutoFightChoose then {AskPlayerForFight}
   % [] AutoFightRun    then {Debug player_flee_combat}
   % [] AutoFightCombat then {ResolveFight}
   % end
end


proc {TestWildPokemonMeeting GameState}
   if {IsOnGrass} then
      {Debug player_on_grass}
      if {Rand 100} >= WildPokemozProba then
	 {Debug player_meet_wild_pokemon}
	 {FightWildPokemon GameState}
      end
   end
end

% game_state(turn:0 player_position:STARTING_POS pokemoz:[StartingPokemoz])
fun {IncrementTurn GameState}
   case GameState
   of game_state(turn:Turn player_position:PP pokemoz:Pokemoz) then
      game_state(turn:Turn+1 player_position:PP pokemoz:Pokemoz)
   end
end

proc {GameLoop InstructionsStream GameState}
   case InstructionsStream
   of Instruction|T then
      {Debug instruction_received(Instruction)}
      if {Bool.'not' {PlayerCanMoveInDirection Instruction}} then {Debug invalid_command(Instruction)} {GameLoop T GameState} end % Skip command if invalid.
      {Debug turn_number(GameState.turn)}
      
      {AnimPlayer Instruction}
      {TestWildPokemonMeeting GameState}
      if {CheckVictoryCondition} then
	 {Debug game_won}
      else
	 {GameLoop T {IncrementTurn GameState}}
      end
   end
end


proc {InitGame}
   proc {BindKeyboardActions}
      {Drawings.map.window bind(event:"<Up>"    action:proc{$} {Send InstructionsPort up}     end)}
      {Drawings.map.window bind(event:"<Left>"  action:proc{$} {Send InstructionsPort left}   end)}
      {Drawings.map.window bind(event:"<Down>"  action:proc{$} {Send InstructionsPort down}   end)}
      {Drawings.map.window bind(event:"<Right>" action:proc{$} {Send InstructionsPort right}  end)}
      {Drawings.map.window bind(event:"<space>" action:proc{$} {Send InstructionsPort finish} end)}
      {Debug keyboard_action_bound}
   end
   
   proc {PositionPlayer}
      {Drawings.map.canvas_handle create(image {XCoord STARTING_POS.x} {YCoord STARTING_POS.y} image:{GetImage sacha_down_3} anchor:nw handle:Drawings.player)} 
      {Debug player_positionned_at(STARTING_POS.x STARTING_POS.y)}
   end

   proc {PositionEnemyTrainers}
      {Debug enemy_trainers_positionned}
   end
   
in
   {BindKeyboardActions}
   {PositionPlayer}
   {PositionEnemyTrainers}
   {Debug game_initialized}
end

% Startup
{DrawMap Game}
{DrawAuxiliaryInterface}
{InitGame}
{GameLoop InstructionsStream GameState}