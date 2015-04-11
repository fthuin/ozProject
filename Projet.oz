declare

[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}

Canvas
WidthBox=40 % Largeur de case
HeightBox=40 % Hauteur de case
NW % Nombre de cases par ligne
NH % Nombre de cases par colonne
W % Largeur totale
H % Hauteur totale
Map=map(r(1 1 1 0 0 0 0)
	r(1 1 1 0 0 1 1)
	r(1 1 1 0 0 1 1)
	r(0 0 0 0 0 1 1)
	r(0 0 0 1 1 1 1)
	r(0 0 0 1 1 0 0)
	r(0 0 0 0 0 0 0))

Desc
Window


proc {InitLayout Map}
   proc{DrawHline X1 Y1 X2 Y2}
      if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
	 skip
      else
	 {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	 {DrawHline X1+HeightBox Y1 X2+HeightBox Y2}
      end
   end
   proc{DrawVline X1 Y1 X2 Y2}
      if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
	 skip
      else
	 {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	 {DrawVline X1 Y1+WidthBox X2 Y2+WidthBox}
      end
   end
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
	    end
	 end
      end
   end
   proc{DrawBox Color X Y}
       {Canvas create(rect X*WidthBox Y*HeightBox X*WidthBox+WidthBox Y*HeightBox+HeightBox fill:Color outline:black)}
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
   
   {DrawHline 0 0 0 H}
   {DrawVline 0 0 W 0}
   {DrawElements Map}
end

{InitLayout Map}

PLAYER_MAXSTEP=1 % Nombre maximum de case par tour
Command
CommandPort = {NewPort Command}

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
   if T1==grass andthen T2==grass then 2
   elseif T1==grass andthen T2==fire then 1
   elseif T1==grass andthen T2==water then 3
   elseif T1==fire andthen T2==grass then 3
   elseif T1==fire andthen T2==fire then 2
   elseif T1==fire andthen T2==water then 1
   elseif T1==water andthen T2==grass then 1
   elseif T1==water andthen T2==fire then 3
   elseif T1==water andthen T2==water then 2
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