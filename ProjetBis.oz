AutoFightRun    = run
AutoFigthChoose = choose
AutoFightCombat = combat
AutoFight       = AutoFightCombat



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

% Time helpers
fun {TurnDuration}
   (10-Speed)*DELAY
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


fun {CheckVictoryCondition}
   {PlayerPosition} == WINNING_POS
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
