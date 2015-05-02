functor
import
  Application
  System
  Lib           at 'lib.ozf'
  CharactersMod at 'characters.ozf'
  MapMod        at 'map.ozf'
  Interface     at 'interface.ozf'
  FightMod      at 'fight.ozf'
  GameIntro     at 'gameIntro.ozf'
  GameStateMod  at 'game_state.ozf'
  PlayerMod     at 'player.ozf'
  PokemozMod    at 'pokemoz.ozf'
define
  {System.show game_started}

  % Messages
  UNABLE_TO_FIGHT = "You meet a wild pokemoz but cannot fight since all your pokemons are injured. Visit the hospital!"
  WIN_BUT_CANNOT_CAPTURE = "You won this fight but cannot capture this pokemon since your already own 3 pokemons"
  FIGHT_LOST = "Oops...You lost this fight! You should visit the hospital to heal your pokemons."
  MEET_WILD_POKEMON = "You meet a wild pokemoz..."
  FIGHT = "Fight!"
  RUN = "Run!"
  CAPTURE_POKEMOZ = "Capture defeated pokemoz?"
  NO = "No"
  YES = "Yes"

  % Get Parameters
  MapPath WildPokemozProba Speed AutoFight Delay
  {Lib.getArgs MapPath WildPokemozProba Speed AutoFight Delay}
  {Lib.debug arguments_parsed}

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
   InstructionsPort
   GameState

  proc {InitGame}
    StartingPos      = pos(x:MapWidth-1 y:MapHeight-1)
    Player           = player(name:PlayerName image:characters_player position:StartingPos selected_pokemoz:1
                              pokemoz_list:[CharactersMod.basePokemoz.PokemozName])
  in
     InstructionsPort = {NewPort InstructionsStream}
    GameState = game_state(turn:0 player:Player trainers:Trainers)
    {MapMod.init Map InstructionsPort Speed Delay}
    {MapMod.drawMap}
    {MapMod.drawPikachuAtPosition  VictoryPosition}
    {MapMod.drawBrockAtPosition    BrockPosition}
    {MapMod.drawMistyAtPosition    MistyPosition}
    {MapMod.drawJamesAtPosition    JamesPosition}
    {MapMod.drawPlayerAtPosition   StartingPos}
    {MapMod.drawHospitalAtPosition HospitalPosition}
    {Interface.init GameState InstructionsPort}
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
    if GameState.player.position == HospitalPosition andthen Direction\=down then
      false % Can only exit hospital by going down...
    else
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
  end

  fun {MovePlayer GameState Direction}
    {MapMod.movePlayer Direction}
    {GameStateMod.updatePlayer GameState {PlayerMod.updatePositionInDirection GameState.player Direction}}
  end

  fun {TestWildPokemozMeeting GameState}
     if {MapMod.isRoad GameState.player.position} then
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

  fun {CheckHospitalCondition GameState}
    GameState.player.position == HospitalPosition
  end

  fun {HealPokemoz GameState} NewState in
    NewState = {GameStateMod.healPokemoz GameState}
    {Interface.updatePlayer1 NewState.player}
    NewState
  end

  fun {WildPokemozVictory GameState WildPokemoz}
    fun {PokemozCount Player} {Length Player.pokemoz_list}          end
    fun {CanCapture}          {PokemozCount GameState.player} < 3   end
  in
    if {CanCapture} then
      WantsToCapture = {Interface.askQuestion CAPTURE_POKEMOZ NO YES} in
      if WantsToCapture==1 then
        NewPlayer = {PlayerMod.capturePokemoz GameState.player {PokemozMod.setHealth WildPokemoz 0}} in
        {Interface.hidePlayer2}
        {Lib.debug pokemoz_captured(NewPlayer.pokemoz_list)}
        {Interface.updatePlayer1 NewPlayer}
        {Interface.selectPlayer1Panel {PokemozCount NewPlayer}}
        {GameStateMod.updatePlayer GameState NewPlayer}
      else
        {Interface.hidePlayer2}
        GameState
      end
    else
      {Interface.writeMessage WIN_BUT_CANNOT_CAPTURE}
      {Interface.hidePlayer2}
      GameState
    end
  end

  fun {FightWildPokemoz GameState WildPlayer}
    EndAttackingPlayer AfterFightState FightResult
    WildPokemoz = WildPlayer.pokemoz_list.1
  in
    {Lib.debug fight_engaged_with_wild_pokemoz(WildPokemoz)}
    FightResult      = {FightMod.fight GameState.player WildPlayer EndAttackingPlayer _}
    AfterFightState  = {GameStateMod.updatePlayer GameState EndAttackingPlayer}
    if FightResult==victory then
      {WildPokemozVictory AfterFightState WildPokemoz}
    else
      {Interface.writeMessage FIGHT_LOST}
      {Interface.hidePlayer2}
      AfterFightState
    end
  end

  fun {MeetWildPokemoz GameState}
    WildPlayer = {PlayerMod.getWildPlayer {CharactersMod.summonWildPokemon GameState}}
    {Interface.showPlayer2 WildPlayer}
    fun {CanFight} {Bool.'not' {PokemozMod.allPokemozAreDead GameState.player.pokemoz_list}} end
  in
    if {CanFight} then
      WantsToFight = {Interface.askQuestion MEET_WILD_POKEMON RUN FIGHT} in
      if WantsToFight==1 then
        {FightWildPokemoz GameState WildPlayer}
      else
        {Lib.debug player_run_from_fight}
        {Interface.hidePlayer2}
        GameState
      end
    else
      {Lib.debug player_cannot_fight}
      {Interface.writeMessage UNABLE_TO_FIGHT}
      {Interface.hidePlayer2}
      GameState
    end
  end

  proc {MoveBeforeHospital GameState}
     PlayerX = GameState.player.position.x
     PlayerY = GameState.player.position.y
  in
     if PlayerX > HospitalPosition.x andthen PlayerY > HospitalPosition.y then
	{Lib.debug movebeforehospital_1}
	{Send InstructionsPort left}
     elseif PlayerX == HospitalPosition.x andthen PlayerY > HospitalPosition.y+1 then
	{Lib.debug movebeforehospital_1}
	{Send InstructionsPort up}
     elseif PlayerX == HospitalPosition.x andthen PlayerY == HospitalPosition.y+1 then
	{Lib.debug movebeforehospital_1}
	{Send InstructionsPort down}
     end
  end

  proc {MoveToHospital GameState Success}
     PlayerX = GameState.player.position.x
     PlayerY = GameState.player.position.y
  in
     if PlayerY > HospitalPosition.y+2 then
	{Lib.debug movetohospital_1}
	{Send InstructionsPort up} Success=false
     elseif PlayerY < HospitalPosition.y+1 then
	{Lib.debug movetohospital_2}
	{Send InstructionsPort down} Success=false
     else
	if PlayerX < HospitalPosition.x then
	   {Lib.debug movetohospital_3}
	   {Send InstructionsPort right} Success=false
	elseif PlayerX > HospitalPosition.x then
	   {Lib.debug movetohospital_4}
	   {Send InstructionsPort left} Success=false
	else
	   {Lib.debug movetohospital_5}
	   {Send InstructionsPort up} %% Rentre dans l'hopital
	   {Send InstructionsPort down}
	   {Send InstructionsPort right} %% Contourne l'hopital
	   Success = true
	end
     end
  end

  proc {MoveFromHospitalToFinish GameState}
     PlayerX = GameState.player.position.x
     PlayerY = GameState.player.position.y
  in
     if PlayerY > VictoryPosition.y+2 then
	{Send InstructionsPort up}
     elseif PlayerY < VictoryPosition.y+1 then
	{Send InstructionsPort down}
     else
	if PlayerX < VictoryPosition.x then
	   {Send InstructionsPort right}
	elseif PlayerX > VictoryPosition.x then
	   {Send InstructionsPort left}
	else
	   {Send InstructionsPort up}
	end
     end
  end

  proc {AutoFightLoop GameState ToFinish IsOutOfHospital}
     if ToFinish then
	{Lib.debug autofightloop_1}
	{MoveFromHospitalToFinish GameState}
	IsOutOfHospital=false
     else
	{Lib.debug autofightloop_4}
	{Lib.debug numberofpokemoz({Length GameState.player.pokemoz_list})}
	   if {Length GameState.player.pokemoz_list} < 3 then
	      %% Player have less than 3 pokemoz
	      %% We want him to get more -> Tall Grass
	      {Lib.debug autofightloop_2}
	      {MoveBeforeHospital GameState}
	      IsOutOfHospital = false
	   else
	      %% Player have 3 pokemoz
	      %% We want him to go to the end
	      {Lib.debug autofightloop_2}
	      {MoveToHospital GameState IsOutOfHospital}
	   end
     end
  end

  proc {GameLoop InstructionsStream GameState GoToFinish}
     case InstructionsStream
     of Instruction|T then AfterMoveState AfterFightState in
	{Lib.debug instruction_received(Instruction)}

      if {Bool.'not' {PlayerCanMoveInDirection GameState Instruction}} then
        {Lib.debug invalid_command(Instruction)}
        {GameLoop T GameState GoToFinish}
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

      if AutoFight then IsOutOfTheHospital in
	 {Lib.debug auto_before_autofightloop}
	 {AutoFightLoop AfterFightState GoToFinish IsOutOfTheHospital}
	 {Lib.debug auto_before_gameloop}
	 if IsOutOfTheHospital then
	    {GameLoop T.2.2 {GameStateMod.incrementTurn AfterFightState} IsOutOfTheHospital}
	    {Lib.debug auto_is_out_hospital}
	 else
	    {GameLoop T {GameStateMod.incrementTurn AfterFightState} IsOutOfTheHospital}
	    {Lib.debug auto_is_not_in_hospital}
	 end
      else
	 {GameLoop T {GameStateMod.incrementTurn AfterFightState} false}
      end
    end
  end

  % Startup
  {InitGame}
  if AutoFight then {Lib.debug first_msg_send_auto} {Send InstructionsPort up} end
  {GameLoop InstructionsStream GameState false}
end
