declare

[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}



WidthBox  = 40     % Largeur de case
HeightBox = 40     % Hauteur de case
PLAYER_MAXSTEP = 8 % Nombre maximum de case par tour

NW % Nombre de cases par ligne
NH % Nombre de cases par colonne
W  % Largeur totale
H  % Hauteur totale

Map=map(r(1 1 1 0 0 0 0)
	r(1 1 1 0 0 1 1)
	r(1 1 1 0 0 1 1)
	r(0 0 0 0 0 1 1)
	r(0 0 0 1 1 1 1)
	r(0 0 0 1 1 0 0)
	r(0 0 0 0 0 0 0))

Canvas
Command
CommandPort = {NewPort Command}
Desc
Window

proc {InitLayout Map}
   proc{DrawUnits L}
      case L of r(Color X Y)|T then
	 {DrawBox Color X Y}
	 {DrawUnits T}
      else
	 skip
      end
   end
   proc{DrawElements Map} L L2 in
      L = {Length {Arity Map}}
      for I in 1..L do
	 L2={Length {Arity Map.I}}
	 for I2 in 1..L2 do
	    if Map.I.I2==1 then
	       {DrawBox green I2-1 I-1}
	    else
	       {DrawBox white I2-1 I-1}
	    end
	 end
      end
   end
   proc{DrawBox Color X Y}
       {Canvas create(rect X*WidthBox Y*HeightBox X*WidthBox+WidthBox Y*HeightBox+HeightBox fill:Color outline:black)}
   end
   proc{Game OldX OldY Command}
      NewX NewY
      NextCommand
      fun{UserCommand Command Count X Y LX LY}
	 IX IY in
	 case Command of c(DX DY)|T then
	    if Count == PLAYER_MAXSTEP then
	       {UserCommand T Count X Y  LX LY}
	    else
	       IX = X+DX
	       IY = Y+DY
	       {Browse X}
	       {Browse Y}
	       {DrawBox white X Y}
	       {DrawBox blue IX IY}
	       {UserCommand T Count+1 IX IY LX LY}
	    end
	 [] finish|T then
	    LX = X
	    LY = Y
	    T
	 end
      end
   in
      NextCommand = {UserCommand Command 0 OldX OldY NewX NewY}
      {Game NewX NewY NextCommand}
   end
in
   NH = {Length {Arity Map}}
   if NH > 0 then
      NW = {Length {Arity Map.1}}
   end
   W=WidthBox*NW % Largeur totale de la fenetre
   H=HeightBox*NH % Hauteur totale de la fenetre
   Desc=td(canvas(bg:white
	       width:W
	       height:H
	       handle:Canvas))
   Window={QTk.build Desc}
   {Browse ok2}
    {DrawElements Map}
   {DrawBox blue NW-1 NH-1}
   thread {Game NW-1 NH-1 Command} end
   {Browse ok1}
end

{InitLayout Map}

{Window bind(event:"<Up>" action:proc{$} {Send CommandPort c(0 ~1)} end)}
{Window bind(event:"<Left>" action:proc{$} {Send CommandPort c(~1 0)} end)}
{Window bind(event:"<Down>" action:proc{$} {Send CommandPort c(0 1)}  end)}
{Window bind(event:"<Right>" action:proc{$} {Send CommandPort c(1 0)} end)}
{Window bind(event:"<space>" action:proc{$} {Send CommandPort finish} end)}
{Browse ok3}
SpeedDelay = 200
AutoFight = true
%AutoFight=false
%AutoFight=choice
Bulbasoz=pokemoz(name:Bulbasoz type:grass owner:wild health:20 maxhealth:20 level:5 experience:0)
Oztirtle=pokemoz(name:Oztirtle type:water owner:wild)
Charmandoz=pokemoz(name:Charmandoz type:fire owner:wild)
Trainer=trainer(name:florian [Bulbasoz] speed:2)
%square(type:road)
%square(type:grass probability:0.1)

{Window show}

fun {CalculateSpeed Speed}
   (10-Speed)*SpeedDelay
end

% {Browse {CalculateSpeed 2}}

% T1 is the attacker
% T2 is the defencer
fun {HPDamage T1 T2}
   case T1#T2 of grass#grass then 2
   [] grass#fire then 1
   [] grass#water then 3
   [] fire#grass then 3
   [] fire#fire then 2
   [] fire#water then 1
   [] water#grass then 1
   [] water#fire then 3
   [] water#water then 2
   end
end 
%{Browse {HPDamage fire fire}}

% LA is the attacker level
% LD is the defenser level
fun {AttackSuccess LA LD}
   (6+LA-LD)*9
end

% P1 is the winner
% P2 is the loser
fun {Win P1 P2}
   case P1 of pokemoz(name:N1 type:T1 owner:O1 health:H1 maxhealth:M1 level:L1 experience:E1) then
      case P2 of pokemoz(name:_ type:_ owner:_ health:_ maxhealth:_ level:L2 experience:_) then NewLevel NewHP in
	 if {CheckEvolution L1 E1+L2 NewLevel NewHP} then
	    pokemoz(name:N1 type:T1 owner:O1 health:NewHP maxhealth:NewHP level:NewLevel experience:0)
	 else
	    pokemoz(name:N1 type:T1 owner:O1 health:H1 maxhealth:M1 level:L1 experience:E1+L2)
	 end
      end
   end
end

fun {CheckEvolution Level Exp NewLevel HP}
   if Level==5 andthen Exp>=5 then
      NewLevel=6
      HP=22
      true
   elseif Level==6 andthen Exp>=12 then
      NewLevel=7
      HP=24
      true
   elseif Level==7 andthen Exp>=20 then
      NewLevel=8
      HP=26
      true
   elseif Level==8 andthen Exp>=30 then
      NewLevel=9
      HP=28
      true
   elseif Level==9 andthen Exp>=50 then
      NewLevel=10
      HP=30
   else
      false
   end
end