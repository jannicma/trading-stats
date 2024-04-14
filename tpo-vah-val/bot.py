from datetime import datetime
from trade_model import trade_model
from trade_logic import enter_logic, handle_trade
from mail import send_mail
import settings

import pandas as pd
import time
import threading

def call_every_thirty_minutes(target_function, exchange):
    def schedule_task():
        while True:
            one_minute = True
            if settings.one_minute_bot_run:
                # 1m + 10s
                current_time = time.time()
                # Get minutes since epoch (ignoring seconds)
                minutes_since_epoch = int(current_time // 60)

                # Calculate next minute with 10 seconds offset
                next_time = (minutes_since_epoch + 1) * 60 + 10

            else:
                # 30m + 10s
                next_time = (int(time.time()) // 1800 + 1) * 1800 + 10


            # Wait until the precise time
            time.sleep(max(next_time - time.time(), 0))

            # Call the target function
            target_function(exchange)
            

    thread = threading.Thread(target=schedule_task)
    thread.start()


def bot_logic(exchange):
    now: datetime = datetime.now()
    now_timestamp = now.timestamp()
    now = now.replace(hour=6, minute=0, second=0, microsecond=0)
    min_required_time = now.timestamp()

    if now_timestamp <= min_required_time:
        return None

    data = exchange.fetch_ohlcv('BTC/USDT', timeframe='30m', limit=60, )
    full_data = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
    full_data['timestamp'] = pd.to_datetime(full_data['timestamp'], unit='ms')   
    full_data = full_data[:-1]

    boolean_series: pd.Series = full_data['timestamp'].dt.date == datetime.today().date()
    daily_data: pd.DataFrame = full_data[boolean_series]

    trade = enter_logic(daily_data, full_data)

    if trade is not None:
        formatted_datetime = now.strftime("%Y-%m-%d %H:%M:%S")

        msg = f'New Trade:\nTime:\t{formatted_datetime}\nPrice:\t{trade.entry}\nATR:\t{trade.atr}\nRSI:\t{trade.rsi}\nLong:\t{trade.is_long}'
        send_mail(msg)



def run_bot(exchange):
    bot_logic(exchange)
    #call_every_thirty_minutes(bot_logic, exchange)
    
    print('running...')