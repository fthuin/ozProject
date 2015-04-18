functor
import
  System
  OS
export
  Debug
  Rand
define
  proc {Debug Msg}
     {System.show Msg}
  end

  fun {Rand I}
     ({OS.rand $} mod I) + 1
  end
end
