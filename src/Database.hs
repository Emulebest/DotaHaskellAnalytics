{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}

module Database where

import Database.MongoDB
import Api ( Match, match_id, Tournament, tournament_id, matches )
import Control.Monad.IO.Class (liftIO)

defaultConnection :: String
defaultConnection = "localhost:27017"

getDb :: IO Pipe
getDb = connect $ readHostPort defaultConnection

-- | Insert a document into the database
insertMatch :: Pipe -> Match -> IO ()
insertMatch pipe tournamentId = do
  e <- access pipe master "dota" $ modify "tournaments" ["tournament_d" := val tournamentId] 
  liftIO $ print e

insertTournament :: Pipe -> Tournament -> IO ()
insertTournament pipe tournament = do
  e <- access pipe master "dota" $ insert "tournaments" ["tournament_id" := val (tournament_id tournament), "matches" := val (matches tournament)]
  return ()

getTournaments :: IO [Document]
getTournaments = do
  pipe <- getDb
  access pipe master "dota" $ find (select [] "tournaments") >>= rest

printDocs :: String -> [Document] -> IO ()
printDocs title docs = liftIO $ putStrLn title >> mapM_ (print . exclude ["_id"]) docs