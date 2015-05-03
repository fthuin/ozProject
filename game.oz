functor
import
  Application
  System
  Module
  Lib           at 'lib.ozf'
  CharactersMod at 'characters.ozf'
  MapMod        at 'map.ozf'
  Interface     at 'interface.ozf'
  FightMod      at 'fight.ozf'
  GameIntro     at 'gameIntro.ozf'
  GameStateMod  at 'game_state.ozf'
  PlayerMod     at 'player.ozf'
  AutoPilot     at 'auto_pilot.ozf'
  PokemozMod    at 'pokemoz.ozf'
define
  {System.show game_started}
  [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}

  % Get Parameters
  MapPath WildPokemozProba Speed AutoFight Delay
  {Lib.getArgs MapPath WildPokemozProba Speed AutoFight Delay}
  {Lib.debug arguments_parsed}

  TurnDuration = (10-Speed)*Delay

  Map = {MapMod.loadMapFromFile MapPath}
  {Lib.debug map_loaded}

  % Intro - Ask player for name and starting pokemoz
  PlayerName  = "Greg"
  PokemozName = bulbasoz
   /*
   PlayerName PokemozName
   if AutoFight then
      PlayerName = "Sacha"
      PokemozName = bulbasoz
   else
      {GameIntro.getUserChoice PlayerName PokemozName}
   end
   */

  % Save some map info
  MapHeight        = {Width Map}
  MapWidth         = {Width Map.1}

  % Compute elements starting position
  VictoryPosition  = pos(x:MapWidth-1 y:0)
  HospitalPosition = pos(x:3 y:3)
  BrockPosition    = pos(x:5 y:1)
  MistyPosition    = pos(x:1 y:1)
  JamesPosition    = pos(x:0 y:5)

  % Compute enemy trainers
   Trainers = [
         {PlayerMod.updatePosition CharactersMod.james JamesPosition}
         {PlayerMod.updatePosition CharactersMod.brock BrockPosition}
         {PlayerMod.updatePosition CharactersMod.misty MistyPosition}
        ]

  % Setup intial game state
   InstructionsStream
   InstructionsPort

  proc {BindKeyboardActions Window Port}
     {Window bind(event:"<Up>"    action:proc{$} {Send Port up}     end)}
     {Window bind(event:"<Left>"  action:proc{$} {Send Port left}   end)}
     {Window bind(event:"<Down>"  action:proc{$} {Send Port down}   end)}
     {Window bind(event:"<Right>" action:proc{$} {Send Port right}  end)}
     {Window bind(event:"<space>" action:proc{$} {Send Port finish} end)}
  end

  proc {UnbindKeyboardActions Window Port}
     {Window bind(event:"<Up>"      action:proc{$} skip end)}
     {Window bind(event:"<Left>"    action:proc{$} skip end)}
     {Window bind(event:"<Down>"    action:proc{$} skip end)}
     {Window bind(event:"<Right>"   action:proc{$} skip end)}
     {Window bind(event:"<space>"   action:proc{$} skip end)}
  end

  fun {InitGame}
    StartingPos      = pos(x:MapWidth-1 y:MapHeight-1)
    Player           = player(name:PlayerName image:characters_player position:StartingPos selected_pokemoz:1
                              pokemoz_list:[CharactersMod.basePokemoz.PokemozName])
    GameState        = game_state(turn:0 player:Player trainers:Trainers)
    BindKeys         = proc {$} {BindKeyboardActions   Window InstructionsPort} end
    UnbindKeys       = proc {$} {UnbindKeyboardActions Window InstructionsPort} end
    MapPlaceHolder
    InterfacePlaceHolder
    Window = {QTk.build td(td(pady:20 padx:20 % Cannot set padding on top-level, so set 1 extra td for padding.
                            placeholder(glue:n handle:MapPlaceHolder        width:1100 height:560)
                            placeholder(glue:n handle:InterfacePlaceHolder  width:1100 height:220)))}
  in
    InstructionsPort = {NewPort InstructionsStream}
    {Window show}
    {Window set(geometry:geometry(width:1 height:1))}
    % Init map
    {MapMod.init MapPlaceHolder Map}
    {MapMod.drawPikachuAtPosition  VictoryPosition}
    {MapMod.drawBrockAtPosition    BrockPosition}
    {MapMod.drawMistyAtPosition    MistyPosition}
    {MapMod.drawJamesAtPosition    JamesPosition}
    {MapMod.drawPlayerAtPosition   StartingPos}
    {MapMod.drawHospitalAtPosition HospitalPosition}

    % Init interface
    {Interface.init InterfacePlaceHolder GameState BindKeys UnbindKeys}
    {FightMod.init Interface AutoFight}

    {Window set(geometry:geometry(width:1200 height:810))}
    if AutoFight then {AutoPilot.init HospitalPosition VictoryPosition} else {BindKeys} end
    GameState
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
    if GameState.player.position == HospitalPosition andthen Direction\=down then
      false % Can only exit hospital by going down...
    else
      if {PositionIsFree GameState NewPosition} then
        case Direction
        of up    then GameState.player.position.y \= 0
	      [] right then
          if GameState.player.position.x \= MapWidth-1
            andthen (HospitalPosition.x \= GameState.player.position.x+1
            orelse   HospitalPosition.y \= GameState.player.position.y)
            then true else false end
	      [] down  then
	         if GameState.player.position.y \= MapHeight-1
    	     andthen (HospitalPosition.y \= GameState.player.position.y+1
    	     orelse   HospitalPosition.x \= GameState.player.position.x)
    	     then true else false end
	      [] left then
	         if GameState.player.position.x \= 0
	         andthen (HospitalPosition.x \= GameState.player.position.x-1
	         orelse   HospitalPosition.y \= GameState.player.position.y)
	         then true else false end
           end
      else % Position was not free.
        false
      end
    end
  end

  fun {MovePlayer GameState Direction}
    {MapMod.movePlayer Direction TurnDuration}
    {GameStateMod.updatePlayer GameState {PlayerMod.updatePositionInDirection GameState.player Direction}}
  end

  fun {TestWildPokemozMeeting GameState}
     if {MapMod.isRoad Map GameState.player.position} then
       {Lib.debug player_on_road} false
     else
       {Lib.debug player_on_grass}
       if {Lib.rand 100} >= WildPokemozProba then false
       else {Lib.debug player_meet_wild_pokemon}  true
       end
     end
  end

  fun {CheckVictoryCondition GameState}
    GameState.player.position == VictoryPosition
  end

  fun {HealPokemoz GameState}
    NewState = {GameStateMod.healPlayerPokemoz GameState}
  in
    {Interface.updatePlayer1 NewState.player}
    NewState
  end

  fun {InHospital GameState}
    GameState.player.position == HospitalPosition
  end

  fun {TestTrainerMeeting GameState Trainer}
    fun {PositionsAreAdjacent Pos1 Pos2}
      XDiff = {Abs (Pos1.x - Pos2.x)}
      YDiff = {Abs (Pos1.y - Pos2.y)}
    in
      if (XDiff+YDiff)==1 then true else false end
    end
    fun {TestTrainerMeetingRec Trainers}
      case Trainers
      of nil then false
      [] H|T then
        if {PositionsAreAdjacent GameState.player.position H.position}
        andthen {PokemozMod.allPokemozAreDead H.pokemoz_list}==false then
          Trainer = H
          true
        else {TestTrainerMeetingRec T} end
      end
    end
  in
    {TestTrainerMeetingRec GameState.trainers}
  end

  proc {GameLoop InstructionsStream GameState}
     case InstructionsStream
     of Instruction|T then AfterMoveState AfterFightState Trainer in
    	{Lib.debug instruction_received(Instruction)}

    	if {Bool.'not' {PlayerCanMoveInDirection GameState Instruction}} then
    	   {Lib.debug invalid_command(Instruction)}
    	   {GameLoop T GameState}
      end

      {Lib.debug turn_number(GameState.turn)}
    	AfterMoveState = {MovePlayer GameState Instruction}
      {Lib.debug player_moved_to(AfterMoveState.player.position)}

      if {InHospital AfterMoveState} then
        AfterFightState = {HealPokemoz AfterMoveState}
      elseif {TestTrainerMeeting AfterMoveState Trainer} then
        AfterFightState = {FightMod.fightTrainer AfterMoveState Trainer}
      elseif {TestWildPokemozMeeting AfterMoveState} then
        AfterFightState = {FightMod.meetWildPokemoz AfterMoveState}
      else
        AfterFightState = AfterMoveState
      end

      if {CheckVictoryCondition AfterFightState} then
        {Lib.debug game_won}
        {Application.exit 0}
      end

      if AutoFight then {AutoPilotInstruction AfterFightState} end
      {GameLoop T {GameStateMod.incrementTurn AfterFightState}}
     end
  end

  proc {AutoPilotInstruction GameState}
    {Send InstructionsPort {AutoPilot.generateNextInstruction GameState}}
  end
  % kickoff
  InitialGameState = {InitGame}
  if AutoFight then {AutoPilotInstruction InitialGameState} end
  {GameLoop InstructionsStream InitialGameState}

end
