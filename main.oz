functor
import
   % OZ modules
   Application
   System

   % Custom modules
   MapDrawing at 'map_drawing.ozf'
define
   {System.show game_started}

   % Base pokemoz
   POKEMOZ_MIN_LEVEL  = 5
   POKEMOZ_MAX_LEVEL  = 10
   POKEMOZ_BASE_XP    = 0
   TYPE_GRASS         = grass
   TYPE_WATER         = water
   TYPE_FIRE          = fire

   BULBASOZ   = pokemoz(name:bulbasoz   type:TYPE_GRASS level:POKEMOZ_MIN_LEVEL health:20 xp:POKEMOZ_BASE_XP)
   OZTIRTLE   = pokemoz(name:oztirtle   type:TYPE_WATER level:POKEMOZ_MIN_LEVEL health:20 xp:POKEMOZ_BASE_XP)
   CHARMANDOZ = pokemoz(name:charmandoz type:TYPE_FIRE  level:POKEMOZ_MIN_LEVEL health:20 xp:POKEMOZ_BASE_XP)


   % Temporary
   Map =  map(r(1 1 1 0 0 0 0)
	            r(1 1 1 0 0 1 1)
	            r(1 1 1 0 0 1 1)
	            r(0 0 0 0 0 1 1)
	            r(0 0 0 1 1 1 1)
	            r(0 0 0 1 1 0 0)
	            r(0 0 0 0 0 0 0))
   PlayerName = greg
   StartingPokemoz = CHARMANDOZ

   % Config starting position
   MapHeight   = {Width Map}
   MapWidth    = {Width Map.1}
   StartingPos = pos(x:MapWidth-1 y:MapHeight-1)

   % Setup intial game state
   InstructionsStream
   InstructionsPort = {NewPort InstructionsStream}
   GameState        = game_state(turn:0 player_position:StartingPos pokemoz:[StartingPokemoz])

   % Setup Map
   {MapDrawing.init Map InstructionsPort 5 200}
   {MapDrawing.drawMap}
   {MapDrawing.drawPlayerAtPosition StartingPos}

   proc {Debug Msg}
      {System.show Msg}
   end

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
         % if {Bool.'not' {PlayerCanMoveInDirection Instruction}} then {Debug invalid_command(Instruction)} {GameLoop T GameState} end % Skip command if invalid.
         {Debug turn_number(GameState.turn)}

         {MapDrawing.movePlayer Instruction}
         % {TestWildPokemonMeeting GameState}
         % if {CheckVictoryCondition} then
   	     %  {Debug game_won}
         % else
   	     {GameLoop T {IncrementTurn GameState}}
         % end
      end
   end

   {GameLoop InstructionsStream GameState}
end
