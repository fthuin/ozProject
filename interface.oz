functor
import
   Module
   Lib at 'lib.ozf'
export
  Draw
define
  [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}

  % Private methods
  fun {PlayerArea Pokemoz}
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

  % Initialiser l'interface de base.
  % Nécessaire de sauver les références aux handles des différents élements pour
  % modifier le contenu plus tard via les autres méthodes.
  % (Il faut changer ce que j'ai déjà fait, ça ne convient forcément pas, c'est temporaire)
  % Game a la forme suivante:
  % game_state(turn:0 player_position:StartingPos pokemoz:[FirstPokemoz SecondPokemoz])
  proc {Init GameState}
    Interface = lr({PlayerArea GameState.pokemoz.1})
    Window = {QTk.build Interface}
    {Window show}
    {Lib.debug auxialiary_interface_drawn}
  end

  % Afficher l'état du joueur sur la gauche.
  % Photo + nom et l'état de ses pokémons (les photos sont déjà compilées dans imageLibrary).
  % Pour chaque pokémon pareil: photo, nom, niveau, health/total health, type, etc.
  proc {DrawPlayer GameState}
  end

  % Afficher l'état d'un pokemon sauvage sur la droite.
  % Photo, nom, niveau, health/total health, type, etc.
  % Ex data: pokemoz(name:bulbasoz type:grass level:5 health:20 xp:7)
  % Max HP can be derived from the level (level*4)
  proc {DrawWildPokemoz WildPokemoz}
  end

  % Afficher l'état du trainer enemy sur la droite.
  % Mirroir du joueur. Mêmes infos. Pas besoin d'utiliser position.
  % Ex data: trainer(name:brock position:pos(x:2 y:2) pokemoz:[Pokemoz1 Pokemoz2])
  proc {DrawEnemyTrainer Trainer}
  end
end
