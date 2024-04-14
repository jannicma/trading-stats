import ccxt
from simulate import simulate_strategy
import pandas as pd
from bot import run_bot
from mail import send_mail
import settings


mexc = ccxt.mexc()

if settings.simulate_strategy:
    if settings.get_data_from_api:
        data = mexc.fetch_ohlcv('BTC/USDT', timeframe='30m', limit=3000)
    else:
        df = pd.read_csv('/Users/jannicmarcon/Documents/mexc_data.csv')
        df['timestamp'] = pd.to_datetime(df['time'], unit='s')  

        data = df[['timestamp', 'open', 'high', 'low', 'close']]
        
        if settings.less_data:
            data = data[-200:]

    pd_data = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
    pd_data['timestamp'] = pd.to_datetime(pd_data['timestamp'], unit='ms')
    
    simulate_strategy(pd_data)
else:
    send_mail('Start Bot...')
    run_bot(mexc)

