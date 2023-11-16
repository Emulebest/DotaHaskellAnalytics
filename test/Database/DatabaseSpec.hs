module Database.DatabaseSpec where

import Data.Tournament
import Database
import Fixtures
import Test.Hspec
import Database.MongoDB
import Data.Functor
import Control.Monad.Reader

spec :: Spec
spec = do
  describe "Database.Database" $ do
    it "should be able to insert and retrieve a tournament" $ do
      pipe <- getDb
      let t = equalNetworthTournament
      let env = DatabaseProperties pipe "dota_test" "tournaments"
      runReaderT (insertTournament t) env
      t' <- runReaderT getTournaments env <&> head
      close pipe
      t' `shouldBe` Just t
      case t' of
        Just t'' -> tournamentId t'' `shouldBe` "1"
        Nothing -> fail "No tournament found"