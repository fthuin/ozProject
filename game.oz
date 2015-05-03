functor
import
  Application
  System
  Module
  Property
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

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  ____   _    ____  ____  _____      _    ____   ____ ____
  % |  _ \ / \  |  _ \/ ___|| ____|    / \  |  _ \ / ___/ ___|
  % | |_) / _ \ | |_) \___ \|  _|     / _ \ | |_) | |  _\___ \
  % |  __/ ___ \|  _ < ___) | |___   / ___ \|  _ <| |_| |___) |
  % |_| /_/   \_\_| \_\____/|_____| /_/   \_\_| \_\\____|____/
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Default values
  DEFAULT_NAME    = "Sacha"
  DEFAULT_POKEMOZ = bulbasoz
  DELAY           = 200
  MAP             = 'Map.txt'
  WILD_POKE_PROBA = 10
  SPEED           = 9
  AUTOFIGHT       = true
  Say             = System.showInfo
  Args = {Application.getArgs record(
             map(single char:&m type:atom default:MAP)
     probability(single char:&p type:int  default:WILD_POKE_PROBA)
           speed(single char:&s type:int  default:SPEED)
       autofight(single char:&a type:bool default:AUTOFIGHT)
            help(single char:[&? &h] default:false))}

  if Args.help then
    {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
    {Say "Options:"}
    {Say "  -m, --map FILE\tFile containing the map (default "#MAP#")"}
    {Say "  -p, --probability INT\tProbability to find a wild pokemoz in tall grass"}
    {Say "  -s, --speed INT\tThe speed of your pokemoz trainer in a range from 0 to 10"}
    {Say "  -a, --autofight BOOL\tChoice weither the game is automatic or not"}
    {Say "  -h, -?, --help\tThis help"}
    {Application.exit 0}
  end

  MapPath          = Args.map
  WildPokemozProba = Args.probability
  Speed            = Args.speed
  AutoFight        = Args.autofight
  TurnDuration = (10-Speed)*DELAY
  {Lib.debug arguments_parsed}

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  ___ _   _ ___ _____    ____    _    __  __ _____ ____ _____  _  _____ _____
  % |_ _| \ | |_ _|_   _|  / ___|  / \  |  \/  | ____/ ___|_   _|/ \|_   _| ____|
  %  | ||  \| || |  | |   | |  _  / _ \ | |\/| |  _| \___ \ | | / _ \ | | |  _|
  %  | || |\  || |  | |   | |_| |/ ___ \| |  | | |___ ___) || |/ ___ \| | | |___
  % |___|_| \_|___| |_|    \____/_/   \_\_|  |_|_____|____/ |_/_/   \_\_| |_____|
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  InstructionsStream
  InstructionsPort

  fun {InitGame}
    % Ask player name and starting pokemoz
    PlayerName PokemozName
    if AutoFight then
      PlayerName =  DEFAULT_NAME
      PokemozName = DEFAULT_POKEMOZ
    else
      {GameIntro.getUserChoice PlayerName PokemozName}
    end

    % Load map
    Map       = {MapMod.loadMapFromFile MapPath}
    MapHeight = {Width Map}
    MapWidth  = {Width Map.1}

    % Configure map elements
    VictoryPosition  = pos(x:MapWidth-1 y:0)
    HospitalPosition = pos(x:3 y:3)
    BrockPosition    = pos(x:5 y:1)
    MistyPosition    = pos(x:1 y:1)
    JamesPosition    = pos(x:0 y:5)
    Trainers = [
           {PlayerMod.updatePosition CharactersMod.james JamesPosition}
           {PlayerMod.updatePosition CharactersMod.brock BrockPosition}
           {PlayerMod.updatePosition CharactersMod.misty MistyPosition}
    ]

    % Prepare main data structures
    MapInfo          = map_info(height:MapHeight width:MapWidth hospital_pos:HospitalPosition victory_pos:VictoryPosition)
    StartingPos      = pos(x:MapInfo.width-1 y:MapInfo.height-1)
    Player           = player(name:PlayerName image:characters_player position:StartingPos selected_pokemoz:1
                              pokemoz_list:[CharactersMod.basePokemoz.PokemozName])
    GameState        = game_state(turn:0 player:Player trainers:Trainers map_info:MapInfo)


    BindKeys         = proc {$} {Lib.bindKeyboardArrows   Window InstructionsPort} end
    UnbindKeys       = proc {$} {Lib.unbindKeyboardArrows Window} end

    % Prepare application main window
    MapPlaceHolder
    InterfacePlaceHolder
    [QTk]  = {Module.link ["x-oz://system/wp/QTk.ozf"]}
    Window = {QTk.build td(td(pady:20 padx:20 % Cannot set padding on top-level, so set 1 extra td for padding.
                            placeholder(glue:n handle:MapPlaceHolder        width:1100 height:560)
                            placeholder(glue:n handle:InterfacePlaceHolder  width:1100 height:220)))}
    {Window show}
    {Window set(geometry:geometry(width:1 height:1))}
  in
    InstructionsPort = {NewPort InstructionsStream}

    % Initialize map interface
    {MapMod.init MapPlaceHolder Map}
    {MapMod.drawPikachuAtPosition  VictoryPosition}
    {MapMod.drawBrockAtPosition    BrockPosition}
    {MapMod.drawMistyAtPosition    MistyPosition}
    {MapMod.drawJamesAtPosition    JamesPosition}
    {MapMod.drawPlayerAtPosition   GameState.player.position}
    {MapMod.drawHospitalAtPosition GameState.map_info.hospital_pos}

    % Initialize other modules
    {Interface.init InterfacePlaceHolder GameState BindKeys UnbindKeys}
    {FightMod.init Interface AutoFight}
    if AutoFight then {AutoPilot.init GameState.map_info.hospital_pos VictoryPosition} else {BindKeys} end
    % Show window
    {Window set(geometry:geometry(width:1200 height:810))}
    GameState
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %   ____    _    __  __ _____ _     ___   ___  ____
  %  / ___|  / \  |  \/  | ____| |   / _ \ / _ \|  _ \
  % | |  _  / _ \ | |\/| |  _| | |  | | | | | | | |_) |
  % | |_| |/ ___ \| |  | | |___| |__| |_| | |_| |  __/
  % \____/_/   \_\_|  |_|_____|_____\___/ \___/|_|
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  fun {PlayerMeetsWildPokemoz? GameState}
     {Bool.and {MapMod.isGrass Map GameState.player.position} ({Lib.rand 100}>=WildPokemozProba)}
  end

  proc {SendNextAutoPilotInstruction GameState}
    {Send InstructionsPort {AutoPilot.generateNextInstruction GameState}}
  end

  proc {GameLoop InstructionsStream GameState}
    fun {PlayerIsAtHospital GameState} GameState.player.position == HospitalPosition end
    fun {PlayerWon GameState}          GameState.player.position == VictoryPosition end
    fun {MovePlayer GameState Direction}
      {MapMod.movePlayer Direction TurnDuration}
      {GameStateMod.updatePlayer GameState {PlayerMod.updatePositionInDirection GameState.player Direction}}
    end
    AfterMoveState AfterActionState Trainer
  in
    case InstructionsStream of Direction|T then
    {Lib.debug instruction_received(Direction)}

    % Test is movement is valid
    if {GameStateMod.canPlayerMoveInDirection? GameState Direction}==false then
       {Lib.debug invalid_command(Direction)}
       {GameLoop T GameState}
    else
       {Lib.debug turn_started(GameState.turn)}
       AfterMoveState = {MovePlayer GameState Direction}
       {Lib.debug player_moved_to(AfterMoveState.player.position)}
    end

    % Execute turn action
    if {PlayerIsAtHospital AfterMoveState} then
      AfterActionState = {GameStateMod.healPlayerPokemoz AfterMoveState}
      {Interface.updatePlayer1 AfterActionState.player}
    elseif {GameStateMod.isPlayerNextToTrainer? AfterMoveState Trainer} then
      AfterActionState = {FightMod.fightTrainer AfterMoveState Trainer}
    elseif {PlayerMeetsWildPokemoz? AfterMoveState} then
      AfterActionState = {FightMod.meetWildPokemoz AfterMoveState}
    else
      AfterActionState = AfterMoveState
    end

    % Test if player won the game
    if {PlayerWon AfterActionState} then
      {Lib.debug game_won}
      {Application.exit 0}
    end

    % Start next loop
    if AutoFight then {SendNextAutoPilotInstruction AfterActionState} end
      {GameLoop T {GameStateMod.incrementTurn AfterActionState}}
    end
  end

  % Kickoff!
  InitialGameState = {InitGame}
  if AutoFight then {SendNextAutoPilotInstruction InitialGameState} end
  {GameLoop InstructionsStream InitialGameState}

end
