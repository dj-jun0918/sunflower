"""날씨 API 테스트 스크립트"""
import asyncio
import sys
sys.path.insert(0, '.')

from app.services.weather_service import WeatherService

async def test():
    ws = WeatherService()
    print(f'API Key available: {ws._is_available()}')
    print(f'API Key (first 20 chars): {ws.api_key[:20] if ws.api_key else None}...')
    
    # 테스트 호출
    print("\n--- Calling get_vilage_fcst ---")
    result = await ws.get_vilage_fcst(73, 134)
    if result:
        print(f'is_mock: {result.get("is_mock")}')
        print(f'forecasts count: {len(result.get("forecasts", []))}')
        if result.get('forecasts'):
            print(f'first forecast: {result["forecasts"][0]}')
            # last forecast to see range
            print(f'last forecast: {result["forecasts"][-1]}')
    else:
        print('No result from get_vilage_fcst')

    print("\n--- Calling get_short_term_forecast ---")
    short_term = await ws.get_short_term_forecast(73, 134)
    print(f"Short term result: {short_term}")


asyncio.run(test())
