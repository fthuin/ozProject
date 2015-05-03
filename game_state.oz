functor
import
  PlayerMod at 'player.ozf'
export
  UpdatePlayer
  IncrementTurn
  HealPlayerPokemoz
  UpdatePlayerAndEnemyTrainer
define
  fun {UpdatePlayer GameState NewPlayer}
    case GameState
    of   game_state(turn:Turn player:_ trainers:Trainers)
    then game_state(turn:Turn player:NewPlayer trainers:Trainers)
    end
  end

  fun {IncrementTurn GameState}
    case GameState
    of   game_state(turn:Turn    player:Player trainers:Trainers)
    then game_state(turn:Turn+1  player:Player trainers:Trainers)
    end
  end

  fun {HealPlayerPokemoz GameState}
    case GameState
    of   game_state(turn:Turn player:Player trainers:Trainers)
    then game_state(turn:Turn player:{PlayerMod.healPokemoz Player} trainers:Trainers)
    end
  end

  fun {UpdatePlayerAndEnemyTrainer GameState NewPlayer NewTrainer}
    fun {ReplaceTrainer TrainersList}
      case TrainersList
      of nil then nil
      [] H|T then
        if H.name == NewTrainer.name then NewTrainer|{ReplaceTrainer T}
        else H|{ReplaceTrainer T}
        end
      end
    end
  in
    case GameState
    of   game_state(turn:Turn player:_         trainers:Trainers)
    then game_state(turn:Turn player:NewPlayer trainers:{ReplaceTrainer Trainers})
    end
  end


end
