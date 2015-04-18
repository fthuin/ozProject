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

  fun {FightWildPokemoz InitialState Interface}
    FinalState = InitialState
    WildPokemoz = {Characters.summonWildPokemon InitialState}
  in
    {Lib.debug fight_started_against(WildPokemoz)}
    FinalState
  end


  /*proc {PokemozFight Attacker Defender ResultingAttacker ResultingDefender}
     proc {RecursivePokemozFight Attacker Defender ResultingAttacker ResultingDefender Round}
        NewDefenderHealth
        NewDefender
     in
        case Attacker#Defender
        of pokemoz(name:NA type:TA level:LA xp:XA health:HA)#pokemoz(name:ND type:TD level:LD xp:XD health:HD) then

  	 {Debug fight_round(Round)}
  	 {Debug attack(Attacker)}
  	 {Debug defense(Defender)}

  	 NewDefenderHealth = if {IsAttackSuccess Attacker Defender} then {Max 0 HD-{Damage TA TD}} else HD end
  	 NewDefender = pokemoz(name:ND type:TD level:LD xp:XD health:NewDefenderHealth)

  	 if NewDefenderHealth==0 then % Fight is over.
  	    {Debug fight_over(winner:Attacker looser:NewDefender)}
  	    if (Round mod 2)==0 then % Current attacker is original attacker.
  	       ResultingAttacker = Attacker
  	       ResultingDefender = NewDefender
  	    % true
  	    else % Current attacker is original defender.
  	       ResultingAttacker = NewDefender
  	       ResultingDefender = Attacker
  	    % false
  	    end
  	 else
  	    {RecursivePokemozFight NewDefender Attacker ResultingAttacker ResultingDefender Round+1} % Switch attack turn
  	 end
        end
     end
  in
     {RecursivePokemozFight Attacker Defender ResultingAttacker ResultingDefender 0}
  end*/

end
