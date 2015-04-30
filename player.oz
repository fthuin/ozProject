functor
import
  Lib        at 'lib.ozf'
  PokemozMod at 'pokemoz.ozf'
export
  UpdatePokemoz
  UpdateCurrentPokemoz
  UpdatePosition
  SwitchToPokemoz
  SwitchToNextPokemoz
  HealPokemoz
  EvolveSelectedPokemoz
define
  fun {UpdatePokemoz Player NewPokemoz Index}
    case Player
    of player(name:Name image:Img position:Pos pokemoz_list:List selected_pokemoz:SP)
    then NewList = {Lib.replaceNthInList List Index NewPokemoz}
    in player(name:Name image:Img position:Pos pokemoz_list:NewList selected_pokemoz:SP)
    end
  end

  fun {UpdateCurrentPokemoz Player NewPokemoz}
    {UpdatePokemoz Player NewPokemoz Player.selected_pokemoz}
  end

  fun {SwitchToPokemoz Player Index}
    case Player
    of   player(name:Name image:Img position:Pos pokemoz_list:List selected_pokemoz:_)
    then player(name:Name image:Img position:Pos pokemoz_list:List selected_pokemoz:Index)
    end
  end

  fun {SwitchToNextPokemoz Player}
    {SwitchToPokemoz Player Player.selected_pokemoz+1}
  end

  fun {UpdatePosition Player Direction}
    case Player
    of player(name:Name image:Img position:pos(x:X y:Y) pokemoz_list:Pokemoz selected_pokemoz:SP)
    then X2 Y2 in
      case Direction
      of up    then X2 = X    Y2 = Y-1
      [] right then X2 = X+1  Y2 = Y
      [] down  then X2 = X    Y2 = Y+1
      [] left  then X2 = X-1  Y2 = Y
      end
      player(name:Name image:Img position:pos(x:X2 y:Y2) pokemoz_list:Pokemoz selected_pokemoz:SP)
    end
  end

  fun {HealPokemoz Player}
    fun {HealPokemozRec PokemozList}
      case PokemozList
      of nil then nil
      [] H|T then {PokemozMod.setMaxHealth H}|{HealPokemozRec T}
      end
    end
  in
    case Player
    of   player(name:Name image:Img position:Pos pokemoz_list:Pokemoz                  selected_pokemoz:SP)
    then player(name:Name image:Img position:Pos pokemoz_list:{HealPokemozRec Pokemoz} selected_pokemoz:SP)
    end
  end

  fun {EvolveSelectedPokemoz Player DefeatedPokemoz}
    case Player
    of   player(name:Name image:Img position:Pos pokemoz_list:PokemozList selected_pokemoz:SP)
    then EvolvedPokemon = {PokemozMod.evolve {List.nth PokemozList SP} DefeatedPokemoz}
         NewPokemonList = {Lib.replaceNthInList PokemozList SP EvolvedPokemon}
    in player(name:Name image:Img position:Pos pokemoz_list:NewPokemonList selected_pokemoz:SP)
    end
  end


end
