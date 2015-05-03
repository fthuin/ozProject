functor
import
  Lib           at 'lib.ozf'
  PokemozMod    at 'pokemoz.ozf'
  PlayerMod     at 'player.ozf'
  GameStateMod  at 'game_state.ozf'
  CharactersMod at 'characters.ozf'
  AutoPilot     at 'auto_pilot.ozf'
export
  MeetWildPokemoz
  FightTrainer
  Init
define
  Interface
  AutoFight

  % Messages
  CHOOSE_STARTING = "Choose your pokemon to start the fight."
  DEAD_CHOOSE_NEXT = "You pokemoz is dead. Choose your next pokemon to continue the fight."
  UNABLE_TO_FIGHT = "You meet a wild pokemoz but cannot fight since all your pokemons are injured. Visit the hospital!"
  WIN_BUT_CANNOT_CAPTURE = "You won this fight but cannot capture this pokemoz since your already own 3 pokemons"
  FIGHT_LOST = "Oops...You lost this fight!\n You should visit the hospital to heal your pokemons."
  MEET_WILD_POKEMON = "You meet a wild pokemoz..."
  MEET_WILD_TRAINER = "You meet another pokemoz trainer.\nNo fight, no glory. Lets go!"
  FIGHT = "Fight!"
  RUN = "Run!"
  CAPTURE_POKEMOZ = "Capture defeated pokemoz?"
  TRAINER_LOSS  = "Oops, you lost this fight...\n Visit the hospital to heal your pokemoz.\n When you feel ready, come back to beat this arrogant prick!"
  TRAINER_WIN = "Congratulations on winning this fight!\nYou are on your way to glory."
  NO = "No"
  YES = "Yes"

  proc {Init Interf AutoF}
    Interface = Interf
    AutoFight    = AutoF
  end

  fun {IsAttackSuccess AttackerPokemoz DefenderPokemoz}
     SuccessProba = (6 + AttackerPokemoz.level - DefenderPokemoz.level) * 9
  in
     {Lib.rand 100} =< SuccessProba
  end

  % Return resulting defender after an attack.
  fun {Attack Attacker Defender}
    if {IsAttackSuccess Attacker Defender}
    then {PokemozMod.dealDamage Defender Attacker.type}
    else Defender
    end
  end

  proc {AssignEndingStates Round CurrentA CurrentD EndAttacker EndDefender}
    if (Round mod 2)==0 then % Current attacker is original attacker.
       EndAttacker = CurrentA
       EndDefender = CurrentD
    else % Current attacker is original defender.
       EndAttacker = CurrentD
       EndDefender = CurrentA
    end
  end

  fun {SelectedPokemonIsDead Player}
    {List.nth Player.pokemoz_list Player.selected_pokemoz}.health==0
  end

  fun {Fight AttackingPlayer DefendingPlayer EndAttacker EndDefender}
    fun {RecFight CAttPlayer CDefPlayer Round}
      fun {IsPlayerAttacking}
        (Round mod 2) == 0
      end

      proc {UpdateInterface PlayerA PlayerB}
        if PlayerA.image == characters_player then
          {Interface.updatePlayer1 PlayerA}
          {Interface.updatePlayer2 PlayerB}
        else
          {Interface.updatePlayer1 PlayerB}
          {Interface.updatePlayer2 PlayerA}
        end
      end
      AttackingPokemoz    = {List.nth CAttPlayer.pokemoz_list CAttPlayer.selected_pokemoz}
      DefendingPokemoz    = {List.nth CDefPlayer.pokemoz_list CDefPlayer.selected_pokemoz}
      EndDefendingPokemoz = {Attack AttackingPokemoz DefendingPokemoz}
      EndDefendingPlayer  = {PlayerMod.updateCurrentPokemoz CDefPlayer EndDefendingPokemoz}
    in
      if (Round mod 3) == 0 then {UpdateInterface CAttPlayer EndDefendingPlayer} end % Only update every 3 turns to speed up..
      % Fight is over
      if {PokemozMod.allPokemozAreDead EndDefendingPlayer.pokemoz_list} then AfterEvoAttPlayer in
        {Lib.debug fight_is_over(winner:CAttPlayer looser:EndDefendingPlayer)}
        AfterEvoAttPlayer = {PlayerMod.evolveSelectedPokemoz CAttPlayer DefendingPokemoz}
        {AssignEndingStates Round AfterEvoAttPlayer EndDefendingPlayer EndAttacker EndDefender}
        {UpdateInterface AfterEvoAttPlayer EndDefendingPlayer}
        if {IsPlayerAttacking} then victory else defeat end
      % Fight continue to next round
    else AfterSwitchDefender in
        if {SelectedPokemonIsDead EndDefendingPlayer} then AfterEvoAttPlayer in
          AfterEvoAttPlayer = {PlayerMod.evolveSelectedPokemoz CAttPlayer DefendingPokemoz}

          {UpdateInterface AfterEvoAttPlayer EndDefendingPlayer}
          if AutoFight orelse {IsPlayerAttacking} then
            AfterSwitchDefender = {PlayerMod.switchToNextPokemoz EndDefendingPlayer}
          else
            ChoosenIndex = {Interface.choosePokemonToFight EndDefendingPlayer DEAD_CHOOSE_NEXT} in
            AfterSwitchDefender = {PlayerMod.updatePokemozSelection EndDefendingPlayer ChoosenIndex}
          end
          {UpdateInterface AfterEvoAttPlayer EndDefendingPlayer}
          {Lib.debug defender_pokemon_is_dead}
          {RecFight AfterSwitchDefender AfterEvoAttPlayer Round+1}
        else
          {RecFight EndDefendingPlayer CAttPlayer Round+1} % Switch attack turn
        end

      end
    end

    StartingPokemozIndex = if AutoFight then AttackingPlayer.selected_pokemoz
                           else {Interface.choosePokemonToFight AttackingPlayer CHOOSE_STARTING} end
  in
     {Lib.debug starting_pokemon_choosen(StartingPokemozIndex)}
     {RecFight {PlayerMod.updatePokemozSelection AttackingPlayer StartingPokemozIndex} DefendingPlayer 0}
  end

  fun {WildPokemozVictory GameState WildPokemoz}
    fun {PokemozCount Player} {Length Player.pokemoz_list}          end
    fun {CanCapture}          {PokemozCount GameState.player} < 3   end
  in
    if {CanCapture} then
      WantsToCapture = if AutoFight then true else {Interface.askQuestion CAPTURE_POKEMOZ NO YES} end in
      if WantsToCapture then
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
      if AutoFight then skip else {Interface.writeMessage WIN_BUT_CANNOT_CAPTURE} end
      {Interface.hidePlayer2}
      GameState
    end
  end

  fun {FightWildPokemoz GameState WildPlayer}
    EndAttackingPlayer
    WildPokemoz      = WildPlayer.pokemoz_list.1
    {Lib.debug fight_engaged_with_wild_pokemoz(WildPokemoz)}
    FightResult      = {Fight GameState.player WildPlayer EndAttackingPlayer _}
    AfterFightState  = {GameStateMod.updatePlayer GameState EndAttackingPlayer}
  in
    if FightResult==victory then
      {WildPokemozVictory AfterFightState WildPokemoz}
    else
      if AutoFight then skip else {Interface.writeMessage FIGHT_LOST} end
      {Interface.hidePlayer2}
      AfterFightState
    end
  end

  fun {FightTrainer GameState EnemyTrainer}
    EndPlayer EndEnemyTrainer
    {Lib.debug fight_engaged_with_trainer(EnemyTrainer)}
    {Interface.showPlayer2 EnemyTrainer}
    if AutoFight then skip else {Interface.writeMessage MEET_WILD_TRAINER} end
    FightResult      = {Fight GameState.player EnemyTrainer EndPlayer EndEnemyTrainer}
    AfterHealTrainer = if FightResult==victory then EndEnemyTrainer else {PlayerMod.healPokemoz EndEnemyTrainer} end
    AfterFightState  = {GameStateMod.updatePlayerAndEnemyTrainer GameState EndPlayer AfterHealTrainer}
  in
    if AutoFight then skip else
      Message = if FightResult==victory then TRAINER_WIN else TRAINER_LOSS end in
      {Interface.writeMessage Message}
    end
    {Interface.hidePlayer2}
    AfterFightState
  end

  fun {MeetWildPokemoz GameState}
     WildPokemoz = {CharactersMod.summonWildPokemon GameState}
     WildPlayer  = {PlayerMod.getWildPlayer WildPokemoz}
     {Interface.showPlayer2 WildPlayer}
     fun {CanFight} {Bool.'not' {PokemozMod.allPokemozAreDead GameState.player.pokemoz_list}} end
  in
    if {CanFight} then WantsToFight in
      WantsToFight = if AutoFight then {AutoPilot.shouldFight GameState WildPokemoz}
      else {Interface.askQuestion MEET_WILD_POKEMON RUN FIGHT} end
      if WantsToFight then
        {FightWildPokemoz GameState WildPlayer}
      else
	      {Lib.debug player_run_from_fight}
	      {Interface.hidePlayer2}
	       GameState
      end
    else
      {Lib.debug player_cannot_fight}
      if AutoFight then skip else {Interface.writeMessage UNABLE_TO_FIGHT} end
      {Interface.hidePlayer2}
      GameState
    end
  end
end
