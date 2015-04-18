declare
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
%BASE_PATH = "/Users/Greg/Desktop/ozProject/"
BASE_PATH = "/home/florian/Documents/Project_2015/"
ImageLibrary = {QTk.loadImageLibrary BASE_PATH#"ImageLibrary.ozf"}

fun {GetImage Name}
   {ImageLibrary get(name:Name image:$)}
end

fun {Title Msg}
   TitleFont = {QTk.newFont font(family:helvetica size:30 weight:bold)}
in
   message(aspect:600 init:Msg glue:new padx:20 pady:20 bg:white font:TitleFont)
end

fun {Subtitle Msg}
   SubTitleFont = {QTk.newFont font(family:helvetica size:15 weight:bold)}
in
   message(aspect:1000 init:Msg padx:20 pady:20 glue:ew bg:white font:SubTitleFont)
end

PlayerName
DropdownPokemoz
ChosenPokemoz
NameTextHandle
SachaCanvasHandle
PokemozCanvasHandle
ChoiceLabelHandle

NewGameMsg       = {Title "New game"}
ChooseNameMsg    = {Subtitle "Choose your name"}
ChoosePokemozMsg = {Subtitle "Choose your starting Pokemoz"}
NameText         = text(init:"Enter your name..." glue:ew width:15 height:2 handle:NameTextHandle bg:white return:PlayerName borderwidth:0 highlightthickness:0)
%DropdownPokemoz  = dropdownlistbox(init:["Bulbasoz - Grass" "Charmandoz - Fire" "Oztirtle - Water"]
%				   return:ChosenPokemoz
%				   glue:new
%				  )
ChoiceLabel = lr(label(init:"ChosenPokemoz : " bg:white) label(init:"none" handle:ChoiceLabelHandle bg:white return:ChosenPokemoz))

StartGameBtn  = button(text:"Start game!" glue:new bg:white action:toplevel#close)
SachaCanvas   = canvas(handle:SachaCanvasHandle   width:400 height:300 bg:white borderwidth:0 highlightthickness:0)
PokemozCanvas = canvas(handle:PokemozCanvasHandle width:400 height:800 bg:white borderwidth:0 highlightthickness:0)

	
MainLayout = td(title:"Pokemoz"
		bg:white
		NewGameMsg
		lr(
		   bg:white
		   glue:new
		   td(bg:white glue:new
		      ChoosePokemozMsg
		     % DropdownPokemoz
		      PokemozCanvas
		     )
		   td(bg:white glue:new
		      ChooseNameMsg
		      NameText
		      SachaCanvas
		      ChoiceLabel
		     )
		 )
		StartGameBtn)

Window = {QTk.build MainLayout}

{SachaCanvasHandle   create(image 110 0   anchor:nw image:{GetImage sacha_large})}
{PokemozCanvasHandle bind(event:"<1>" action:proc{$ X Y}
						if Y < 270 then
						   {ChoiceLabelHandle set("Bulbasoz")}
						elseif Y < 540 then
						   {ChoiceLabelHandle set("Charmandoz")}
						else
						   {ChoiceLabelHandle set("Oztirtle")}
						end
					     end
			  args:[int(x) int(y)])} 
{PokemozCanvasHandle create(image 75  0   anchor:nw image:{GetImage pokemoz_bulbasaur})}
{PokemozCanvasHandle create(text  75  250 anchor:nw text:"Bulbasoz - Grass")}
{PokemozCanvasHandle create(image 75  270 anchor:nw image:{GetImage pokemoz_charmander})}
{PokemozCanvasHandle create(text  75  520 anchor:nw text:"Charmandoz - Fire" justify:center)}
{PokemozCanvasHandle create(image 75  540 anchor:nw image:{GetImage pokemoz_squirtle})}
{PokemozCanvasHandle create(text  75  790 anchor:nw text:"Ozirtle - Water")}

{Window show(wait:true modal:true)}

{Browse {String.toAtom ChosenPokemoz}}
{Browse {String.toAtom PlayerName}}
