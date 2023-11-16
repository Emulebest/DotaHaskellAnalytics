{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Data.Tournament where

import GHC.Generics
import Data.Typeable

import Data.Match

type TournamentId = String
type TournamentName = String

data Tournament = Tournament { tournamentId :: TournamentId, matches :: [Match], tournamentName :: TournamentName } deriving (Show, Generic, Typeable, Eq)

getMeanNetWorthDifference :: Tournament -> Float
getMeanNetWorthDifference t = sum (map getNetWorthDifference (matches t)) / fromIntegral (length $ matches t)
