functor
import
   Lib           at 'lib.ozf'
   PokemozMod    at 'pokemoz.ozf'
   CharactersMod at 'characters.ozf'
   GameStateMod  at 'game_state.ozf'
export
   GenerateNextInstruction
   ShouldFight
   Init
define
  HospitalPosition
  VictoryPosition

  proc {Init HospitalPos VictoryPos}
    HospitalPosition = HospitalPos
    VictoryPosition  = VictoryPos
  end

  fun {InFrontHospital GameState}
     if GameState.player.position.x == HospitalPosition.x+1 andthen
        GameState.player.position.y == HospitalPosition.y+1 then true
     else false
     end
  end

  fun {InHospital GameState}
    GameState.player.position == HospitalPosition
  end

  fun {MoveToCapture GameState}
     {Lib.debug move_to_capture}
     PlayerX = GameState.player.position.x
     PlayerY = GameState.player.position.y
  in
     if PlayerX > HospitalPosition.x      andthen PlayerY > HospitalPosition.y    then left
     elseif PlayerX == HospitalPosition.x andthen PlayerY > HospitalPosition.y+1  then up
     elseif PlayerX == HospitalPosition.x andthen PlayerY == HospitalPosition.y+1 then down
     end
  end

  fun {MoveToHospital GameState}
     {Lib.debug move_to_hospital}
     PlayerX = GameState.player.position.x
     PlayerY = GameState.player.position.y
  in
     if PlayerY > HospitalPosition.y+2      then up
     elseif PlayerY < HospitalPosition.y+1  then down
     else
        if PlayerX < HospitalPosition.x     then right
        elseif PlayerX > HospitalPosition.x then left
        else up %% Rentre dans l'hopital
        end
     end
  end

  fun {MoveToFinish GameState}
     {Lib.debug move_to_finish}
     PlayerX = GameState.player.position.x
     PlayerY = GameState.player.position.y
  in
     if PlayerY > VictoryPosition.y+2 then
        if {InFrontHospital GameState}     then right
        else up
        end
     elseif PlayerY < VictoryPosition.y+1  then down
     else
        if PlayerX < VictoryPosition.x     then right
        elseif PlayerX > VictoryPosition.x then left
        else up
        end
     end
  end

  fun {MoveToJames GameState}
     {Lib.debug move_to_james}
     PlayerX = GameState.player.position.x
     PlayerY = GameState.player.position.y
  in
     if PlayerY < GameState.trainers.1.position.y     then down
     elseif PlayerY > GameState.trainers.1.position.y then up
     elseif PlayerX < GameState.trainers.1.position.x then right
     else left
     end
  end

  fun {Move GameState}
     if {InHospital GameState}                                                     then down
     elseif {PokemozMod.allPokemozAreDead GameState.player.pokemoz_list}           then {MoveToHospital GameState}
     elseif {Length GameState.player.pokemoz_list} < 3                             then {MoveToCapture GameState}
     elseif {PokemozMod.allPokemozAreDead CharactersMod.james.pokemoz_list}==false then {MoveToJames GameState}
     else {MoveToFinish GameState}
     end
  end

  fun {GenerateNextInstruction GameState} Direction in
     Direction = {Move GameState}
     if {GameStateMod.canPlayerMoveInDirection? GameState Direction} then
	Direction
     else
	if {GameStateMod.canPlayerMoveInDirection? GameState up}
	   andthen {GameState.isPositionFree? GameState pos(GameState.player.position.x GameState.player.position.y-1)} then up
	elseif {GameStateMod.canPlayerMoveInDirection? GameState down}
	   andthen {GameState.isPositionFree? GameState pos(GameState.player.position.x GameState.player.position.y+1)} then down
	elseif {GameStateMod.canPlayerMoveInDirection? GameState left}
	   andthen {GameState.isPositionFree? GameState pos(GameState.player.position.x-1 GameState.player.position.y)} then left
	elseif {GameStateMod.canPlayerMoveInDirection? GameState right}
	   andthen {GameState.isPositionFree? GameState pos(GameState.player.position.x+1 GameState.player.position.y)} then right
	end
     end
  end


  fun {ShouldFight GameState WildPokemon}
    true
  end


end
