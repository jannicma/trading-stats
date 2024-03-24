from datetime import datetime, time, timedelta
import pandas as pd
from trade_model import trade_model
from helpers import add_minutes
from tpo import create_tpo
from typing import Union




def simulate_strategy(data):
    first_timestamp: pd.Timestamp = pd.to_datetime(data.head(1)['timestamp']).iloc[0]
    first_day: pd.Timestamp = first_timestamp - timedelta(hours=first_timestamp.hour, minutes=first_timestamp.minute)

    loop: bool = True
    daily_date: pd.Timestamp = first_day
    current_time: time = time(hour=23, minute=30)
    poc: int = 0
    vah: int = 0
    val: int = 0
    end_trade = False
    trade: Union[trade_model, None] = None
    last_datetime: datetime = datetime.min

    while loop:
        if current_time == time(hour=23, minute=30):
            current_time = time(hour=6)
            daily_date += timedelta(days=1)
            poc, vah, val = (0, 0, 0)

        boolean_series: pd.Series = (data['timestamp'].dt.date == daily_date.date()) & (data['timestamp'].dt.time <= current_time)
        daily_data: pd.DataFrame = data[boolean_series]
        
        if len(daily_data) == 0:
            break

        if poc > 0:
            #in trade
            if isinstance(trade, trade_model):
                #in long
                if trade.is_long:
                    #update deviation
                    if trade.entry - daily_data.iloc[-1]['low'] > trade.deviation:
                        trade.deviation = trade.entry - daily_data.iloc[-1]['low']
                        if trade.deviation > 1300:
                            end_trade = True

                    #poc hit
                    if daily_data.iloc[-1]['high'] >= poc and trade.poc_hit is None:
                        trade.poc_hit = poc

                    #entry after poc hit
                    if trade.poc_hit is not None and trade.poc_hit > 0 and daily_data.iloc[-1]['low'] <= trade.entry:
                        end_trade = True

                    #vah hit
                    if daily_data.iloc[-1]['high'] >= vah:
                        trade.range_hit = vah
                        end_trade = True


                #in short
                else:
                    #update deviation
                    if daily_data.iloc[-1]['high'] - trade.entry > trade.deviation:
                        trade.deviation = daily_data.iloc[-1]['high'] - trade.entry
                        if trade.deviation > 1300:
                            end_trade = True

                    #poc hit
                    if daily_data.iloc[-1]['low'] <= poc and trade.poc_hit is None:
                        trade.poc_hit = poc

                    #entry after poc hit
                    if trade.poc_hit is not None and trade.poc_hit > 0 and daily_data.iloc[-1]['high'] >= trade.entry:
                        end_trade = True

                    #val hit
                    if daily_data.iloc[-1]['low'] <= val:
                        trade.range_hit = val
                        end_trade = True

                if end_trade:
                    last_datetime = trade.entry_time
                    trade = trade.finish_trade()
                    end_trade = False
                    print('-----------')

            #entry
            if trade is None:
                min_datetime: datetime = last_datetime + timedelta(hours=1)
                #short
                if daily_data.iloc[-1]['high'] > vah and daily_data.iloc[-2]['close'] <= vah and min_datetime <= daily_data.iloc[-1]['timestamp']:
                    print(vah, val, poc)
                    deviation = daily_data.iloc[-1]['high'] - vah
                    trade = trade_model(vah, daily_data.iloc[-1]['timestamp'], False, deviation)

                #long
                elif daily_data.iloc[-1]['low'] < val and daily_data.iloc[-2]['close'] >= val and min_datetime <= daily_data.iloc[-1]['timestamp']:
                    print(vah, val, poc)
                    deviation = val - daily_data.iloc[-1]['low']
                    trade = trade_model(val, daily_data.iloc[-1]['timestamp'], True, deviation)



        poc, vah, val = create_tpo(daily_data)

        current_time = add_minutes(current_time)


    a = 0
