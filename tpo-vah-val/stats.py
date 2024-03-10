import ccxt

mexc = ccxt.mexc()
data = mexc.fetch_ohlcv('BTC/USDT', timeframe='30m')
print(data)