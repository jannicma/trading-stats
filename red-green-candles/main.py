import pandas as pd
from stats import run_simulation


df = pd.read_csv('/Users/jannicmarcon/Documents/EURUSD_5m.csv')
df['timestamp'] = pd.to_datetime(df['time'], unit='s')  

data = df[['timestamp', 'open', 'high', 'low', 'close']]
        
if False:
    data = data[-500:]

pd_data = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
pd_data['timestamp'] = pd.to_datetime(pd_data['timestamp'], unit='ms')
    
run_simulation(pd_data)