functor
import
  PokemozMod at 'pokemoz.ozf'
  Lib        at 'lib.ozf'
export
  BasePokemoz
  SummonWildPokemon
  Brock
  James
  Misty
define
  WildPokemozBreedsList = [
    pokemoz(name:bellsprout   type:PokemozMod.grass)
    pokemoz(name:caterpie     type:PokemozMod.grass)
    pokemoz(name:lapras       type:PokemozMod.water)
    pokemoz(name:magby        type:PokemozMod.fire)
    pokemoz(name:magikarp     type:PokemozMod.water)
    pokemoz(name:moltres      type:PokemozMod.fire)
    pokemoz(name:nidoran      type:PokemozMod.grass)
    pokemoz(name:oddish       type:PokemozMod.grass)
    pokemoz(name:omanyte      type:PokemozMod.water)
    pokemoz(name:poliwag      type:PokemozMod.water)
    pokemoz(name:ponyta       type:PokemozMod.fire)
    pokemoz(name:vulpix       type:PokemozMod.fire)
    pokemoz(name:onix         type:PokemozMod.ground)
    pokemoz(name:geodude      type:PokemozMod.ground)
    pokemoz(name:koffing      type:PokemozMod.poison)
    pokemoz(name:horsea       type:PokemozMod.water)
  ]
  WildPokemozBreedsCount = {Length WildPokemozBreedsList}

  BasePokemoz = base_pokemoz(
    bulbasoz:   {PokemozMod.new bulbasoz   PokemozMod.grass PokemozMod.minLevel}
    oztirtle:   {PokemozMod.new oztirtle   PokemozMod.water PokemozMod.minLevel}
    charmandoz: {PokemozMod.new charmandoz PokemozMod.fire  PokemozMod.minLevel}
  )

  Brock = player(name:"Brock"  image:characters_brock position:nil
            selected_pokemoz:1 pokemoz_list:[
              {PokemozMod.new geodude  PokemozMod.ground 8}
              {PokemozMod.new onix     PokemozMod.ground 10}
            ])

  James = player(name:"James"  image:characters_james position:nil
            selected_pokemoz:1 pokemoz_list:[
              {PokemozMod.new bellsprout  PokemozMod.ground 5}
              {PokemozMod.new koffing     PokemozMod.ground 7}
            ])

  Misty = player(name:"Misty"  image:characters_misty position:nil
             selected_pokemoz:1 pokemoz_list:[
                {PokemozMod.new horsea      PokemozMod.ground 7}
                {PokemozMod.new poliwag     PokemozMod.ground 9}
             ])

  fun {SummonWildPokemon GameState}
    Breed       = {List.nth WildPokemozBreedsList {Lib.rand WildPokemozBreedsCount}}
    Level       = {PokemozMod.wildPokemonLvl GameState.turn}
  in
    {PokemozMod.new Breed.name Breed.type Level}
  end
end
