import ccxt
from simulate import simulate_strategy
import pandas as pd
from bot import run_bot


simulate = True

mexc = ccxt.mexc()

if simulate:
    data = mexc.fetch_ohlcv('BTC/USDT', timeframe='30m', limit=3000)

    pd_data = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
    pd_data['timestamp'] = pd.to_datetime(pd_data['timestamp'], unit='ms')
    
    simulate_strategy(pd_data)
else:
    run_bot(mexc)

