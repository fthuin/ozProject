functor
export
  BasePokemoz
  WildPokemozList
  Trainers
define
  GRASS = grass
  WATER = water
  FIRE  = fire

  Bulbasoz   = pokemoz(name:bulbasoz   type:GRASS level:5 health:20 xp:0)
  Oztirtle   = pokemoz(name:oztirtle   type:WATER level:5 health:20 xp:0)
  Charmandoz = pokemoz(name:charmandoz type:FIRE  level:5 health:20 xp:0)

  BasePokemoz = base_pokemoz(
    bulbasoz:Bulbasoz
    oztirtle:Oztirtle
    charmandoz:Charmandoz
  )

  WildPokemozList = [
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

  Trainers = [
    trainer(name:brock        position:pos(x:2 y:2) pokemoz:[Bulbasoz])
    trainer(name:james        position:pos(x:4 y:4) pokemoz:[Oztirtle])
    trainer(name:may          position:pos(x:2 y:4) pokemoz:[Oztirtle])
    trainer(name:misty        position:pos(x:4 y:2) pokemoz:[Bulbasoz])
    trainer(name:team_rocket  position:pos(x:6 y:6) pokemoz:[Bulbasoz Oztirtle Charmandoz])
  ]

end
