{-# LANGUAGE OverloadedStrings #-}


module Api.Api where

import Network.HTTP.Req
import qualified Data.Text as T
import qualified Data.Map as Map
import Control.Concurrent.Async
import Control.RateLimit
import Data.Time.Units
import Api.DataTransfer.Match as IM
import Api.DataTransfer.Stats as S
import Data.Tournament
import Data.Match as M
import Control.Monad.IO.Class

newtype (TimeUnit t) => QueryOpts t = QueryOpts { rateLimit :: t }

queryOptsMillis :: Int -> QueryOpts Millisecond
queryOptsMillis millisDelayPerInvocation = QueryOpts $ fromIntegral millisDelayPerInvocation

-- | This variable controls the list of tournaments that will be queried. First value is the tournament ID, second value is the tournament name.
tournamentList :: Map.Map String String
tournamentList = Map.fromList [("5401", "The International 2017"), ("4664", "The International 2016")]

queryTournament :: TimeUnit t => QueryOpts t -> String -> String -> IO Tournament
queryTournament queryOpts tournamentId tournamentName = do
    matches <- getTournamentMatches tournamentId
    -- | Rate limit the getMatchData function to specified queryOpts rate limit. OpenDota has a rate limit of 60 requests per minute for free accounts.
    rateLimitedFunction <- rateLimitInvocation (rateLimit queryOpts) getMatchData
    matchData <- mapConcurrently rateLimitedFunction matches
    let transformedMatch = map intermediateMatchToMatch matchData
    return $ Tournament tournamentId transformedMatch tournamentName

intermediateMatchToMatch :: IntermediateMatchStats -> Match
intermediateMatchToMatch match = Match { matchId = S.match_id match, playerStats = map intermediatePlayerStatsToPlayerStats (S.players match) }

intermediatePlayerStatsToPlayerStats :: IntermediatePlayerStats -> PlayerStats
intermediatePlayerStatsToPlayerStats stats = PlayerStats { M.isRadiant = S.isRadiant stats, netWorth = S.net_worth stats }

getTournamentMatches :: String -> IO [IntermediateMatch]
getTournamentMatches id = runReq defaultHttpConfig $ do
  r <- req GET (https "api.opendota.com" /: "api" /: "leagues" /: T.pack id /: "matches" ) NoReqBody jsonResponse mempty
  return $ responseBody r

getMatchData :: IntermediateMatch -> IO IntermediateMatchStats
getMatchData match = runReq defaultHttpConfig $ do
  liftIO $ print $ IM.match_id match
  r <- req GET (https "api.opendota.com" /: "api" /: "matches" /: T.pack (show $ IM.match_id match) ) NoReqBody jsonResponse mempty
  return $ responseBody r

printMatchIds :: TimeUnit t => QueryOpts t -> String -> String -> IO ()
printMatchIds queryOpts id name = do
  queriedTournamentMatches <- queryTournament queryOpts id name
  print queriedTournamentMatches