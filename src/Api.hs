{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}


module Api where

import GHC.Generics
import Data.Aeson
import Network.HTTP.Req
import qualified Data.Text as T

data Tournament = Tournament { tournament_id :: String, matches :: [Match] } deriving (Show, Generic)

newtype Match = Match { match_id :: Int } deriving (Show, Generic)

instance FromJSON Match

instance ToJSON Match where
    toEncoding = genericToEncoding defaultOptions

-- "/api/leagues/4664/matches"
tournamentMatches :: String -> IO Tournament
tournamentMatches tournamentId = runReq defaultHttpConfig $ do
  r <- req GET (https "api.opendota.com" /: "api" /: "leagues" /: T.pack tournamentId /: "matches" ) NoReqBody jsonResponse mempty
  let matches = responseBody r
  return Tournament { tournament_id = tournamentId, matches = matches }

printMatchIds :: String -> IO ()
printMatchIds tournamentId = do
  quriedTournamentMatches <- tournamentMatches tournamentId
  print quriedTournamentMatches