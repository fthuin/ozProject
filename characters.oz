functor
import
  Lib at 'lib.ozf'
export
  BasePokemoz
  SummonWildPokemon
  Trainers
define
  GRASS = grass
  WATER = water
  FIRE  = fire

  % Base pokemoz
  POKEMOZ_MIN_LEVEL  = 5
  POKEMOZ_MAX_LEVEL  = 10
  POKEMOZ_BASE_XP    = 0

  fun {MaxHealth Level}
     Level * 4
  end

  fun {NewPokemon Name Type Level}
    pokemoz(name:Name
            type:Type
            level:Level
            health:{MaxHealth POKEMOZ_MIN_LEVEL}
            xp:POKEMOZ_BASE_XP)
  end

  Bulbasoz   = {NewPokemon bulbasoz   GRASS POKEMOZ_MIN_LEVEL}
  Oztirtle   = {NewPokemon oztirtle   WATER POKEMOZ_MIN_LEVEL}
  Charmandoz = {NewPokemon charmandoz FIRE  POKEMOZ_MIN_LEVEL}


  WildPokemozBreedsList = [
    pokemoz(name:bellsprout   type:GRASS)
    pokemoz(name:caterpie     type:GRASS)
    pokemoz(name:nidoran      type:GRASS)
    pokemoz(name:oddish       type:GRASS)
    pokemoz(name:poliwag      type:WATER)
    pokemoz(name:magikarp     type:WATER)
    pokemoz(name:lapras       type:WATER)
    pokemoz(name:omanyte      type:WATER)
    pokemoz(name:magby        type:FIRE)
    pokemoz(name:ponyta       type:FIRE)
    pokemoz(name:vulpix       type:FIRE)
    pokemoz(name:moltres      type:FIRE)
  ]
  WildPokemozBreedsCount = {Length WildPokemozBreedsList}

  fun {GenerateWildPokemozLevel Turn}
     ComputedLevel = 5 + {Lib.rand (Turn div 10)}
  in
     if ComputedLevel > POKEMOZ_MAX_LEVEL then POKEMOZ_MAX_LEVEL
     else ComputedLevel
     end
  end

  % Public

  BasePokemoz = base_pokemoz(
    bulbasoz:Bulbasoz
    oztirtle:Oztirtle
    charmandoz:Charmandoz
  )

  Trainers = [
    trainer(name:brock        position:pos(x:2 y:2) pokemoz:[Bulbasoz])
    trainer(name:james        position:pos(x:4 y:4) pokemoz:[Oztirtle])
    trainer(name:may          position:pos(x:2 y:4) pokemoz:[Oztirtle])
    trainer(name:misty        position:pos(x:4 y:2) pokemoz:[Bulbasoz])
    trainer(name:team_rocket  position:pos(x:6 y:6) pokemoz:[Bulbasoz Oztirtle Charmandoz])
  ]

  fun {SummonWildPokemon GameState}
    Breed       = {List.nth WildPokemozBreedsList {Lib.rand WildPokemozBreedsCount}}
    Level       = {GenerateWildPokemozLevel GameState.turn}
  in
    {NewPokemon Breed.name Breed.type Level}
  end
end
