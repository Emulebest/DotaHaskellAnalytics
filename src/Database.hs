{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}

module Database where

import Database.MongoDB as Mongo
import Control.Monad.IO.Class (liftIO)
import Data.Tournament
import Data.Match
import Control.Monad.Reader
import qualified Data.Text as T
import System.Environment (lookupEnv)


-- | Controls the host port connection string for Mongo
defaultConnection :: IO String
defaultConnection = do
  connectionString <- lookupEnv "MONGO_CONNECTION"
  case connectionString of
    Just conn -> return conn
    Nothing -> return "localhost:27017"

class DBProps a where
  pipe :: a -> Pipe
  dbName :: a -> String
  collName :: a -> String

instance DBProps DatabaseProperties where
  pipe = propsPipe
  dbName = propsDbName
  collName = propsCollName

data DatabaseProperties = DatabaseProperties { propsPipe :: Pipe, propsDbName :: String, propsCollName :: String }

getDb :: IO Pipe
getDb = do
  connectionString <- defaultConnection
  connect $ readHostPort connectionString

insertMatch :: (DBProps t, MonadReader t m, MonadIO m) => Tournament -> Match -> m ()
insertMatch t match = do
  env <- ask
  let (pipe', dbName', collName') = (pipe env, dbName env, collName env)
  e <- access pipe' master (T.pack dbName') $ modify (Select ["tournamentId" := val (tournamentId t)] (T.pack collName')) ["$push" := val ["matches" := val match]]
  return ()

insertTournament :: (DBProps t, MonadReader t m, MonadIO m) => Tournament -> m ()
insertTournament tournament = do
  env <- ask
  let (pipe', dbName', collName') = (pipe env, dbName env, collName env)
  e <- access pipe' master (T.pack dbName') $ insert (T.pack collName') ["tournamentId" := val (tournamentId tournament), "matches" := val (matches tournament), "tournamentName" := val (tournamentName tournament)]
  return ()

insertTournaments :: (DBProps t, MonadReader t m, MonadIO m) => [Tournament] -> m ()
insertTournaments tournaments = do
  env <- ask
  let (pipe', dbName', collName') = (pipe env, dbName env, collName env)
  e <- access pipe' master (T.pack dbName') $ insertMany (T.pack collName') (map (\t -> ["tournamentId" := val (tournamentId t), "matches" := val (matches t), "tournamentName" := val (tournamentName t)]) tournaments)
  return ()

getTournaments :: (DBProps t, MonadReader t m, MonadIO m, MonadFail f) => m [f Tournament]
getTournaments = do
  env <- ask
  let (pipe', dbName', collName') = (pipe env, dbName env, collName env)
  documents <- access pipe' master (T.pack dbName') $ find (select [] (T.pack collName')) >>= rest
  return $ fmap documentToTournament documents

printDocs :: String -> [Document] -> IO ()
printDocs title docs = liftIO $ putStrLn title >> mapM_ (print . exclude ["_id"]) docs

documentToTournament :: MonadFail m => Document -> m Tournament
documentToTournament doc = do
  tId <- Mongo.lookup "tournamentId" doc
  m <- Mongo.lookup "matches" doc
  tName <- Mongo.lookup "tournamentName" doc
  return $ Tournament tId m tName