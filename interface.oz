functor
import
  Module
  Lib at 'lib.ozf'
export
  Init
  DrawPlayer
  DrawWildPokemoz
  DrawEnemyTrainer
define
  [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}

  Interface
  Window

  % Private methods
  fun {PlayerArea Pokemoz}
     fun {Label Text}
        label(init:Text glue:w font:{QTk.newFont font(weight:bold)})
     end
     fun {Value Text}
        label(init:Text glue:e)
     end

     TitleLabel  = label(init:"My pokemoz" font:{QTk.newFont font(size:20 weight:bold)})

     % Name : <PokemozName>
     NameLabel   = {Label "Name:"}
     Name   = {Value {AtomToString Pokemoz.name}}
     NameLabels = lr(NameLabel Name)

     % Type : <PokemozType>
     TypeLabel   = {Label "Type:"}
     Type   = {Value {AtomToString Pokemoz.type}}
     TypeLabels= lr(TypeLabel Type)

     % Level : <PokemozLevel>
     LevelLabel  = {Label "Level:"}
     Level  = {Value {IntToString  Pokemoz.level}}
     LevelLabels = lr(LevelLabel Level)
     
     % Health : <PokemozHealth>
     HealthLabel = {Label "Health:"}
     Health = {Value {IntToString  Pokemoz.health}}
     HealthLabels = lr(HealthLabel Health)
     
     % XP : <PokemozXP>
     XPLabel     = {Label "XP:"}
     XP     = {Value {IntToString  Pokemoz.xp}}
     XPLabels = lr(XPLabel XP)
     
     %Labels = td(glue:e NameLabel TypeLabel LevelLabel HealthLabel XPLabel)    
     %Values = td(glue:w Name Type Level Health XP)
     
  in
     %td(TitleLabel lr(Labels Values))
     td(Title Label td(NameLabels TypeLabels LevelLabels HealthLabels XPLabels))
  end

  % Public method

  % Initialiser l'interface de base.
  % Nécessaire de sauver les références aux handles des différents élements pour
  % modifier le contenu plus tard via les autres méthodes.
  % (Il faut changer ce que j'ai déjà fait, ça ne convient forcément pas, c'est temporaire)
  % Ex data: game_state(turn:0 player:Player trainers:Characters.trainers)
  % Où Player = player(name:PlayerName position:StartingPos pokemoz:[StartingPokemoz])
  proc {Init GameState}
    Interface = lr({PlayerArea GameState.player.pokemoz.1})
    Window = {QTk.build Interface}
    {Window show}
    {Lib.debug auxialiary_interface_drawn}
  end

  % Afficher l'état du joueur sur la gauche.
  % Photo + nom et l'état de ses pokémons (les photos sont déjà compilées dans imageLibrary).
  % Pour chaque pokémon pareil: photo, nom, niveau, health/total health, type, etc.
  proc {DrawPlayer GameState}
    skip
  end

  % Afficher l'état d'un pokemon sauvage sur la droite.
  % Photo, nom, niveau, health/total health, type, etc.
  % Ex data: pokemoz(name:oddish type:grass level:5 health:20 xp:7)
  % (Max HP peut être dérivé du niveau => level*4)
  proc {DrawWildPokemoz WildPokemoz}
    skip
  end

  % Afficher l'état du trainer enemy sur la droite.
  % Mirroir du joueur. Mêmes infos. Pas besoin d'utiliser position.
  % Ex data: trainer(name:team_rocket  position:pos(x:6 y:6) pokemoz:[Bulbasoz Oztirtle Charmandoz])
  proc {DrawEnemyTrainer Trainer}
    skip
  end
end
