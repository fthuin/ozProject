functor
import
   Module
   Lib          at 'lib.ozf'
   Characters   at 'characters.ozf'
export
  Init
  DrawPlayer
  DrawPlayerPokemoz
  DrawWildPokemoz
  DrawEnemyTrainer
define
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   ImageLibrary = {QTk.loadImageLibrary "ImageLibrary.ozf"}

   Player1Handles
   Player2Handles

   fun {GetImage Name}
      {ImageLibrary get(name:Name image:$)}
   end

   Interface
   Window

   fun {CreatePokemozInterface Handles Number}
     NameLabelH LevelXpLabelH HPLabelH ImageCanvasH TypeCanvasH HPGreenCanvasH HPRedCanvasH TopLevel
     ImageCanvasImgH TypeCanvasImgH

     ImageCanvas = canvas(handle:ImageCanvasH glue:w width:150 height:150 bg:white borderwidth:0 highlightthickness:0)
     TypeCanvas  = canvas(handle:TypeCanvasH  glue:e width:40  height:40  bg:white borderwidth:0 highlightthickness:0)
     InfosArea   = td(background:white glue:nswe
        lr(background:white
          label(handle:NameLabelH font:{QTk.newFont font(weight:bold size:16)} glue:w bg:white)
          TypeCanvas
        )
        label(handle:LevelXpLabelH bg:white)
        lr(background:white
          label(handle:HPLabelH bg:white)
          canvas(width:0 height:30 handle:HPGreenCanvasH bg:white borderwidth:0 highlightthickness:0)
          canvas(width:0 height:30 handle:HPRedCanvasH   bg:white borderwidth:0 highlightthickness:0)
        )
     )
   in
     Handles = handles( name_label:         NameLabelH
                        level_xp_label:     LevelXpLabelH
                        hp_label_handle:    HPLabelH
                        image_canvas:       ImageCanvasH
                        type_canvas:        TypeCanvasH
                        health_green_canvas:HPGreenCanvasH
                        health_red_canvas:  HPRedCanvasH
                        pokemoz_img:        ImageCanvasImgH
                        type_img:           TypeCanvasImgH
                        )
      lr(borderwidth:0 highlightthickness:0 background:white title:{VirtualString.toString "Pokemoz "#Number} ImageCanvas InfosArea)
   end


   fun {CreatePlayerInterface Handles}
     PanelH PictureCanvasH NameLabelH PictureImgH Panel1H Panel2H Panel3H
     PictureCanvas = canvas(handle:PictureCanvasH glue:w width:100 height:100
                            bg:white borderwidth:0 highlightthickness:0)
     Panel=panel(borderwidth:0 highlightthickness:0 glue:n handle:PanelH bg:white
        {CreatePokemozInterface Panel1H 1}
        {CreatePokemozInterface Panel2H 2}
        {CreatePokemozInterface Panel3H 3}
     )
   in
     Handles = handles( panel:          PanelH
                        picture_canvas: PictureCanvasH
                        picture_img:    PictureImgH
                        name_label:     NameLabelH
                        panel1:         Panel1H
                        panel2:         Panel2H
                        panel3:         Panel3H)
     lr(padx:20 pady:20 background:white glue:nsew
        td(glue:wn bg:white
          PictureCanvas
          label(handle:NameLabelH bg:white font:{QTk.newFont font(weight:bold size:25)}
                wraplength:100 glue:w justify:center anchor:center))
        Panel)
   end

   proc {FillPlayerInterface Player Handles}

     proc {LoopPokemoz PokemozList N}
       case PokemozList
       of nil then skip
       [] H|T then
         {FillPokemoz Handles.{VirtualString.toAtom panel#N} H}
         {LoopPokemoz T N+1}
       end
     end

     proc {FillPokemoz Handles Pokemoz}
       fun {HealthGreen Pokemoz}
         {FloatToInt ({IntToFloat Pokemoz.health}/{IntToFloat {Characters.maxHealth Pokemoz.level}})*100.0}
       end
       GreenWidth       = {HealthGreen Pokemoz}
       RedWidth         = 100 - GreenWidth
       BackgroundGreen  = if GreenWidth==0 then white else green end
       BackgroundRed    = if RedWidth==0   then white else red   end   % Hack since 0 pixel still appears...
     in
       {Handles.name_label          set(text:Pokemoz.name)}
       {Handles.level_xp_label      set(text:{VirtualString.toString "Level "#Pokemoz.level#" - "#Pokemoz.xp#" XP"})}
       {Handles.hp_label_handle     set(text:{VirtualString.toString Pokemoz.health#" HP"})}
       {Handles.pokemoz_img         set(image:{GetImage {VirtualString.toAtom pokemoz_#Pokemoz.name}})}
       {Handles.type_img            set(image:{GetImage {VirtualString.toAtom types_#Pokemoz.type}})}
       {Handles.health_green_canvas set(width:GreenWidth bg:BackgroundGreen)}
       {Handles.health_red_canvas   set(width:RedWidth   bg:BackgroundRed)}
     end
   in
     {Handles.picture_img    set(image:{GetImage Player.image})}
     {Handles.name_label     set(text:Player.name)}
     {LoopPokemoz Player.pokemoz 1}
   end


   fun {CenterArea}
     td(
        pady:20
        glue:nesw
        background:white
        label(justify:center background:white height:2 text:"You meet a wild pokemon..." wraplength:100)
        lr(background:white
          button(text:"Fight!" width:10)
          button(text:"Run!"   width:10)
        )
     )
   end

   % We already create all the image without specifying the image.
   % We save the handles to each of them so that we can easily change them afterwards.
   proc {AddImagesToCanvas Handles}
     proc {CreateImageForPanel Handles}
       {Handles.image_canvas create(image 0 0 anchor:nw handle:Handles.pokemoz_img)}
       {Handles.type_canvas  create(image 0 0 anchor:nw handle:Handles.type_img)}
     end
   in
     {Handles.picture_canvas      create(image 0 0 anchor:nw handle:Handles.picture_img)}
     {CreateImageForPanel Handles.panel1}
     {CreateImageForPanel Handles.panel2}
     {CreateImageForPanel Handles.panel3}
   end


   proc {Init GameState}
     Player1 = {CreatePlayerInterface Player1Handles}
     Player2 = {CreatePlayerInterface Player2Handles}
     Center  = {CenterArea}
     Interface = lr(title:"My Pokemoz" resizable:resizable(width:false height:false) background:black Player1 Center Player2)
   in
     Window = {QTk.build Interface}
     {Window show}
     {Window set(geometry:geometry(x:50 y:500 width:1050 height:217))}
     {AddImagesToCanvas Player1Handles}
     {AddImagesToCanvas Player2Handles}
     {FillPlayerInterface GameState.player Player1Handles}
   end


   % Private methods
   fun {PlayerArea PlayerName Pokemoz NameHandle TypeHandle LevelHandle HealthHandle XPHandle}
      fun {Label Text}
	       label(init:Text glue:w font:{QTk.newFont font(weight:bold)})
      end

      fun {Value Text Handle}
	       label(init:Text handle:Handle glue:e)
      end

     %TitleLabel  = label(init:"My pokemoz" font:{QTk.newFont font(size:20 weight:bold)})

     PlayerNameLabel = label(pady:20 init:PlayerName glue:w font:{QTk.newFont font(weight:bold)})


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
  /*proc {Init GameState}
     case GameState of game_state(turn:_ player:Player trainers:_) then
	      case Player of player(name:PlayerName position:_ pokemoz:ListPokemoz) then
	         PartPlayer = {PlayerArea PlayerName ListPokemoz.1 PokemozNameHandle PokemozTypeHandle PokemozLevelHandle PokemozHealthHandle PokemozXPHandle}
	         PartWild = {PlayerArea "Enemy" ListPokemoz.1 WildNameHandle WildTypeHandle WildLevelHandle WildHealthHandle WildXPHandle}
	   in
	   Interface = td(title:"My Pokemoz"
			  lr(PartPlayer
			     PartWild)
			 )
	   % TODO : Gerer la liste de pokemoz ?
     	end
     end
     {Lib.debug interface_before_build}
     Window = {QTk.build Interface}
     {Window show}
     {WildNameHandle set("none")}
     {WildTypeHandle set("none")}
     {WildLevelHandle set("none")}
     {WildHealthHandle set("none")}
     {WildXPHandle set("none")}
     {Lib.debug auxialiary_interface_drawn}
  end*/

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
