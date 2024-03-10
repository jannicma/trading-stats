import ccxt
from datetime import datetime
import pandas as pd
import matplotlib.pyplot as plt



def create_tpo(df):
    # Define price buckets
    price_buckets = pd.cut(df[['high', 'low']].max(axis=1),
                        bins=range(int(min(df['high'])), int(max(df['high'])), 21),
                        right=True)

    # Aggregate volume by bucket
    volume_by_bucket = price_buckets.value_counts()

    # Calculate Point of Control (POC)
    poc = volume_by_bucket.idxmax()

    center_points = [(interval.left + interval.right) / 2 for interval in volume_by_bucket.index]
    poc_center = (poc.left + poc.right) / 2

    # Plot histogram
    plt.bar(center_points, volume_by_bucket.values)  # Pass the list of center points
    plt.xlabel('Price Bucket ($)')
    plt.ylabel('Volume')
    plt.title('TPO Chart (BTC/USDT) - ' + str(datetime.today().date()))
    plt.axvline(x=poc_center, color='red', linestyle='dashed', linewidth=2, label='POC')
    plt.legend()
    plt.show()






mexc = ccxt.mexc()
data = mexc.fetch_ohlcv('BTC/USDT', timeframe='30m', limit=70)

pd_data = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
pd_data['timestamp'] = pd.to_datetime(pd_data['timestamp'], unit='ms')

today = datetime.today().date()
data_today = pd_data[pd_data['timestamp'].dt.date == today]

create_tpo(data_today)








a = ''