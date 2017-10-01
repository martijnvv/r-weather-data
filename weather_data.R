library('stats')
library('httr')
library('dplyr')
library('grid')
library('gridExtra')

api_key <- function(force = FALSE) {
  
  env <- Sys.getenv('weather_api_key')
  if (!identical(env, "") && !force) return(env)
  
  if (!interactive()) {
    stop("Please set env var weather_api_key to your ForecastIO API key",
         call. = FALSE)
  }
  
  message("Couldn't find env var weather_api_key")
  message("Please enter your API key and press enter:")
  pat <- readline(": ")
  
  if (identical(pat, "")) {
    stop("PassiveTotal API key entry failed", call. = FALSE)
  }
  
  message("weather_api_key env var to PAT")
  Sys.setenv(weather_api_key = pat)
  
  pat
  
}

api_key() -> api
latitude = "52.155"
longitude = "5.3875"
Sys.Date() -1 -> yesterday
as.numeric(as.POSIXct(yesterday, format="%Y-%m-%d")) -> time
language = "en"
units = "si"

url <- sprintf("https://api.darksky.net/forecast/%s/%s,%s,%s?exclude=currently,flags",
               api, latitude, longitude, time)

params <- list(units=units, language=language)

resp <- httr::GET(url=url, query=params)
httr::stop_for_status(resp)

tmp <- httr::content(resp, as="parsed")

dat_hourly <- dplyr::bind_rows(lapply(tmp$hourly$data, as_data_frame))
as.POSIXct(dat_hourly$time, origin="1970-01-01")  -> dat_hourly$time_new

dat_daily <- dplyr::bind_rows(lapply(tmp$daily$data, as_data_frame))
as.POSIXct(dat_daily$time, origin="1970-01-01")  -> dat_daily$time_new


