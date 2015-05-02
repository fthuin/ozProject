functor
import
  Lib        at 'lib.ozf'
  PokemozMod at 'pokemoz.ozf'
  PlayerMod  at 'player.ozf'
export
  Fight
  Init
define
  InterfaceMod
  AutoFight

  CHOOSE_STARTING = "Choose your pokemon to start the fight."
  DEAD_CHOOSE_NEXT = "You pokemoz is dead. Choose your next pokemon to continue the fight."

  proc {Init Interf AutoF}
    InterfaceMod = Interf
    AutoFight = AutoF
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
    proc {UpdateInterface Player}
      if Player.image == characters_player then
        {InterfaceMod.updatePlayer1 Player}
      else
        {InterfaceMod.updatePlayer2 Player}
      end
    end

    fun {RecFight CurrentAttackingPlayer CurrentDefendingPlayer Round}
      AttackingPokemoz    = {List.nth CurrentAttackingPlayer.pokemoz_list CurrentAttackingPlayer.selected_pokemoz}
      DefendingPokemoz    = {List.nth CurrentDefendingPlayer.pokemoz_list CurrentDefendingPlayer.selected_pokemoz}
      EndDefendingPokemoz = {Attack AttackingPokemoz DefendingPokemoz}
      EndDefendingPlayer  = {PlayerMod.updateCurrentPokemoz CurrentDefendingPlayer EndDefendingPokemoz}
    in
      {UpdateInterface EndDefendingPlayer}
      % Fight is over
      if {PokemozMod.allPokemozAreDead EndDefendingPlayer.pokemoz_list} then AfterEvolutionAttackingPlayer in
        {Lib.debug fight_is_over(winner:CurrentAttackingPlayer looser:EndDefendingPlayer)}
        AfterEvolutionAttackingPlayer = {PlayerMod.evolveSelectedPokemoz CurrentAttackingPlayer DefendingPokemoz}
        {AssignEndingStates Round AfterEvolutionAttackingPlayer EndDefendingPlayer EndAttacker EndDefender}
        {UpdateInterface AfterEvolutionAttackingPlayer}
        if (Round mod 2) == 0 then victory else defeat end
      % Fight continue to next round
      else FinalDefender in
        {UpdateInterface EndDefendingPlayer}
        if {SelectedPokemonIsDead EndDefendingPlayer} then
          if AutoFight then
            FinalDefender = {PlayerMod.switchToNextPokemoz EndDefendingPlayer}
          else
            ChoosenIndex = {InterfaceMod.choosePokemonToFight EndDefendingPlayer DEAD_CHOOSE_NEXT} in
            FinalDefender = {PlayerMod.updatePokemozSelection EndDefendingPlayer ChoosenIndex}
          end
          {UpdateInterface EndDefendingPlayer}
          {Lib.debug defender_pokemon_is_dead}
        else
          FinalDefender = EndDefendingPlayer
        end
        {RecFight FinalDefender CurrentAttackingPlayer Round+1} % Switch attack turn
      end
    end

    StartingPokemozIndex = if AutoFight then AttackingPlayer.selected_pokemoz
                           else {InterfaceMod.choosePokemonToFight AttackingPlayer CHOOSE_STARTING} end
  in
     {Lib.debug starting_pokemon_choosen(StartingPokemozIndex)}
     {RecFight {PlayerMod.updatePokemozSelection AttackingPlayer StartingPokemozIndex} DefendingPlayer 0}
  end

end
