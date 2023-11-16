{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

-- This package is required for DTO representation of the match stats
-- Sadly, Haskell does not support conditional tagged JSON deserialization, so we need to create a separate DTO for the stats
module Api.DataTransfer.Stats where

import GHC.Generics
import Data.Aeson
import Data.Typeable

data IntermediateMatchStats = IntermediateMatchStats { match_id :: Int, players :: [IntermediatePlayerStats] } deriving (Show, Generic, Typeable, Eq)

data IntermediatePlayerStats = IntermediatePlayerStats { isRadiant :: Bool, net_worth :: Int } deriving (Show, Generic, Typeable, Eq)

instance FromJSON IntermediateMatchStats
instance ToJSON IntermediateMatchStats where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON IntermediatePlayerStats
instance ToJSON IntermediatePlayerStats where
  toEncoding = genericToEncoding defaultOptions