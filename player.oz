functor
import
  Lib        at 'lib.ozf'
export
  UpdatePokemoz
  UpdateCurrentPokemoz
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
end
