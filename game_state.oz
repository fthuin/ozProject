functor
import
  PlayerM at 'player.ozf'
export
  UpdatePlayer
  MovePlayer
  IncrementTurn
  HealPokemoz
define
  fun {UpdatePlayer GameState NewPlayer}
    case GameState
    of   game_state(turn:Turn player:_ trainers:Trainers)
    then game_state(turn:Turn player:NewPlayer trainers:Trainers)
    end
  end

  fun {MovePlayer GameState Direction}
    case GameState
    of   game_state(turn:Turn player:Player trainers:Trainers)
    then game_state(turn:Turn player:{PlayerM.updatePosition Player Direction} trainers:Trainers)
    end
  end

  fun {IncrementTurn GameState}
    case GameState
    of   game_state(turn:Turn    player:Player trainers:Trainers)
    then game_state(turn:Turn+1  player:Player trainers:Trainers)
    end
  end

  fun {HealPokemoz GameState}
    case GameState
    of   game_state(turn:Turn player:Player trainers:Trainers)
    then game_state(turn:Turn player:{PlayerM.healPokemoz Player} trainers:Trainers)
    end
  end

end
