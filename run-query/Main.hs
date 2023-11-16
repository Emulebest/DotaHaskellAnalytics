{-# LANGUAGE OverloadedStrings #-}

module Main where

import Api.Api
import Database
import Database.MongoDB
import Data.Map (foldrWithKey)
import Data.Tournament
import Control.Monad.Reader

main :: IO ()
main = do
    putStrLn "Running data query"
    pipe <- getDb
    let delay = queryOptsMillis 2000
    tournaments <- foldrWithKey (\k v _acc -> do
        t <- queryTournament delay k v
        acc <- _acc
        return (acc ++ [t])) (return []) tournamentList
    runReaderT (insertTournaments tournaments) (DatabaseProperties pipe "dota" "tournaments")
    print "Inserted successfully"
    close pipe
    return ()

