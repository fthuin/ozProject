functor
import
  Application
  System
  Lib           at 'lib.ozf'
  CharactersMod at 'characters.ozf'
  Map           at 'map.ozf'
  Interface     at 'interface.ozf'
  FightMod      at 'fight.ozf'
  GameIntro     at 'gameIntro.ozf'
  GameStateMod  at 'game_state.ozf'
  PlayerMod     at 'player.ozf'
  PokemozMod    at 'pokemoz.ozf'
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
  WildPokemozProba = 15
  Speed = 8
  DELAY = 200

  % Intro - Ask player for name and starting pokemoz
  PlayerName  = "Greg"
  PokemozName = bulbasoz

  /*PlayerName
  PokemozName
  {GameIntro.getUserChoice PlayerName PokemozName}*/

  % Save some map info
  MapHeight        = {Width TestMap}
  MapWidth         = {Width TestMap.1}

  % Compute elements starting position
  VictoryPosition  = pos(x:MapWidth-1 y:0)
  HospitalPosition = pos(x:(MapWidth div 2) y:(MapHeight div 2))
  BrockPosition    = pos(x:VictoryPosition.x-1 y:VictoryPosition.y+1)
  MistyPosition    = pos(x:HospitalPosition.x-2 y:HospitalPosition.y-1)
  JamesPosition    = pos(x:2 y:(MapHeight-2))

  % Compute enemy trainers
  Trainers = [
    {PlayerMod.updatePosition CharactersMod.brock BrockPosition}
    {PlayerMod.updatePosition CharactersMod.misty MistyPosition}
    {PlayerMod.updatePosition CharactersMod.james JamesPosition}
  ]

  % Setup intial game state
  InstructionsStream
  GameState

  proc {InitGame}
    StartingPos      = pos(x:MapWidth-1 y:MapHeight-1)
    Player           = player(name:PlayerName image:characters_player position:StartingPos selected_pokemoz:1
                              pokemoz_list:[CharactersMod.basePokemoz.PokemozName])
    InstructionsPort = {NewPort InstructionsStream}
  in
    GameState = game_state(turn:0 player:Player trainers:Trainers)
    {Map.init TestMap InstructionsPort Speed DELAY}
    {Map.drawMap}
    {Map.drawPikachuAtPosition  VictoryPosition}
    {Map.drawBrockAtPosition    BrockPosition}
    {Map.drawMistyAtPosition    MistyPosition}
    {Map.drawJamesAtPosition    JamesPosition}
    {Map.drawPlayerAtPosition   StartingPos}
    {Map.drawHospitalAtPosition HospitalPosition}
    {Interface.init GameState}
    {FightMod.setInterface Interface}
  end

  fun {PositionIsFree GameState Position}
    fun {PositionIsFreeRec Trainers}
      case Trainers
      of nil then true
      [] Trainer|T then
        if Trainer.position == Position then false
        else {PositionIsFreeRec T} end
      end
    end
  in
    {PositionIsFreeRec GameState.trainers}
  end

  fun {PlayerCanMoveInDirection GameState Direction}
    NewPosition = {Lib.positionInDirection GameState.player.position Direction}
  in
    if {PositionIsFree GameState NewPosition} then
      case Direction
      of up    then GameState.player.position.y \= 0
      [] right then GameState.player.position.x \= MapWidth-1
      [] down  then GameState.player.position.y \= MapHeight-1
      [] left  then GameState.player.position.x \= 0
      end
    else % Position was not free.
      false
    end
  end

  fun {MovePlayer GameState Direction}
    {Map.movePlayer Direction}
    {GameStateMod.updatePlayer GameState {PlayerMod.updatePositionInDirection GameState.player Direction}}
  end

  fun {TestWildPokemozMeeting GameState}
     if {Map.isRoad GameState.player.position} then
       {Lib.debug player_on_road} false
     else
       {Lib.debug player_on_grass}
       if {Lib.rand 100} >= WildPokemozProba then
         {Lib.debug player_meet_wild_pokemon} false
       else true
       end
     end
  end

  fun {CheckVictoryCondition GameState}
    GameState.player.position == VictoryPosition
  end

  fun {CheckHospitalCondition GameState}
    GameState.player.position == HospitalPosition
  end

  fun {HealPokemoz GameState} NewState in
    NewState = {GameStateMod.healPokemoz GameState}
    {Interface.updatePlayer1 NewState.player}
    NewState
  end

  fun {PokemozCount Player}
    {Length Player.pokemoz_list}
  end

  fun {MeetWildPokemoz GameState}
    WildPokemoz  = {CharactersMod.summonWildPokemon GameState}
    WildPlayer   = player(name:nil image:characters_wild position:nil pokemoz_list:[WildPokemoz] selected_pokemoz:1)
    {Interface.updatePlayer2 WildPlayer}
    WantsToFight = {Interface.askQuestion "You meet a wild pokemoz." "Run!" "Fight!"}
  in
    if WantsToFight==1 then EndAttackingPlayer AfterFightState FightResult in
      {Lib.debug fight_started_with_wild_pokemoz(WildPokemoz)}
      FightResult      = {FightMod.fight GameState.player WildPlayer EndAttackingPlayer _}
      AfterFightState  = {GameStateMod.updatePlayer GameState EndAttackingPlayer}

      if FightResult==victory andthen {PokemozCount AfterFightState.player} < 3 then
        WantsToCapture = {Interface.askQuestion "Capture defeated pokemoz?" "No"  "Yes"}
      in
        if WantsToCapture==1 then
          NewPlayer = {PlayerMod.capturePokemoz AfterFightState.player {PokemozMod.setHealth WildPokemoz 0}}
        in
          {Interface.clearPlayer2}
          {Lib.debug pokemoz_captured(NewPlayer.pokemoz_list)}
          {Interface.updatePlayer1 NewPlayer}
          {Interface.selectPlayer1Panel {PokemozCount NewPlayer}}
          {GameStateMod.updatePlayer AfterFightState NewPlayer}
        else
          {Interface.clearPlayer2}
          AfterFightState
        end
      else
        {Interface.clearPlayer2}
        AfterFightState
      end
    else % Player run from fight. No change in GameState.
      {Lib.debug player_run_from_fight}
      {Interface.clearPlayer2}
      GameState
    end
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

      if {CheckHospitalCondition AfterMoveState} then
        AfterFightState = {HealPokemoz AfterMoveState}
      elseif {TestWildPokemozMeeting AfterMoveState} then
        AfterFightState = {MeetWildPokemoz AfterMoveState}
      else
        AfterFightState = AfterMoveState
      end

      if {CheckVictoryCondition AfterFightState} then
        {Lib.debug game_won}
        {Application.exit 0}
      end

      {GameLoop T {GameStateMod.incrementTurn AfterFightState}}
    end
  end

  % Startup
  {InitGame}
  {GameLoop InstructionsStream GameState}
end
