functor
import
   Module
   Lib          at 'lib.ozf'
   PokemozMod   at 'pokemoz.ozf'
export
  Init
  UpdatePlayer1
  UpdatePlayer2
  AskQuestion
  ClearPlayer2
define
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   ImageLibrary = {QTk.loadImageLibrary "ImageLibrary.ozf"}

   Player1Handles
   Player2Handles
   CenterAreaHandles

   fun {GetImage Name}
      {ImageLibrary get(name:Name image:$)}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    ____ ____  _____    _  _____ _____   _        _ __   _____  _   _ _____
%  / ___|  _ \| ____|  / \|_   _| ____| | |      / \\ \ / / _ \| | | |_   _|
% | |   | |_) |  _|   / _ \ | | |  _|   | |     / _ \\ V / | | | | | | | |
% | |___|  _ <| |___ / ___ \| | | |___  | |___ / ___ \| || |_| | |_| | | |
%  \____|_| \_\_____/_/   \_\_| |_____| |_____/_/   \_\_| \___/ \___/  |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {CreatePokemozInterface Handles Number}
     NameLabelH LevelXpLabelH HPLabelH ImageCanvasH TypeCanvasH HPGreenCanvasH HPRedCanvasH
     ImageCanvasImgH TypeCanvasImgH TopLevelH

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
     Handles = handles( top_level:          TopLevelH
                        name_label:         NameLabelH
                        level_xp_label:     LevelXpLabelH
                        hp_label_handle:    HPLabelH
                        image_canvas:       ImageCanvasH
                        type_canvas:        TypeCanvasH
                        health_green_canvas:HPGreenCanvasH
                        health_red_canvas:  HPRedCanvasH
                        pokemoz_img:        ImageCanvasImgH
                        type_img:           TypeCanvasImgH
                        )
      lr(handle:TopLevelH borderwidth:0 highlightthickness:0 background:white
         title:{VirtualString.toString "Pokemoz "#Number} ImageCanvas InfosArea)
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
                        panel1handles: Panel1H
                        panel2handles: Panel2H
                        panel3handles: Panel3H)
     lr(padx:20 pady:20 background:white glue:nsew
        td(glue:wn bg:white
          PictureCanvas
          label(handle:NameLabelH bg:white font:{QTk.newFont font(weight:bold size:25)}
                wraplength:100 glue:w justify:center anchor:center))
        Panel)
   end

   fun {CreateCenterArea}
     LabelH Button1H Button2H
   in
     CenterAreaHandles = handles(label:LabelH button1:Button1H button2:Button2H)
     td(
        pady:20
        glue:nesw
        background:white
        label(justify:center handle:LabelH background:white height:2 wraplength:100)
        lr(background:white
          button(handle:Button1H width:10)
          button(handle:Button2H width:10)
        )
     )
   end

   % We already create all the image without specifying the image.
   % We save the handles to each of them so that we can easily change them afterwards.
   proc {AddImagesToCanvas Handles}
     proc {CreateImageForPanel Handles}
       {Handles.image_canvas create(image 0 0 anchor:nw handle:Handles.pokemoz_img)}
       {Handles.type_canvas  create(image 0 0 anchor:nw handle:Handles.type_img   )}
     end
   in
     {Handles.picture_canvas create(image 0 0 anchor:nw handle:Handles.picture_img)}
     {CreateImageForPanel Handles.panel1handles}
     {CreateImageForPanel Handles.panel2handles}
     {CreateImageForPanel Handles.panel3handles}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _   _ ____  ____    _  _____ _____   _        _ __   _____  _   _ _____
%  | | | |  _ \|  _ \  / \|_   _| ____| | |      / \\ \ / / _ \| | | |_   _|
%  | | | | |_) | | | |/ _ \ | | |  _|   | |     / _ \\ V / | | | | | | | |
%  | |_| |  __/| |_| / ___ \| | | |___  | |___ / ___ \| || |_| | |_| | | |
%   \___/|_|   |____/_/   \_\_| |_____| |_____/_/   \_\_| \___/ \___/  |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   proc {UpdatePlayerInterface Player Handles}
     proc {LoopPokemoz PokemozList N}
       case PokemozList
       of nil then skip
       [] H|T then
         {FillPokemoz Handles.{VirtualString.toAtom panel#N#handles} H}
         {LoopPokemoz T N+1}
       end
     end

     proc {FillPokemoz Handles Pokemoz}
       fun {HealthGreen Pokemoz}
         {FloatToInt ({IntToFloat Pokemoz.health}/{IntToFloat {PokemozMod.maxHealth Pokemoz.level}})*100.0}
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

     SelectedPanel = Handles.{VirtualString.toAtom panel#Player.selected_pokemoz#handles}.top_level
   in
     {Handles.picture_img    set(image:{GetImage Player.image})}
     {Handles.name_label     set(text:Player.name)}
     {Handles.panel selectPanel(SelectedPanel)}
     {LoopPokemoz Player.pokemoz_list 1}
   end

   proc {ClearPlayerInterface Handles}
     proc {ClearPanel Handles}
       {Handles.name_label          set(text:nil)}
       {Handles.level_xp_label      set(text:nil)}
       {Handles.hp_label_handle     set(text:nil)}
       {Handles.pokemoz_img         set(image:nil)}
       {Handles.type_img            set(image:nil)}
       {Handles.health_green_canvas set(width:0 bg:white)}
       {Handles.health_red_canvas   set(width:0 bg:white)}
     end
   in
     {Handles.picture_img set(image:nil)}
     {Handles.name_label  set(text:nil)}
     {ClearPanel Handles.panel1handles}
     {ClearPanel Handles.panel2handles}
     {ClearPanel Handles.panel3handles}
   end

   proc {Init GameState}
     Player1   = {CreatePlayerInterface Player1Handles}
     Player2   = {CreatePlayerInterface Player2Handles}
     Center    = {CreateCenterArea}
     Interface = lr(title:"My Pokemoz" resizable:resizable(width:false height:false) background:black Player1 Center Player2)
     Window    = {QTk.build Interface}
   in
     {Window show}
     {Window set(geometry:geometry(x:50 y:500 width:1050 height:217))}
     {AddImagesToCanvas Player1Handles}
     {AddImagesToCanvas Player2Handles}
     {UpdatePlayerInterface GameState.player Player1Handles}
     {Lib.debug auxialiary_interface_drawn}
   end

  proc {UpdatePlayer1 Player}
    {UpdatePlayerInterface Player Player1Handles}
  end

  proc {UpdatePlayer2 Player}
    {UpdatePlayerInterface Player Player2Handles}
  end

  proc {ClearPlayer2}
    {ClearPlayerInterface Player2Handles}
  end


  % Used to ask question to the player.
  % We use the central area for that.
  % All the handles are in this variable: CenterAreaHandles
  % It a record like this: handles(label:LabelH button1:Button1H button2:Button2H)
  % Must set the text on both buttons, and get the answer (1 or 2 depending of the buttons selected)
  fun {AskQuestion QuestionText Button1Text Button2Text}
     AskQuestionStream AskQuestionPort 
     {NewPort AskQuestionStream AskQuestionPort}
     Answer
     proc {AskQuestionServer Stream}
	case Stream of fight|T then Answer=1
	[] run|T then Answer=2
	[] _|T then {AskQuestionServer T}
	end
     end
  in
     case CenterAreaHandles of handles(label:LabelH button1:Button1H button2:Button2H) then
	{LabelH set("Wow ! Do you think you can handle a fight ?")}
	{Button1H set(text:"Fight")}
	{Button1H set(state:normal)}
	{Button1H set(action:proc{$} {Send AskQuestionPort fight} end)}
	{Button2H set(text:"Run")}
	{Button2H set(state:normal)}
	{Button2H set(action:proc{$} {Send AskQuestionPort run} end)}
	thread {AskQuestionServer AskQuestionStream} end
	Answer
     end
  end
end
