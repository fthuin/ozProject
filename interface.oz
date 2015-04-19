functor
import
   Module
   Lib          at 'lib.ozf'
export
  Init
  DrawPlayer
  DrawPlayerPokemoz
  DrawWildPokemoz
  DrawEnemyTrainer
define
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   
   Interface
   Window
   
  % Private methods
   fun {PlayerArea PlayerName Pokemoz NameHandle TypeHandle LevelHandle HealthHandle XPHandle}
      {Lib.debug entering_playerArea_method}
      fun {Label Text}
	 label(init:Text glue:w font:{QTk.newFont font(weight:bold)})
      end
      fun {Value Text Handle}
	 label(init:Text handle:Handle glue:e)
      end
      
     %TitleLabel  = label(init:"My pokemoz" font:{QTk.newFont font(size:20 weight:bold)})

     % Name of the player
      PlayerNameLabel = label(pady:20 init:PlayerName glue:w font:{QTk.newFont font(weight:bold)})
      
     % Name : <PokemozName>
      NameLabel   = {Label "Name:"}
      Name   = {Value {AtomToString Pokemoz.name} NameHandle}
      NameLabels = lr(NameLabel Name)
      
     % Type : <PokemozType>
      TypeLabel   = {Label "Type:"}
      Type   = {Value {AtomToString Pokemoz.type} TypeHandle}
      TypeLabels= lr(TypeLabel Type)
      
     % Level : <PokemozLevel>
      LevelLabel  = {Label "Level:"}
      Level  = {Value {IntToString  Pokemoz.level} LevelHandle}
      LevelLabels = lr(LevelLabel Level)
      
     % Health : <PokemozHealth>
      HealthLabel = {Label "Health:"}
      Health = {Value {IntToString  Pokemoz.health} HealthHandle}
      HealthLabels = lr(HealthLabel Health)

     % XP : <PokemozXP>
     XPLabel     = {Label "XP:"}
     XP     = {Value {IntToString  Pokemoz.xp} XPHandle}
     XPLabels = lr(XPLabel XP)

     %Labels = td(glue:e NameLabel TypeLabel LevelLabel HealthLabel XPLabel)
     %Values = td(glue:w Name Type Level Health XP)

  in
     %td(TitleLabel lr(Labels Values))
      td(%TitleLabel
	 padx:50
	 pady:30
	td(PlayerNameLabel NameLabels TypeLabels LevelLabels HealthLabels XPLabels))
  end

  % Public method
   
   PokemozNameHandle
   PokemozTypeHandle
   PokemozLevelHandle
   PokemozHealthHandle
   PokemozXPHandle
   WildNameHandle
   WildTypeHandle
   WildLevelHandle
   WildHealthHandle
   WildXPHandle
  % Initialiser l'interface de base.
  % Nécessaire de sauver les références aux handles des différents élements pour
  % modifier le contenu plus tard via les autres méthodes.
  % (Il faut changer ce que j'ai déjà fait, ça ne convient forcément pas, c'est temporaire)
  % Ex data: game_state(turn:0 player:Player trainers:Characters.trainers)
  % Où Player = player(name:PlayerName position:StartingPos pokemoz:[StartingPokemoz])
  proc {Init GameState}
     case GameState of game_state(turn:_ player:Player trainers:_) then
	case Player of player(name:PlayerName position:_ pokemoz:ListPokemoz) then
	   PartPlayer = {PlayerArea PlayerName ListPokemoz.1 PokemozNameHandle PokemozTypeHandle PokemozLevelHandle PokemozHealthHandle PokemozXPHandle}
	   PartWild = {PlayerArea "Enemy" ListPokemoz.1 WildNameHandle WildTypeHandle WildLevelHandle WildHealthHandle WildXPHandle}
	   in
	   {Lib.debug interface_init_doublecase}
	   Interface = td(title:"My Pokemoz"
			  lr(PartPlayer
			     PartWild)
			 )
	   {Lib.debug variable_interface_linked}
	   % TODO : Gerer la liste de pokemoz ?
     	end
     end
     {Lib.debug interface_before_build}
     Window = {QTk.build Interface}
     {Lib.debug interface_after_build}
     {Window show}
     {WildNameHandle set("none")}
     {Lib.debug wild_pokemoz_set_name}
     {WildTypeHandle set("none")}
     {WildLevelHandle set("none")}
     {WildHealthHandle set("none")}
     {WildXPHandle set("none")}
     {Lib.debug auxialiary_interface_drawn}
  end

  % Afficher l'état du joueur sur la gauche.
  % Photo + nom et l'état de ses pokémons (les photos sont déjà compilées dans imageLibrary).
  % Pour chaque pokémon pareil: photo, nom, niveau, health/total health, type, etc.
  proc {DrawPlayer GameState}
     skip
  end

  proc {DrawPlayerPokemoz Pokemoz}
     {Lib.debug drawing_player_pokemoz(Pokemoz)}
     case Pokemoz of pokemoz(name:_ type:_ level:Level health:Health xp:XP) then
	   %{PokemozNameHandle set(Name)}
	   %{PokemozTypeHandle set(Type)}
	   {PokemozLevelHandle set(Level)}
	   {PokemozHealthHandle set(Health)}
	   {PokemozXPHandle set(XP)}
     end
  end


  % Afficher l'état d'un pokemon sauvage sur la droite.
  % Photo, nom, niveau, health/total health, type, etc.
  % Ex data: pokemoz(name:oddish type:grass level:5 health:20 xp:7)
  % (Max HP peut être dérivé du niveau => level*4)
  proc {DrawWildPokemoz WildPokemoz}
     case WildPokemoz of pokemoz(name:Name type:Type level:Level health:Health xp:XP) then
	{WildNameHandle set(Name)}
	{WildTypeHandle set(Type)}
	{WildLevelHandle set(Level)}
	{WildHealthHandle set(Health)}
	{WildXPHandle set(XP)}
     end
     {Lib.debug drawing_wild_pokemoz(WildPokemoz)}
  end

  % Afficher l'état du trainer enemy sur la droite.
  % Miroir du joueur. Mêmes infos. Pas besoin d'utiliser position.
  % Ex data: trainer(name:team_rocket  position:pos(x:6 y:6) pokemoz:[Bulbasoz Oztirtle Charmandoz])
  proc {DrawEnemyTrainer Trainer}
    skip
  end
end
