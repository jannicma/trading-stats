from datetime import datetime, time, timedelta
import pandas as pd
from trade_model import trade_model
from helpers import add_minutes
from tpo import create_tpo
from typing import Union
from trade_logic import enter_logic, handle_trade




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
    trade_finished = False

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
                trade, trade_finished = handle_trade(daily_data, trade)

            #entry
            if trade_finished:
                trade_finished = False
                trade = enter_logic(daily_data)



        poc, vah, val = create_tpo(daily_data)

        current_time = add_minutes(current_time)


    a = 0
