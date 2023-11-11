{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Api (matches, Match (Match))
import Database
import Database.MongoDB

main :: IO ()
main = do
  pipe <- getDb
  queriedMatches <- matches "4664"
  insertMatches pipe queriedMatches 
  m <- allMatches 
  printDocs "All matches" m
  close pipe
  return ()
  
