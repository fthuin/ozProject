functor
import
  Lib        at 'lib.ozf'
  Characters at 'characters.ozf'
  Pokemoz    at 'pokemoz.ozf'
  Player     at 'player.ozf'
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
    then {Pokemoz.dealDamage Defender Attacker.type}
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
    [] H|T then
      {Lib.debug head(H)}
      {Lib.debug tail(T)}
      if H.health==0 then {AllPokemozAreDead T}
      else false
      end
    end
  end

  fun {SelectedPokemonIsDead Player}
    {List.nth Player.pokemoz_list Player.selected_pokemoz}.health==0
  end

  fun {SwitchToNextPokemon Player}
    case Player of player(name:Name image:Img position:Pos pokemoz_list:List selected_pokemoz:SP) then
      player(name:Name image:Img position:Pos pokemoz_list:List selected_pokemoz:SP+1)
    end
  end


  proc {Fight AttackingPlayer DefendingPlayer EndAttacker EndDefender}
    proc {UpdateInterface Player}
      if Player.image == characters_player then % Player
        {Interface.updatePlayer1 Player}
      else
        {Interface.updatePlayer2 Player}
      end
    end

    proc {RecFight CurrentAttackingPlayer CurrentDefendingPlayer Round}
      AttackingPokemoz    = {List.nth CurrentAttackingPlayer.pokemoz_list CurrentAttackingPlayer.selected_pokemoz}
      DefendingPokemoz    = {List.nth CurrentDefendingPlayer.pokemoz_list CurrentDefendingPlayer.selected_pokemoz}
      EndDefendingPokemoz = {Attack AttackingPokemoz DefendingPokemoz}
      EndDefendingPlayer  = {Player.updateCurrentPokemoz CurrentDefendingPlayer EndDefendingPokemoz}
    in
      {UpdateInterface EndDefendingPlayer}
      if {AllPokemozAreDead EndDefendingPlayer.pokemoz_list} then % Fight is over
        {Lib.debug fight_is_over(winner:CurrentAttackingPlayer looser:EndDefendingPlayer)}
        {AssignEndingStates Round CurrentAttackingPlayer EndDefendingPlayer EndAttacker EndDefender}
      else AfterSwapDefender in
        if {SelectedPokemonIsDead EndDefendingPlayer} then
          AfterSwapDefender = {SwitchToNextPokemon EndDefendingPlayer}
          {Lib.debug defender_pokemon_is_dead}
          {UpdateInterface AfterSwapDefender}
        else
          AfterSwapDefender = EndDefendingPlayer
        end
        {RecFight AfterSwapDefender CurrentAttackingPlayer Round+1} % Switch attack turn
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
    case InitialState of game_state(turn:Turn player:_ trainers:Trainers) then
      game_state(turn:Turn player:EndAttackingPlayer trainers:Trainers)
    end
  end
end
