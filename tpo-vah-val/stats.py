from math import floor
import ccxt
from datetime import datetime, time, timedelta
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
    max_val: int = df['high'].max()
    min_val: int = df['low'].min()

    max_box_level = floor(max_val / tpo_size) * tpo_size
    min_box_level = floor(min_val / tpo_size) * tpo_size

    tpo_dict = {}
    for num in range(min_box_level, max_box_level+1, tpo_size):
        tpo_dict[num] = 0

    for _ , row in df.iterrows():
        high: int = row['high']
        low = row['low']

        for key in tpo_dict:
            if low < (key + tpo_size) and high >= key:
                tpo_dict[key]+=1
        
    if False:
        print_tpo(tpo_dict)
    
    vah, val, poc = calculate_tpo_values(tpo_dict, tpo_size, 70)
    return poc, vah, val


def add_minutes(original_time, min = 30):
    total_minutes: int = original_time.hour * 60 + original_time.minute
    total_minutes += min
    new_hours: int = total_minutes // 60
    new_minutes: int = total_minutes % 60
    new_time: time = time(new_hours, new_minutes)
    return new_time


def simulate_strategy(data):
    first_timestamp: pd.Timestamp = pd.to_datetime(data.head(1)['timestamp']).iloc[0]
    first_day: pd.Timestamp = first_timestamp - timedelta(hours=first_timestamp.hour, minutes=first_timestamp.minute)

    loop: bool = True
    daily_date: pd.Timestamp = first_day
    current_time: time = time(hour=23, minute=30)
    poc: int = 0
    vah: int = 0
    val: int = 0
    entry: float = 0.0
    deviation: float = 0.0
    entry_long: bool = False
    poc_hit: int = 0
    range_hit: int = 0

    while loop:
        if current_time == time(hour=23, minute=30):
            current_time = time(hour=6)
            daily_date += timedelta(days=1)
            poc, vah, val = (0, 0, 0)

        boolean_series: pd.Series = (data['timestamp'].dt.date == daily_date.date()) & (data['timestamp'].dt.time <= current_time)
        daily_data: pd.DataFrame = data[boolean_series]
        
        if poc > 0:
            #in trade
            if entry > 0:
                #in long
                if entry_long:
                    #update deviation
                    if entry - daily_data.iloc[-1]['low'] > deviation:
                        deviation = entry - daily_data.iloc[-1]['low']

                    #poc hit
                    if daily_data.iloc[-1]['high'] >= poc and poc_hit == 0:
                        poc_hit = poc

                    #entry after poc hit
                    if poc_hit > 0 and daily_data.iloc[-1]['low'] <= entry:
                        a=0

                    #vah hit
                    if daily_data.iloc[-1]['high'] >= vah:
                        range_hit = vah


                #in short
                elif not entry_long:
                    #update deviation
                    if daily_data.iloc[-1]['high'] - entry > deviation:
                        deviation = daily_data.iloc[-1]['high'] - entry

                    #poc hit
                    if daily_data.iloc[-1]['low'] <= poc and poc_hit == 0:
                        poc_hit = poc

                    #entry after poc hit
                    if poc_hit > 0 and daily_data.iloc[-1]['high'] >= entry:
                        a=0

                    #val hit
                    if daily_data.iloc[-1]['low'] <= val:
                        range_hit = val


            #entry
            if entry == 0:
                #short
                if daily_data.iloc[-1]['high'] > vah:
                    entry_long = False
                    entry = vah
                    deviation = daily_data.iloc[-1]['high'] - vah

                #long
                elif daily_data.iloc[-1]['low'] < val:
                    entry_long = True
                    entry = val
                    deviation = val - daily_data.iloc[-1]['low']


        poc, vah, val = create_tpo(daily_data)

        current_time = add_minutes(current_time)
    
    a = 0


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
