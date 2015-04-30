functor
import
  Lib at 'lib.ozf'
export
  BasePokemoz
  SummonWildPokemon
  Trainers
  MaxHealth
define
  GRASS = grass
  WATER = water
  FIRE  = fire

  % Base pokemoz
  POKEMOZ_MIN_LEVEL  = 5
  POKEMOZ_MAX_LEVEL  = 10
  POKEMOZ_BASE_XP    = 0

  fun {NewPokemon Name Type Level}
    pokemoz(name:Name
            type:Type
            level:Level
            health:20
            xp:POKEMOZ_BASE_XP)
  end

  Bulbasoz   = {NewPokemon bulbasoz   GRASS POKEMOZ_MIN_LEVEL}
  Oztirtle   = {NewPokemon oztirtle   WATER POKEMOZ_MIN_LEVEL}
  Charmandoz = {NewPokemon charmandoz FIRE  POKEMOZ_MIN_LEVEL}


  WildPokemozBreedsList = [
    pokemoz(name:bellsprout   type:GRASS)
    pokemoz(name:caterpie     type:GRASS)
    pokemoz(name:lapras       type:WATER)
    pokemoz(name:magby        type:FIRE)
    pokemoz(name:magikarp     type:WATER)
    pokemoz(name:moltres      type:FIRE)
    pokemoz(name:nidoran      type:GRASS)
    pokemoz(name:oddish       type:GRASS)
    pokemoz(name:omanyte      type:WATER)
    pokemoz(name:poliwag      type:WATER)
    pokemoz(name:ponyta       type:FIRE)
    pokemoz(name:vulpix       type:FIRE)
  ]
  WildPokemozBreedsCount = {Length WildPokemozBreedsList}

  fun {GenerateWildPokemozLevel Turn}
     ComputedLevel = 4 + {Lib.rand ((Turn div 10)+1)}
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
    trainer(name:"Brock"        image:characters_brock        position:pos(x:2 y:2) pokemoz_list:[Bulbasoz] selected_pokemoz:1)
    trainer(name:"James"        image:characters_james        position:pos(x:4 y:4) pokemoz_list:[Oztirtle] selected_pokemoz:1)
    trainer(name:"May"          image:characters_may          position:pos(x:2 y:4) pokemoz_list:[Oztirtle] selected_pokemoz:1)
    trainer(name:"Misty"        image:characters_misty        position:pos(x:4 y:2) pokemoz_list:[Bulbasoz] selected_pokemoz:1)
    trainer(name:"Team rocket"  image:characters_team_rocket  position:pos(x:6 y:6) pokemoz_list:[Bulbasoz Oztirtle Charmandoz] selected_pokemoz:1)
  ]

  fun {SummonWildPokemon GameState}
    Breed       = {List.nth WildPokemozBreedsList {Lib.rand WildPokemozBreedsCount}}
    Level       = {GenerateWildPokemozLevel GameState.turn}
  in
    {NewPokemon Breed.name Breed.type Level}
  end
end
