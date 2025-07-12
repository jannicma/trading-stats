import pandas as pd
import datetime

def main():
    full_data = pd.read_csv('/Users/jannicmarcon/Documents/GitHub/trading-stats/cheapest-day/data/BTC_4h.csv')
    full_data['timestamp'] = pd.to_datetime(full_data['time'], unit='s')

    week_low_day = -1
    week_low = 9999999
    lowest_days = {}
    last_weekday = -1
    daily_low = 9999999
    for _, row in full_data.iterrows():
        curr_date = row['timestamp']
        curr_low = row['low']
        curr_weekday = curr_date.to_pydatetime().weekday()

        if last_weekday != curr_weekday:
            daily_low = curr_low
        else:
            daily_low = curr_low if curr_low < daily_low else daily_low 

        if curr_weekday == 0:
            week_low = daily_low
            week_low_day = curr



main()
