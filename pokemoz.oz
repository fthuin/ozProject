functor
export
  MaxHealth
  SetMaxHealth
  DealDamage
  Evolve
define
  fun {MaxHealth Level}
     Level * 4
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

  fun {LevelForXp Xp}
    if Xp < 5      then 5
    elseif Xp < 12 then 6
    elseif Xp < 20 then 7
    elseif Xp < 30 then 8
    elseif Xp < 50 then 9
    else 10
    end
  end

  fun {SetMaxHealth Pokemoz}
    case Pokemoz
    of   pokemoz(name:Name type:Type level:Level health:_ xp:Xp)
    then pokemoz(name:Name type:Type level:Level health:{MaxHealth Level} xp:Xp)
    end
  end

  % Return defender
  fun {DealDamage Defender AttackerType}
    case Defender
    of pokemoz(name:Name type:Type level:Level health:Health xp:Xp)
    then Dmg = {Damage AttackerType Type}
    in pokemoz(name:Name type:Type level:Level health:{Max 0 (Health-Dmg)} xp:Xp)
    end
  end

  fun {Evolve Pokemon DefeatedPokemoz}
    case Pokemon
    of   pokemoz(name:Name type:Type level:Level health:Health xp:Xp)
    then
      NewXp    = Xp+DefeatedPokemoz.level
      NewLevel = {LevelForXp NewXp}
      NewHp    = if NewLevel==Level then Health else {MaxHealth NewLevel} end
    in pokemoz(name:Name type:Type level:NewLevel health:NewHp xp:NewXp)
    end
  end

end
