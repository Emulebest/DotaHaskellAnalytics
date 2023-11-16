# Dota Haskell Analytics

## Description

This project is a Haskell implementation of the logic to compare the networth between the richest player (a.k.a first position or carry) and the poorest player (a.k.a position five or hard support) across the series of The International tournaments in Dota 2. 
Final result is the Bar Chart representation in a generated file 'chart.svg'.

## Data

Data is taken from [OpenDota](https://www.opendota.com/) API.
If you are willing to modify the tournaments you would like to query you can do so in src/Api.hs file. `tournamentList = Map.fromList [("5401", "The International 2017"), ("4664", "The International 2016")]`, where the first is the league id and second is the name of the tournament.

If you would like to change the name of the generated chart file, please refer to `renderableToFile def "chart.svg" chart'` in src/Chart/Bar.hs file. You can modify the chart rendering parameters in the aforementioned file as well.

## How to run

There are two ways to run the application: using Docker-compose or using Stack.


### Docker-compose

Pre-requisites: Docker & Docker-compose

1) Install Docker and Docker-compose
2) Make sure that src/Database.hs configuration is set (this could be either done via environment variable `MONGO_CONNECTION` or by changing the default value in src/Database.hs)
3) Run `docker-compose up` in the root directory of the project

### Stack

Pre-requisites: Haskell & Stack & Mongo

1) Install Haskell & Stack
2) Install and start Mongo
3) Make sure that src/Database.hs configuration is set (this could be either done via environment variable `MONGO_CONNECTION` or by changing the default value in src/Database.hs)
4) Run `stack build` in the root directory of the project
5) Run `stack exec Run-exe` in the root directory of the project to run the whole application
6) Run `stack exec Query-exe` in the root directory of the project to run only the data query part
7) Run `stack exec Data-exe` in the root directory of the project to run only the data analysis & chart generation part

## Tests

To run the tests, please run `stack test` in the root directory of the project.

## Comments and future improvements

Haskell is not my primary language, so I would appreciate any feedback on the code. Please feel free to open issues and PRs.

There are some things that I would like to improve in the future:
- [ ] Fix the split between DTO and domain models, can't express it nicely in Aeson because of lack of conditional parsing of separate JSON fields
- [ ] Make the API layer more abstracted (however, I am sure that OpenDota APIs won't change)
- [ ] Add API layer tests with mocked responses
- [ ] Improve the API calling rate limiting, it might be too restrictive right now
- [ ] Improve automatic resource closing, e.g. closing the Mongo connection. I can write my own Monad for that but not sure this is the optimal solution, need to investigate more
- [ ] Improve compile times for Haskell in Docker (not sure if it is possible, but it takes a lot of time to compile the project in Docker)
- [ ] Since there is a delay between requests, it would be possible to write records to database between API invocations
- [ ] Improve the readability of the chart

## License

Distributed under the MIT license. See LICENSE for more information.