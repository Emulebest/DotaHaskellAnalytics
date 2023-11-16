module Data.TournamentSpec where

import Data.Match
import Data.Tournament
import Fixtures
import Test.Hspec

spec :: Spec
spec = do
  describe "Data.Tournament" $ do
    it "should be able to calculate the net worth difference and mean net worth difference" $ do
      let t = equalNetworthTournament
      getNetWorthDifference (head $ matches t) `shouldBe` 20
      getMeanNetWorthDifference t `shouldBe` 20


main :: IO ()
main = hspec spec