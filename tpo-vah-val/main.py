import ccxt
from simulate import simulate_strategy
import pandas as pd
from bot import run_bot


simulate = False
api = False
less_data = False

mexc = ccxt.mexc()

if simulate:
    if api:
        data = mexc.fetch_ohlcv('BTC/USDT', timeframe='30m', limit=3000)
    else:
        df = pd.read_csv('/Users/jannicmarcon/Documents/mexc_data.csv')
        df['timestamp'] = pd.to_datetime(df['time'], unit='s')  

        data = df[['timestamp', 'open', 'high', 'low', 'close']]
        
        if less_data:
            data = data[-200:]

    pd_data = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
    pd_data['timestamp'] = pd.to_datetime(pd_data['timestamp'], unit='ms')
    
    simulate_strategy(pd_data)
else:
    run_bot(mexc)

