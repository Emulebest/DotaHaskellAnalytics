{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

-- This package is required for DTO representation of the match
-- Sadly, Haskell does not support conditional tagged JSON deserialization, so we need to create a separate DTO for the match
module Api.DataTransfer.Match where

import GHC.Generics
import Data.Aeson
import Data.Typeable

newtype IntermediateMatch = IntermediateMatch { match_id :: Int } deriving (Show, Generic, Typeable, Eq)

instance FromJSON IntermediateMatch
instance ToJSON IntermediateMatch where
  toEncoding = genericToEncoding defaultOptions