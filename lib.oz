functor
import
   Application
   Property
   System
   OS
export
   Debug
   Rand
   ReplaceNthInList
   PositionInDirection
   GetArgs
define
  proc {Debug Msg}
     {System.show Msg}
  end

  fun {Rand I}
     ({OS.rand $} mod I) + 1
  end

  fun {ReplaceNthInList List Nth NewElement}
    case List
    of nil then nil
    [] H|T then
      if Nth>1 then H|{ReplaceNthInList T Nth-1 NewElement}
      else NewElement|T end
    end
  end

  fun {PositionInDirection Pos Direction}
    case Direction
    of up    then pos(x:Pos.x   y:Pos.y-1)
    [] right then pos(x:Pos.x+1 y:Pos.y)
    [] down  then pos(x:Pos.x   y:Pos.y+1)
    [] left  then pos(x:Pos.x-1 y:Pos.y)
    end
  end


   proc {GetArgs Map Probability Speed AutoFight DELAY}
      %% Default values
      MAP         = 'Map.txt'
      PROBABILITY = 10
      SPEED       = 9
      AUTOFIGHT   = false
      Say         = System.showInfo
      Args = {Application.getArgs record(
                 map(single char:&m type:atom default:MAP)
         probability(single char:&p type:int  default:PROBABILITY)
               speed(single char:&s type:int  default:SPEED)
           autofight(single char:&a type:bool default:AUTOFIGHT)
                help(single char:[&? &h] default:false))}
   in
      %% Help message
      if Args.help then
        {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
        {Say "Options:"}
        {Say "  -m, --map FILE\tFile containing the map (default "#MAP#")"}
        {Say "  -p, --probability INT\tProbability to find a wild pokemoz in tall grass"}
        {Say "  -s, --speed INT\tThe speed of your pokemoz trainer in a range from 0 to 10"}
        {Say "  -a, --autofight BOOL\tChoice weither the game is automatic or not"}
        {Say "  -h, -?, --help\tThis help"}
        {Application.exit 0}
      end

      Map         = Args.map
      Probability = Args.probability
      Speed       = Args.speed
      AutoFight   = Args.autofight
      DELAY       = 200
      %% TODO : Vérifier la qualité des arguments
   end

end
