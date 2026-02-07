import httpx
import asyncio

async def main():
    url = "http://127.0.0.1:8000/api/v1/weather/current"
    params = {"lat": 37.4219983, "lng": -122.084}
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get(url, params=params, timeout=10.0)
            print(f"Status: {resp.status_code}")
            print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Request failed: {e}")

if __name__ == "__main__":
    asyncio.run(main())
