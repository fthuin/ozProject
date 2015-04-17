declare
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}

L % handler of the label
R % will be bound to the content of the label at the closure
TextHandle % The handler of the text field
Continue % the method that calls the game

Desc=td(title:"Choose your trainer name"
	label(init:"Insert your name here :"
	   handle:L
	   return:R)
	lr(text(glue:nw handle:TextHandle height:3 width:20)
	   button(text:"Continue" glue:e action:Continue highlightcolor:red)
	  )
       )

{{QTk.build Desc} show}

% if sets a default name
%{TextHandle set("Player1")}

Continue=proc{$} Pseudo in
	    Pseudo={TextHandle get($)}
	    {Browse {String.toAtom Pseudo}}
	    % TODO : Ici linker l'action à effectuer quand on clique sur continue
	 end
