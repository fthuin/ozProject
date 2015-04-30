functor
import
  Lib        at 'lib.ozf'
  Characters at 'characters.ozf'
  PokemozMod at 'pokemoz.ozf'
  PlayerMod  at 'player.ozf'
  GameState  at 'game_state.ozf'
export
  FightWildPokemoz
  SetInterface
define
  Interface

  proc {SetInterface I}
    Interface = I
  end

  fun {IsAttackSuccess AttackerPokemoz DefenderPokemoz}
     SuccessProba = (6 + AttackerPokemoz.level - DefenderPokemoz.level) * 9
  in
     {Lib.rand 100} >= SuccessProba
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

  fun {AllPokemozAreDead PokemozList}
    case PokemozList
    of nil then true
    [] H|T then if H.health==0 then {AllPokemozAreDead T} else false end
    end
  end

  fun {SelectedPokemonIsDead Player}
    {List.nth Player.pokemoz_list Player.selected_pokemoz}.health==0
  end

  proc {Fight AttackingPlayer DefendingPlayer EndAttacker EndDefender}
    proc {UpdateInterface Player}
      if Player.image == characters_player then
        {Interface.updatePlayer1 Player}
      else
        {Interface.updatePlayer2 Player}
      end
    end

    proc {RecFight CurrentAttackingPlayer CurrentDefendingPlayer Round}
      AttackingPokemoz    = {List.nth CurrentAttackingPlayer.pokemoz_list CurrentAttackingPlayer.selected_pokemoz}
      DefendingPokemoz    = {List.nth CurrentDefendingPlayer.pokemoz_list CurrentDefendingPlayer.selected_pokemoz}
      EndDefendingPokemoz = {Attack AttackingPokemoz DefendingPokemoz}
      EndDefendingPlayer  = {PlayerMod.updateCurrentPokemoz CurrentDefendingPlayer EndDefendingPokemoz}
    in
      {UpdateInterface EndDefendingPlayer}
      if {AllPokemozAreDead EndDefendingPlayer.pokemoz_list} then AfterEvolutionAttackingPlayer in % Fight is over
        {Lib.debug fight_is_over(winner:CurrentAttackingPlayer looser:EndDefendingPlayer)}
        AfterEvolutionAttackingPlayer = {PlayerMod.evolveSelectedPokemoz CurrentAttackingPlayer DefendingPokemoz}
        {AssignEndingStates Round AfterEvolutionAttackingPlayer EndDefendingPlayer EndAttacker EndDefender}
        {UpdateInterface AfterEvolutionAttackingPlayer}
      else FinalDefender in
        if {SelectedPokemonIsDead EndDefendingPlayer} then
          FinalDefender = {PlayerMod.switchToNextPokemoz EndDefendingPlayer}
          {Lib.debug defender_pokemon_is_dead}
          {UpdateInterface FinalDefender}
        else
          FinalDefender = EndDefendingPlayer
        end
        {RecFight FinalDefender CurrentAttackingPlayer Round+1} % Switch attack turn
      end
    end
  in
     {RecFight AttackingPlayer DefendingPlayer 0}
  end

  % Public
  fun {FightWildPokemoz InitialState}
    WildPokemoz = {Characters.summonWildPokemon InitialState}
    WildPlayer  = player(name:nil image:characters_wild position:nil pokemoz_list:[WildPokemoz] selected_pokemoz:1)
    EndAttackingPlayer
  in
    {Lib.debug fight_started_with_wild_pokemoz(WildPokemoz)}
    {Interface.updatePlayer2 WildPlayer}
    {Fight InitialState.player WildPlayer EndAttackingPlayer _}
    {GameState.updatePlayer InitialState EndAttackingPlayer}
  end
end
