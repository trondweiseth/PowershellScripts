curl http://wttr.in/baerum?0F
Function WeatherReport(){
	param([switch]$Full,[switch]$Day,[switch]$Moon)
	if ($Full) {curl http://wttr.in/baerum?F}
	if ($Day) {curl http://wttr.in/baerum?1F}
	if ($Moon) {curl http://wttr.in/Moon?F}
	else {curl http://wttr.in/baerum?0F}
}
