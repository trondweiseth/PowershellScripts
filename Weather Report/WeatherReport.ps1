Function WeatherReport(){
	param([string]$Location,[switch]$Full,[switch]$Day,[switch]$Moon)
	if (!$Location) {$Location = "baerum"}
	if ($Full) {(Invoke-WebRequest "https://wttr.in/${Location}?F" -UserAgent "curl" ).Content}
	if ($Day) {(Invoke-WebRequest "https://wttr.in/${Location}?1F" -UserAgent "curl" ).Content}
	if ($Moon) {(Invoke-WebRequest "https://wttr.in/Moon?F" -UserAgent "curl" ).Content}
	if (!$Full -and !$Day -and !$Moon) {(Invoke-WebRequest "https://wttr.in/${Location}?0F" -UserAgent "curl" ).Content}
}
