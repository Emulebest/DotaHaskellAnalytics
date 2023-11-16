module Chart.Bar where

import Graphics.Rendering.Chart
import Graphics.Rendering.Chart.Backend.Diagrams
import Data.Colour
import Control.Lens
import Data.Default.Class
import Data.Tournament
import Data.List
import Api.Api
import qualified Data.Map as Map

chart :: Bool -> [Tournament] -> Renderable ()
chart borders tournaments = toRenderable layout
 where
  layout =
        layout_title .~ "Dota Statistics" ++ btitle
      $ layout_title_style . font_size .~ 10
      $ layout_x_axis . laxis_generate .~ autoIndexAxis alabels
      $ layout_y_axis . laxis_override .~ axisGridHide
      $ layout_left_axis_visibility . axis_show_ticks .~ False
      $ layout_plots .~ [ plotBars bars2 ]
      $ def :: Layout PlotIndex Double

  sortByTournamentId = sortBy (\t1 t2 -> compare (tournamentId t1) (tournamentId t2))
  tournamentValues = map (singleton . realToFrac . getMeanNetWorthDifference) (sortByTournamentId tournaments)
  bars2 = plot_bars_titles .~ ["Networth Difference"]
      $ plot_bars_values .~ addIndexes tournamentValues
      $ plot_bars_style .~ BarsClustered
      $ plot_bars_spacing .~ BarsFixGap 30 5
      $ plot_bars_item_styles .~ map mkstyle (cycle defaultColorSeq)
      $ def

  alabels = map snd $ Map.assocs tournamentList

  btitle = if borders then "" else " (no borders)"
  bstyle = if borders then Just (solidLine 1.0 $ opaque black) else Nothing
  mkstyle c = (solidFillStyle c, bstyle)


displayChart :: Bool -> [Tournament] -> IO ()
displayChart borders tournaments = do
  let chart' = chart borders tournaments
  renderableToFile def "chart.svg" chart'
  return ()