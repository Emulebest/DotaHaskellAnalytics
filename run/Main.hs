{-# LANGUAGE OverloadedStrings #-}

module Main where

import Api.Api
import Database
import Database.MongoDB
import Data.Map (foldrWithKey)
import Data.Tournament
import Control.Monad.Reader
import Chart.Bar

main :: IO ()
main = do
    putStrLn "Running data query"
    pipe <- getDb
    let env = DatabaseProperties pipe "dota" "tournaments"
    let delay = queryOptsMillis 2000
    tournaments <- foldrWithKey (\k v _acc -> do
        t <- queryTournament delay k v
        acc <- _acc
        return (acc ++ [t])) (return []) tournamentList
    runReaderT (insertTournaments tournaments) env
    print "Inserted successfully"
    putStrLn "Running data analysis"
    tList <- runReaderT getTournaments env
    let tournaments = sequence tList
    case tournaments of
      Just t -> displayChart True t
      Nothing -> print "Nothing"
    close pipe
    return ()