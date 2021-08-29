Function WeatherReport(){
	param([string]$Location,[switch]$Full,[switch]$Day,[switch]$Moon)
	if (!$Location) {$Location = "baerum"}
	if ($Full) {curl "https://wttr.in/${Location}?F"}
	if ($Day) {curl "https://wttr.in/${Location}?1F"}
	if ($Moon) {curl "https://wttr.in/Moon?F"}
	if (!$Full -and !$Day -and !$Moon) {curl "https://wttr.in/${Location}?0F"}
}
