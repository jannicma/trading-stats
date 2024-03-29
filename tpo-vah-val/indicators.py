import pandas as pd
from datetime import datetime, time, timedelta



def calc_atr(data, timestamp):
    start_timestamp = timestamp - timedelta(hours=7)
    boolean_series: pd.Series = (data['timestamp'] <= timestamp) & (data['timestamp'] > start_timestamp)
    important_data: pd.DataFrame = data[boolean_series]

    added_ranges = 0.0
    for index, candle in important_data.iterrows():
        true_range = candle['high'] - candle['low']
        added_ranges += true_range

    atr = added_ranges / 14

    return round(atr, 2)



def calc_rsi(data, timestamp):
    start_timestamp = timestamp - timedelta(hours=7)
    boolean_series: pd.Series = (data['timestamp'] <= timestamp) & (data['timestamp'] > start_timestamp)
    important_data: pd.DataFrame = data[boolean_series]

    gain_amount = 0.0
    gain_candles = 0
    loss_amount = 0.0
    loss_candles = 0
    for index, candle in important_data.iterrows():
        if candle['open'] > candle['close']:
            loss_amount += candle['open'] - candle['close']
            loss_candles += 1
        else:
            gain_amount += candle['close'] - candle['open']
            gain_candles += 1
    
    avg_gain = gain_amount / gain_candles
    avg_loss = loss_amount / loss_candles

    rs = avg_gain / avg_loss
    rsi = 100 - ( 100 / ( 1 + rs ))
    
    return round(rsi, 2)