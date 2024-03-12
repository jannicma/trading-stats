from math import floor
import ccxt
from datetime import datetime, timedelta
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def closest_number(numbers, target):
    def distance(num):
        return abs(num - target)
    
    return min(numbers, key=distance)


def print_tpo(tpo_dict):
        # Extract data as lists
    keys = list(tpo_dict.keys())
    values = list(tpo_dict.values())

    # Create bar chart with Seaborn
    sns.barplot(x=values, y=keys, orient='h')  # Use 'h' for horizontal bars

    # Set chart labels and title
    plt.xlabel('Value')
    plt.ylabel('Key')
    plt.title('Seaborn Bar Chart (Keys vs. Values)')

    # Make bars thicker
    sns.despine(left=True)  # Remove unnecessary left spine

    # Optional: Rotate x-axis labels for better readability
    plt.xticks(rotation=45)  # Rotate labels by 45 degrees

    # Show the chart
    plt.tight_layout()
    plt.show()

def calculate_poc(tpo_dict):
    tpo_height = len(tpo_dict)

    max_tpos = max(tpo_dict.values())
    highest_tpos = {}
    i = 0
    for price, tpos in tpo_dict.items():
        if tpos == max_tpos:
            highest_tpos[i] = price
        i+=1

    poc = 0
    if len(highest_tpos) > 1:
        keys = highest_tpos.keys()
        key = closest_number(keys, tpo_height/2)
        poc = highest_tpos[key]
    else:
        poc = list(highest_tpos.values())[0]

    return poc


def calculate_value_area(tpos, va, poc, block_size):
    tpo_count = sum(tpos.values())
    tpo_va = floor(tpo_count / 100 * va)
    tpos_done = 0
    upper_level = poc
    lower_level = poc

    while tpos_done <= tpo_va:
        if tpos_done == 0:
            tpos_done += tpos[poc]
            upper_level += block_size
            lower_level -= block_size
        else:
            if lower_level not in tpos.keys() or (upper_level in tpos.keys() and tpos[upper_level] >= tpos[lower_level]):
                tpos_done += tpos[upper_level]
                upper_level += block_size
            else:
                tpos_done += tpos[lower_level]
                lower_level -= block_size

    return upper_level, lower_level


def calculate_tpo_values(tpo_dict, tpo_size, value_area=70):
    tpo_dict = dict(sorted(tpo_dict.items()))

    #calculate POC
    poc = calculate_poc(tpo_dict)

    #calculate VAH / VAL
    vah, val = calculate_value_area(tpo_dict, value_area, poc, tpo_size)

    # Return results
    return vah, val, poc



def create_tpo(df, tpo_size = 21):
    max_val = df['high'].max()
    min_val = df['low'].min()

    max_box_level = floor(max_val / tpo_size) * tpo_size
    min_box_level = floor(min_val / tpo_size) * tpo_size

    tpo_dict = {}
    for num in range(min_box_level, max_box_level+1, tpo_size):
        tpo_dict[num] = 0

    for _ , row in df.iterrows():
        high = row['high']
        low = row['low']

        for key in tpo_dict:
            if low < (key + tpo_size) and high >= key:
                tpo_dict[key]+=1
        
    if False:
        print_tpo(tpo_dict)
    
    vah, val, poc = calculate_tpo_values(tpo_dict, tpo_size, 70)
    return poc, vah, val




mexc = ccxt.mexc()
data = mexc.fetch_ohlcv('BTC/USDT', timeframe='30m', limit=300)

pd_data = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
pd_data['timestamp'] = pd.to_datetime(pd_data['timestamp'], unit='ms')

today = datetime.today().date()
data_today = pd_data[pd_data['timestamp'].dt.date == today]

create_tpo(data_today)

for i in range(5):
    day = datetime.today().date() - timedelta(days=i)
    data_day = pd_data[pd_data['timestamp'].dt.date == day]

    print(day)
    print(create_tpo(data_day))
    print('-------')
