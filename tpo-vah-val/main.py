import ccxt
from simulate import simulate_strategy
import pandas as pd




mexc = ccxt.mexc()
data = mexc.fetch_ohlcv('BTC/USDT', timeframe='30m', limit=300)

pd_data = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
pd_data['timestamp'] = pd.to_datetime(pd_data['timestamp'], unit='ms')


simulate_strategy(pd_data)


# today = datetime.today().date()
# data_today = pd_data[pd_data['timestamp'].dt.date == today]


# create_tpo(data_today)

# for i in range(5):
#     day = datetime.today().date() - timedelta(days=i)
#     data_day = pd_data[pd_data['timestamp'].dt.date == day]

#     print(day)
#     print(create_tpo(data_day))
#     print('-------')
