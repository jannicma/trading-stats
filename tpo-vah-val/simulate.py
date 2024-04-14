from datetime import datetime, time, timedelta
from math import floor
import pandas as pd
from trade_model import trade_model
from helpers import add_minutes
from typing import Union
from trade_logic import enter_logic, handle_trade
import settings


def analyze_strategy(trades):
    num_trades = len(trades)
    num_poc = 0
    num_range = 0
    plus = 0
    minus = 0
    for trade in trades:
        if trade.poc_hit is not None:
            plus += abs(trade.entry - trade.poc_hit)
            num_poc += 1
        if trade.range_hit is not None:
            num_range += 1

        if trade.poc_hit is None:
            minus += floor(abs(2*trade.atr))

    loss_trades = num_trades - num_poc

    print(f'Trades: {num_trades}; POC Hits: {num_poc}; Range Hits: {num_range}; Loss Trades: {loss_trades}')
    print(f'Profit: {plus}; Loss: {minus}')

    if settings.print_csv:
        with open("/Users/jannicmarcon/Desktop/trades.csv", "w") as file:
            file.write("time,entry,long,deviation,atr,rsi,poc,range\n")
            for trade in trades:
                file.write(f"{trade.entry_time},{trade.entry},{trade.is_long},{trade.deviation},{trade.atr},{trade.rsi},{trade.poc_hit},{trade.range_hit}\n")



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
    all_trades = []

    while loop:
        if current_time == time(hour=23, minute=30):
            current_time = time(hour=6)
            daily_date += timedelta(days=1)

        boolean_series: pd.Series = (data['timestamp'].dt.date == daily_date.date()) & (data['timestamp'].dt.time <= current_time)
        daily_data: pd.DataFrame = data[boolean_series]
        
        if len(daily_data) == 0:
            break

        #in trade
        if isinstance(trade, trade_model):
            trade, trade_finished = handle_trade(daily_data, trade)

        #entry
        if trade_finished:
            trade_finished = False
            all_trades.append(trade)
            trade = None
            
        if trade is None:
            trade = enter_logic(daily_data, data)


        current_time = add_minutes(current_time)

    analyze_strategy(all_trades)

    a = 0
