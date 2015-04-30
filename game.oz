functor
import
  Application
  System
  Lib        at 'lib.ozf'
  Characters at 'characters.ozf'
  Map        at 'map.ozf'
  Interface  at 'interface.ozf'
  Fight      at 'fight.ozf'
  GameIntro  at 'gameIntro.ozf'
define
  {System.show game_started}

  % Temporary game parameters
  TestMap = map(r(1 1 1 0 0 0 0)
                r(1 1 1 0 0 1 1)
                r(1 1 1 0 0 1 1)
                r(0 0 0 0 0 1 1)
                r(0 0 0 1 1 1 1)
                r(0 0 0 1 1 0 0)
                r(0 0 0 0 0 0 0))
  WildPokemozProba = 50
  Speed = 8
  DELAY = 200

  % Intro - Ask player for name and starting pokemoz
  PlayerName = "Greg"
  PokemozName = bulbasoz
  % {GameIntro.getUserChoice PlayerName PokemozName}

  % Save some map info
  MapHeight   = {Width TestMap}
  MapWidth    = {Width TestMap.1}
  VictoryPosition  = pos(x:MapWidth-1 y:0)
  HospitalPosition = pos(x:(MapWidth div 2) y:(MapHeight div 2))
  {Lib.debug HospitalPosition}

  % Setup intial game state
  InstructionsStream
  GameState

  proc {InitGame}
    StartingPos      = pos(x:MapWidth-1 y:MapHeight-1)
    Player           = player(name:PlayerName image:characters_player position:StartingPos selected_pokemoz:1
                              pokemoz_list:[Characters.basePokemoz.PokemozName
                                            Characters.basePokemoz.charmandoz
                                            Characters.basePokemoz.oztirtle])
    InstructionsPort = {NewPort InstructionsStream}
  in
    GameState = game_state(turn:0 player:Player trainers:Characters.trainers)
    {Map.init TestMap InstructionsPort Speed DELAY}
    {Map.drawMap}
    {Map.drawPlayerAtPosition StartingPos}
    {Map.drawHospitalAtPosition HospitalPosition}
    {Interface.init GameState}
    {Fight.setInterface Interface}
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
                 player:player(name:Name image:Img position:pos(x:X y:Y) pokemoz_list:Pokemoz selected_pokemoz:SP)
                 trainers:Trainers) then X2 Y2 in
     case Direction
     of up    then X2 = X    Y2 = Y-1
     [] right then X2 = X+1  Y2 = Y
     [] down  then X2 = X    Y2 = Y+1
     [] left  then X2 = X-1  Y2 = Y
     end
     {Map.movePlayer Direction}
     game_state(turn:Turn
                player:player(name:Name image:Img position:pos(x:X2 y:Y2) pokemoz_list:Pokemoz selected_pokemoz:SP)
                trainers:Trainers)
    end
  end

  fun {TestWildPokemozMeeting GameState}
     if {Map.isRoad GameState.player.position} then
       {Lib.debug player_on_road} false
     else
       {Lib.debug player_on_grass}
       if {Lib.rand 100} >= WildPokemozProba then
         {Lib.debug player_meet_wild_pokemon} true
       else false
       end
     end
  end

  fun {CheckVictoryCondition GameState}
     GameState.player.position == VictoryPosition
  end

  proc {GameLoop InstructionsStream GameState}
    case InstructionsStream
    of Instruction|T then AfterMoveState AfterFightState in
      {Lib.debug instruction_received(Instruction)}

      if {Bool.'not' {PlayerCanMoveInDirection GameState Instruction}} then
        {Lib.debug invalid_command(Instruction)}
        {GameLoop T GameState}
      end

      {Lib.debug turn_number(GameState.turn)}
      AfterMoveState = {MovePlayer GameState Instruction}
      {Lib.debug player_moved_to(AfterMoveState.player.position)}

      if {TestWildPokemozMeeting AfterMoveState} then
        AfterFightState = {Fight.fightWildPokemoz AfterMoveState}
      else
        AfterFightState = AfterMoveState
      end

      if {CheckVictoryCondition AfterFightState} then
        {Lib.debug game_won}
        {Application.exit 0}
      end

      {GameLoop T {IncrementTurn AfterFightState}}
    end
  end

  % Startup
  {InitGame}
  {GameLoop InstructionsStream GameState}
end
