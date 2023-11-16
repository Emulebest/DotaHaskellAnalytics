{-# LANGUAGE OverloadedStrings #-}

module Main where

import Database
import Database.MongoDB
import Data.Tournament
import Chart.Bar
import Control.Monad.Reader

main :: IO ()
main = do
    putStrLn "Running data analysis"
    pipe <- getDb
    tList <- runReaderT getTournaments (DatabaseProperties pipe "dota" "tournaments")
    let tournaments = sequence tList
    case tournaments of
      Just t -> displayChart True t
      Nothing -> print "Nothing"
    close pipe
    return ()