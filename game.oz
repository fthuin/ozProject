functor
import
   System
   Lib at 'lib.ozf'
   Map at 'map.ozf'
   Interface at 'interface.ozf'
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
   TestMap = map(r(1 1 1 0 0 0 0)
	               r(1 1 1 0 0 1 1)
	               r(1 1 1 0 0 1 1)
	               r(0 0 0 0 0 1 1)
	               r(0 0 0 1 1 1 1)
	               r(0 0 0 1 1 0 0)
	               r(0 0 0 0 0 0 0))
   PlayerName = greg
   StartingPokemoz = CHARMANDOZ

   % Config starting position
   MapHeight   = {Width TestMap}
   MapWidth    = {Width TestMap.1}
   StartingPos = pos(x:MapWidth-1 y:MapHeight-1)

   % Setup intial game state
   InstructionsStream
   InstructionsPort = {NewPort InstructionsStream}
   GameState        = game_state(turn:0 player_position:StartingPos pokemoz:[StartingPokemoz])

   % Setup Map
   {Map.init TestMap InstructionsPort 5 200}
   {Map.drawMap}
   {Map.drawPlayerAtPosition StartingPos}
   {Interface.draw GameState}


   fun {IncrementTurn GameState}
      case GameState
      of game_state(turn:Turn player_position:PP pokemoz:Pokemoz) then
         game_state(turn:Turn+1 player_position:PP pokemoz:Pokemoz)
      end
   end

   fun {PlayerCanMoveInDirection GameState Direction}
      case Direction
      of up    then GameState.player_position.y \= 0
      [] right then GameState.player_position.x \= MapWidth-1
      [] down  then GameState.player_position.y \= MapHeight-1
      [] left  then GameState.player_position.x \= 0
      end
   end

   fun {MovePlayer GameState Direction}
     case GameState
     of game_state(turn:Turn player_position:pos(x:X y:Y) pokemoz:Pokemoz) then X2 Y2 in
       case Direction
       of up    then X2 = X    Y2 = Y-1
       [] right then X2 = X+1  Y2 = Y
       [] down  then X2 = X    Y2 = Y+1
       [] left  then X2 = X-1  Y2 = Y
       end
       {Map.movePlayer Direction}
       game_state(turn:Turn player_position:pos(x:X2 y:Y2) pokemoz:Pokemoz)
     end
   end


   proc {GameLoop InstructionsStream GameState}
      case InstructionsStream
      of Instruction|T then AfterMoveState in
         {Lib.debug instruction_received(Instruction)}
         if {Bool.'not' {PlayerCanMoveInDirection GameState Instruction}} then
           {Lib.debug invalid_command(Instruction)}
           {GameLoop T GameState}
         end % Skip command if invalid.

         {Lib.debug turn_number(GameState.turn)}
         AfterMoveState = {MovePlayer GameState Instruction}
         {Lib.debug player_moved_to(AfterMoveState.player_position)}
         % {TestWildPokemonMeeting GameState}
         % if {CheckVictoryCondition} then
   	     %  {Debug game_won}
         % else
   	     {GameLoop T {IncrementTurn AfterMoveState}}
         % end
      end
   end

   {GameLoop InstructionsStream GameState}
end
