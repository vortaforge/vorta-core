# Uses guikit:predicate/weather_*
data modify storage guikit:work wx set from storage guikit:cond current.weather
execute unless data storage guikit:work wx run data modify storage guikit:work wx set value "clear"
function guikit:cond/t_weather_do with storage guikit:work
