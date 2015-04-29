functor
import
  Lib        at 'lib.ozf'
  Characters at 'characters.ozf'
export
  FightWildPokemoz
define

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

  proc {UpdateInterface Interface Round Pokemoz}
    if (Round mod 2)==0 then % Current attacker is original attacker (player).
      {Lib.debug player_attacks_wild_pokemon(round:Round)}
      {Interface.updatePlayer2 player(name:"" image:characters_wild pokemoz:[Pokemoz])}
    else
      {Lib.debug wild_pokemon_attacks_player(round:Round)}
      {Interface.updatePlayer1 player(name:"Greg" image:characters_player pokemoz:[Pokemoz])} %TODO: TEMPORARY. IMPLMENT MULTIPLE POKEMONS FIGHTS
    end
  end

  proc {PokemozFight Attacker Defender EndAttacker EndDefender Interface}
    proc {RecFight A D Round} NewDef in
      NewDef = {DealDamage A D}
      {UpdateInterface Interface Round NewDef}
      if NewDef.health == 0 then % Fight is over.
        {Lib.debug fight_is_over(winner:A looser:NewDef)}
        {AssignEndingStates Round A NewDef EndAttacker EndDefender}
      else
        {RecFight NewDef A Round+1} % Switch attack turn
      end
    end
  in
     {RecFight Attacker Defender 0}
  end

  fun {ReplacePlayerPokemonListState GameState NewPokemozList}
    case GameState
    of game_state(turn:Turn
                  player:player(name:Name image:Img position:Pos pokemoz:_)
                  trainers:Trainers) then
       game_state(turn:Turn
                  player:player(name:Name image:Img position:Pos pokemoz:NewPokemozList)
                  trainers:Trainers)
    end
  end


  % Public
  fun {FightWildPokemoz InitialState Interface}
    WildPokemoz = {Characters.summonWildPokemon InitialState}
    EndAttacker EndDefender
  in
    {Lib.debug fight_started_with_wild_pokemoz(WildPokemoz)}
    {Interface.updatePlayer2 player(name:"" image:characters_wild pokemoz:[WildPokemoz])}
    {PokemozFight InitialState.player.pokemoz.1 WildPokemoz EndAttacker EndDefender Interface}
    {ReplacePlayerPokemonListState InitialState [EndAttacker]}
    % TODO: Ask for capture?
  end
end
