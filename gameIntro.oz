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
NameText         = text(glue:n width:15 height:2 handle:NameTextHandle return:PlayerName borderwidth:0 highlightthickness:0)

ChoiceLabel = lr(label(init:"ChosenPokemoz :" bg:white) label(init:"none" handle:ChoiceLabelHandle bg:white return:ChosenPokemoz))

StartGameBtn  = button(text:"Start game !" padx:150 pady:20 glue:new bg:white action:toplevel#close)
SachaCanvas   = canvas(handle:SachaCanvasHandle   width:400 height:350 bg:white borderwidth:0 highlightthickness:0)
PokemozCanvas = canvas(handle:PokemozCanvasHandle width:300 height:600 bg:white borderwidth:0 highlightthickness:0)

	
MainLayout = td(title:"Pokemoz"
		bg:white
		NewGameMsg
		lr(
		   bg:white
		   glue:new
		   td(bg:white glue:new
		      ChoosePokemozMsg
		      PokemozCanvas
		     )
		   td(bg:white glue:new
		      ChooseNameMsg
		      NameText
		      SachaCanvas
		      ChoiceLabel
		      StartGameBtn
		     )
		 )
	       )

Window = {QTk.build MainLayout}

{SachaCanvasHandle   create(image 110 50   anchor:nw image:{GetImage sacha_large})}
{PokemozCanvasHandle bind(event:"<1>" action:proc{$ X Y}
						if Y < 180 then
						   {ChoiceLabelHandle set("Bulbasoz")}
						elseif Y < 360 then
						   {ChoiceLabelHandle set("Charmandoz")}
						else
						   {ChoiceLabelHandle set("Oztirtle")}
						end
					     end
			  args:[int(x) int(y)])} 
{PokemozCanvasHandle create(image 75  0   anchor:nw image:{GetImage pokemoz_bulbasaur})}
{PokemozCanvasHandle create(text  150  160 anchor:center text:"Bulbasoz - Grass" justify:center)}
{PokemozCanvasHandle create(image 75  180 anchor:nw image:{GetImage pokemoz_charmander})}
{PokemozCanvasHandle create(text  150  340 anchor:center text:"Charmandoz - Fire" justify:center)}
{PokemozCanvasHandle create(image 75  360 anchor:nw image:{GetImage pokemoz_squirtle})}
{PokemozCanvasHandle create(text  150  520 anchor:center text:"Ozirtle - Water" justify:center)}

{Window show(wait:true modal:true)}

{Browse {String.toAtom ChosenPokemoz}}
{Browse {String.toAtom PlayerName}}
