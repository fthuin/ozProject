functor
import
  Lib        at 'lib.ozf'
  Characters at 'characters.ozf'
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

  fun {Damage AType DType}
     if AType==DType then 2
     else
        case AType#DType
        of grass#water  then 3
        [] grass#fire   then 1
        [] fire#grass   then 3
        [] fire#water   then 1
        [] water#fire   then 3
        [] water#grass  then 1
        end
     end
  end

  % Return resulting defender after an attack.
  fun {DealDamage Attacker Defender}
    case Defender
    of pokemoz(name:Name type:Type level:Level xp:Xp health:Health) then
      if {IsAttackSuccess Attacker Defender} then
        NewHealth = {Max 0 Health-{Damage Attacker.type Type}} in
        pokemoz(name:Name type:Type level:Level xp:Xp health:NewHealth)
      else
        Defender
      end
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



  fun {ReplaceNthInList List Nth NewElement}
    case List
    of nil then nil
    [] H|T then
      if Nth>1 then H|{ReplaceNthInList T Nth-1 NewElement}
      else NewElement|T end
    end
  end

  fun {UpdateSelectedPokemoz Player NewPokemoz} NewList in
    case Player of player(name:Name image:Img position:Pos pokemoz_list:OriginalList selected_pokemoz:SP) then
      NewList = {ReplaceNthInList OriginalList SP NewPokemoz}
      player(name:Name image:Img position:Pos pokemoz_list:NewList selected_pokemoz:SP)
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
      EndDefendingPokemoz = {DealDamage AttackingPokemoz DefendingPokemoz}
      EndDefendingPlayer  = {UpdateSelectedPokemoz CurrentDefendingPlayer EndDefendingPokemoz}
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
