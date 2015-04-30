functor
import
  System
  OS
export
  Debug
  Rand
  ReplaceNthInList
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
end
