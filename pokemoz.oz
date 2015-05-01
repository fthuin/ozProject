functor
export
  MaxHealth
  SetMaxHealth
  DealDamage
  Evolve
  BaseXpForLevel
  New
  WildPokemonLvl
  MinLevel
  MaxLevel
  Grass
  Water
  Fire
  Ground
define
  MinLevel  = 5
  MaxLevel  = 10
  Grass     = grass
  Water     = water
  Fire      = fire
  Ground    = ground
  Poison    = poison
  Electric  = electric
  Flying    = flying

  fun {New Name Type Level}
    pokemoz(name:   Name
            type:   Type
            level:  Level
            health: {PokemozMod.maxHealth Level}
            xp:     {PokemozMod.baseXpForLevel Level}
    )
  end

  fun {WildPokemonLvl Turn}
     ComputedLevel = 4 + {Lib.rand ((Turn div 10)+1)}
  in
     if ComputedLevel > PokemozMod.maxLevel then PokemozMod.maxLevel
     else ComputedLevel
     end
  end


  fun {MaxHealth Level}
     Level * 4
  end

  fun {GrassDamage OtherType}
    case OtherType
    of Grass  then 2
    [] Water  then 3
    [] Fire   then 1
    [] Ground then 3
    [] Poison then 1
    [] Electric  then 2
    [] Flying    then 1
    end
  end

  fun {WaterDamage OtherType}
    case OtherType
    of Grass  then 1
    [] Water  then 2
    [] Fire   then 3
    [] Ground then 3
    [] Poison then 2
    [] Electric  then 2
    [] Flying    then 2
    end
  end

  fun {FireDamage OtherType}
    case OtherType
    of Grass  then 3
    [] Water  then 1
    [] Fire   then 2
    [] Ground then 2
    [] Poison then 2
    [] Electric  then 2
    [] Flying    then 2
    end
  end

  fun {GroundDamage OtherType}
    case OtherType
    of Grass  then 1
    [] Water  then 2
    [] Fire   then 3
    [] Ground then 2
    [] Poison then 3
    [] Electric  then 3
    [] Flying    then 0
    end
  end

  fun {PoisonDamage OtherType}
    case OtherType
    of Grass  then 3
    [] Water  then 2
    [] Fire   then 2
    [] Ground then 1
    [] Poison then 2
    [] Electric  then 2
    [] Flying    then 2
    end
  end

  fun {ElectricDamage OtherType}
    case OtherType
    of Grass     then 1
    [] Water     then 3
    [] Fire      then 2
    [] Ground    then 0
    [] Poison    then 2
    [] Electric  then 1
    [] Flying    then 3
    end
  end

  fun {Damage AType DType}
     if AType==DType then 2
     else
        case AType#DType
        of grass#water  then 3
        [] grass#fire   then 1
        [] grass#ground then 1
        [] grass#poison then 1
        [] fire#grass   then 3
        [] fire#water   then 1
        [] water#fire   then 3
        [] water#grass  then 1
        end
     end
  end

  fun {BaseXpForLevel Level}
    case Level
    of 5  then 0
    [] 6  then 5
    [] 7  then 12
    [] 8  then 20
    [] 9  then 30
    [] 10 then 50
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
