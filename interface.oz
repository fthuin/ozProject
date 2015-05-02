functor
import
   Module
   Lib          at 'lib.ozf'
   PokemozMod   at 'pokemoz.ozf'
export
  Init
  UpdatePlayer1
  ShowPlayer2
  UpdatePlayer2
  HidePlayer2
  AskQuestion
  WriteMessage
  SelectPlayer1Panel
define
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   ImageLibrary = {QTk.loadImageLibrary "ImageLibrary.ozf"}

   Player1Handles
   Player2Handles
   CenterAreaHandles
   BindKeys
   UnbindKeys

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
        lr(bg:white
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
     PlaceHolderH TopLevelH PanelH PictureCanvasH NameLabelH PictureImgH Panel1H Panel2H Panel3H
     PictureCanvas = canvas(handle:PictureCanvasH glue:w width:100 height:100
                            bg:white borderwidth:0 highlightthickness:0)
     Panel = panel(borderwidth:0 highlightthickness:0 glue:n handle:PanelH bg:white
        {CreatePokemozInterface Panel1H 1}
        {CreatePokemozInterface Panel2H 2}
        {CreatePokemozInterface Panel3H 3}
     )
     Content = lr(background:white glue:nsew handle:TopLevelH
                 td(glue:wn bg:white
                   PictureCanvas
                   label(handle:NameLabelH bg:white font:{QTk.newFont font(weight:bold size:25)}
                         wraplength:100 glue:w justify:center anchor:center))
                 Panel)
   in
     Handles = handles( place_holder:   PlaceHolderH
                        top_level:      TopLevelH
                        panel:          PanelH
                        picture_canvas: PictureCanvasH
                        picture_img:    PictureImgH
                        name_label:     NameLabelH
                        panel1handles:  Panel1H
                        panel2handles:  Panel2H
                        panel3handles:  Panel3H)
     placeholder(glue:ns handle:PlaceHolderH background:white width:394 padx:20 pady:20 Content)
   end

   CenterAreaPlaceHolderH
   fun {CreateCenterAreaPlaceHolder}
     td(glue:ns padx:0 pady:20
        canvas(bg:white width:300 height:0) % Hack to constrain the width...
        placeholder(glue:nsew bg:white handle:CenterAreaPlaceHolderH background:white))
   end

   proc {CreateCenterAreaDialogs}
     PlaceHolderH
     InfoToplevel InfoLabel InfoBtn
     QuestionTopLevel QuestionLabel QuestionBtnYes QuestionBtnNo
     PokemozChoiceTopLevel PokemozChoiceLabel PokemozChoice1 PokemozChoice2 PokemozChoice3

     Info = td(handle:InfoToplevel bg:white
       label(justify:center handle:InfoLabel background:white height:6 width:30 wraplength:260)
       button(handle:InfoBtn width:10)
     )
     {CenterAreaPlaceHolderH set(Info)}
     {CenterAreaPlaceHolderH set(empty)}

     Question = td(handle:QuestionTopLevel bg:white
       label(justify:center handle:QuestionLabel background:white height:6 width:30 wraplength:260)
       lr(bg:white
         button(handle:QuestionBtnYes width:10)
         button(handle:QuestionBtnNo  width:10)
       )
     )
     {CenterAreaPlaceHolderH set(Question)}
     {CenterAreaPlaceHolderH set(empty)}

     PokemozChoice = td(handle:PokemozChoiceTopLevel bg:white
        label(justify:center handle:PokemozChoiceLabel background:white height:6 width:30 wraplength:260)
        td(bg:white
          button(handle:PokemozChoice1 width:20)
          button(handle:PokemozChoice2 width:20)
          button(handle:PokemozChoice3 width:20)
        )
     )
     {CenterAreaPlaceHolderH set(PokemozChoice)}
     {CenterAreaPlaceHolderH set(empty)}
   in
     CenterAreaHandles = handles( place_holder:   CenterAreaPlaceHolderH
                                  info:info(
                                      top_level: InfoToplevel
                                      label:     InfoLabel
                                      btn:       InfoBtn
                                  )
                                  question:question(
                                      top_level: QuestionTopLevel
                                      label:     QuestionLabel
                                      btn_yes:   QuestionBtnYes
                                      btn_no:    QuestionBtnNo
                                  )
                                  pokemoz_choice(
                                      top_level: PokemozChoiceTopLevel
                                      label:     PokemozChoiceLabel
                                      choice1:   PokemozChoice1
                                      choice2:   PokemozChoice2
                                      choice3:   PokemozChoice3
                                  ))
      skip
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

   proc {Init PlaceHolder GameState BindKeyboardActions UnbindKeyboardActions}
     Player1    = {CreatePlayerInterface Player1Handles}
     Player2    = {CreatePlayerInterface Player2Handles}
     Center     = {CreateCenterAreaPlaceHolder}
     Content    = lr(Player1 Center Player2)
   in
     BindKeys   = BindKeyboardActions
     UnbindKeys = UnbindKeyboardActions
     {PlaceHolder set(Content)}
     {CreateCenterAreaDialogs}
     {AddImagesToCanvas Player1Handles}
     {AddImagesToCanvas Player2Handles}
     {HidePlayer2}
     {HideCenterArea}
     {UpdatePlayerInterface GameState.player Player1Handles}
     {Lib.debug auxialiary_interface_drawn}
   end

  proc {HideCenterArea}
    {CenterAreaHandles.place_holder set(empty)}
  end

  proc {UpdatePlayer1 Player}
    {UpdatePlayerInterface Player Player1Handles}
  end

  proc {ShowPlayer2 Player}
    {UpdatePlayerInterface Player Player2Handles}
    {Player2Handles.place_holder set(Player2Handles.top_level)}
  end

  proc {UpdatePlayer2 Player}
    {UpdatePlayerInterface Player Player2Handles}
  end

  proc {HidePlayer2}
    {Player2Handles.place_holder set(empty)}
    {ClearPlayerInterface Player2Handles}
  end

  proc {SelectPlayer1Panel Index}
    {Player1Handles.panel selectPanel(Player1Handles.{VirtualString.toAtom panel#Index#handles}.top_level)}
  end

  proc {CenterAreaCleanup}
    {HideCenterArea}
    {BindKeys}
  end

  fun {AskQuestion QuestionText BtnTrueText BtnFalseText}
    {UnbindKeys}
    Answer
    proc {HitBtnTrue}  Answer=false end
    proc {HitBtnFalse} Answer=true end
  in
    {CenterAreaHandles.question.label     set(text:QuestionText)}
    {CenterAreaHandles.question.btn_yes   set(text:BtnTrueText action:HitBtnTrue)}
    {CenterAreaHandles.question.btn_no    set(text:BtnFalseText action:HitBtnFalse)}

    {CenterAreaHandles.place_holder set(CenterAreaHandles.question.top_level)}

    if Answer==true then {CenterAreaCleanup} Answer else {CenterAreaCleanup} Answer end
  end

  proc {WriteMessage Message}
    {UnbindKeys}
    Answer
    proc {HitBtn} Answer=0 end
  in
    {CenterAreaHandles.info.label   set(text:Message)}
    {CenterAreaHandles.info.btn     set(text:"Got it!" action:HitBtn)}
    {CenterAreaHandles.place_holder set(CenterAreaHandles.info.top_level)}
    if Answer==1 then {CenterAreaCleanup} else {CenterAreaCleanup} end
  end


end
