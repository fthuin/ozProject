functor
import
   System
   Lib        at 'lib.ozf'
   Characters at 'characters.ozf'
   Map        at 'map.ozf'
   Interface  at 'interface.ozf'
define
   {System.show game_started}

   % Base pokemoz
   POKEMOZ_MIN_LEVEL  = 5
   POKEMOZ_MAX_LEVEL  = 10

   % Temporary
   TestMap = map(r(1 1 1 0 0 0 0)
	               r(1 1 1 0 0 1 1)
	               r(1 1 1 0 0 1 1)
	               r(0 0 0 0 0 1 1)
	               r(0 0 0 1 1 1 1)
	               r(0 0 0 1 1 0 0)
	               r(0 0 0 0 0 0 0))
   PlayerName      = greg
   StartingPokemoz = Characters.basePokemoz.bulbasoz

   % Config starting position
   MapHeight   = {Width TestMap}
   MapWidth    = {Width TestMap.1}
   StartingPos = pos(x:MapWidth-1 y:MapHeight-1)

   % Setup intial game state
   InstructionsStream
   InstructionsPort = {NewPort InstructionsStream}
   Player           = player(name:PlayerName position:StartingPos pokemoz:[StartingPokemoz])
   GameState        = game_state(turn:0 player:Player trainers:Characters.trainers)

   proc {InitGame}
     {Map.init TestMap InstructionsPort 5 200}
     {Map.drawMap}
     {Map.drawPlayerAtPosition StartingPos}
     {Interface.init GameState}
   end

   fun {IncrementTurn GameState}
      case GameState
      of game_state(turn:Turn    player:Player trainers:Trainers) then
         game_state(turn:Turn+1  player:Player trainers:Trainers)
      end
   end

   fun {PlayerCanMoveInDirection GameState Direction}
      case Direction
      of up    then GameState.player.position.y \= 0
      [] right then GameState.player.position.x \= MapWidth-1
      [] down  then GameState.player.position.y \= MapHeight-1
      [] left  then GameState.player.position.x \= 0
      end
   end

   fun {MovePlayer GameState Direction}
     case GameState
     of game_state(turn:Turn
                   player:player(name:Name position:pos(x:X y:Y) pokemoz:Pokemoz)
                   trainers:Trainers) then X2 Y2 in
       case Direction
       of up    then X2 = X    Y2 = Y-1
       [] right then X2 = X+1  Y2 = Y
       [] down  then X2 = X    Y2 = Y+1
       [] left  then X2 = X-1  Y2 = Y
       end
       {Map.movePlayer Direction}
       game_state(turn:Turn
                  player:player(name:Name position:pos(x:X2 y:Y2) pokemoz:Pokemoz)
                  trainers:Trainers)
     end
   end

   proc {GameLoop InstructionsStream GameState}
      case InstructionsStream
      of Instruction|T then AfterMoveState in
        % GAME LOOP
        {Lib.debug instruction_received(Instruction)}

        if {Bool.'not' {PlayerCanMoveInDirection GameState Instruction}} then
          {Lib.debug invalid_command(Instruction)}
          {GameLoop T GameState}
        end % Skip command if invalid.

        {Lib.debug turn_number(GameState.turn)}
        AfterMoveState = {MovePlayer GameState Instruction}
        {Lib.debug player_moved_to(AfterMoveState.player.position)}

        % {TestWildPokemonMeeting GameState}
        % if {CheckVictoryCondition} then
        %  {Debug game_won}
        % else

        {GameLoop T {IncrementTurn AfterMoveState}}
      end
   end

   % Startup
   {InitGame}
   {GameLoop InstructionsStream GameState}
end
