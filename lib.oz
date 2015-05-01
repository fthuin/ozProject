functor
import
  System
  OS
export
  Debug
  Rand
  ReplaceNthInList
  PositionInDirection
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

end
