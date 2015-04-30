functor
export
  UpdatePlayer
define
  fun {UpdatePlayer GameState NewPlayer}
    case GameState
    of game_state(turn:Turn player:_ trainers:Trainers)
    then game_state(turn:Turn player:NewPlayer trainers:Trainers)
    end
  end
end
