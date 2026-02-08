from app.services.weather_service import convert_lat_lon_to_grid
import math

try:
    lat = 37.4219983
    lng = -122.084
    print(f"Testing conversion for lat={lat}, lng={lng}")
    nx, ny = convert_lat_lon_to_grid(lat, lng)
    print(f"Result: nx={nx}, ny={ny}")
except Exception as e:
    print(f"Error during conversion: {e}")
