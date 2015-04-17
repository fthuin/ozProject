functor
import
   Module
   Lib at 'lib.ozf'
export
  Draw
define
  [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}

  % Private methods
  fun {PokemozArea Pokemoz}
     fun {Label Text}
        label(init:Text glue:w font:{QTk.newFont font(weight:bold)})
     end
     fun {Value Text}
        label(init:Text glue:e)
     end

     TitleLabel  = label(init:"My pokemoz" font:{QTk.newFont font(size:20 weight:bold)})

     % Column of labels
     NameLabel   = {Label "Name:"}
     TypeLabel   = {Label "Type:"}
     LevelLabel  = {Label "Level:"}
     HealthLabel = {Label "Health:"}
     XPLabel     = {Label "XP:"}
     Labels = td(glue:e NameLabel TypeLabel LevelLabel HealthLabel XPLabel)

     % Column of values
     Name   = {Value {AtomToString Pokemoz.name}}
     Type   = {Value {AtomToString Pokemoz.type}}
     Level  = {Value {IntToString  Pokemoz.level}}
     Health = {Value {IntToString  Pokemoz.health}}
     XP     = {Value {IntToString  Pokemoz.xp}}
     Values = td(glue:w Name Type Level Health XP)
  in
     td(TitleLabel lr(Labels Values))
  end

  % Public method
  proc {Draw GameState}
     Interface = lr({PokemozArea GameState.pokemoz.1})
     Window = {QTk.build Interface}
  in
     {Window show}
     {Lib.debug auxialiary_interface_drawn}
  end

end
