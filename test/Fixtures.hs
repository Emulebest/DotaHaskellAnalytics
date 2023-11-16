module Fixtures where

import Data.Match
import Data.Tournament

equalNetworthTournament :: Tournament
equalNetworthTournament =
  let netWorths = [10, 20, 30]
   in let radiant = map (PlayerStats True) netWorths
       in let dire = map (PlayerStats False) netWorths
           in Tournament "1" [Match 1 (radiant ++ dire)] "test"