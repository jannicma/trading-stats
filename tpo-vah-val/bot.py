from trade_model import trade_model
from trade_logic import enter_logic, handle_trade


import time
import threading

def call_every_thirty_minutes(target_function, exchange):
    def schedule_task():
        while True:
            one_minute = True
            if one_minute:
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
    data = exchange.fetch_ohlcv('BTC/USDT', timeframe='1m', limit=3)
    #TODO remove last candle - its only 10 seconds long
    print(data)
    print()

def run_bot(exchange):
    call_every_thirty_minutes(bot_logic, exchange)
    
    print('running...')