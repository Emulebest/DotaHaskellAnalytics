{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Data.Match where

import GHC.Generics
import Data.Aeson
import Data.Typeable
import Database.MongoDB

data Match = Match { matchId :: Int, playerStats :: [PlayerStats] } deriving (Show, Generic, Typeable, Eq)

getNetWorthDifference :: Match -> Float
getNetWorthDifference m = 
    let maxNetworthRadiant = maximum $ map netWorth $ filter isRadiant $ playerStats m
        maxNetworthDire = maximum $ map netWorth $ filter (not . isRadiant) $ playerStats m
        minNetworthRadiant = minimum $ map netWorth $ filter isRadiant $ playerStats m
        minNetworthDire = minimum $ map netWorth $ filter (not . isRadiant) $ playerStats m
    in (/ 2) . fromIntegral $ ((maxNetworthRadiant - minNetworthRadiant) + (maxNetworthDire - minNetworthDire))

instance FromJSON Match
instance ToJSON Match where
  toEncoding = genericToEncoding defaultOptions

instance Val Match where
  val m = val [ "matchId" =: matchId m, "playerStats" =: playerStats m ]
  cast' (Doc doc) = Match <$> (cast' =<< look "matchId" doc) <*> (cast' =<< look "playerStats" doc)

data PlayerStats = PlayerStats { isRadiant :: Bool, netWorth :: Int } deriving (Show, Generic, Typeable, Eq)

instance FromJSON PlayerStats
instance ToJSON PlayerStats where
  toEncoding = genericToEncoding defaultOptions

instance Val PlayerStats where
  val p = val [ "isRadiant" =: isRadiant p, "netWorth" =: netWorth p ]
  cast' (Doc doc) = PlayerStats <$> (cast' =<< look "isRadiant" doc) <*> (cast' =<< look "netWorth" doc)