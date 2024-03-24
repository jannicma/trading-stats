import pandas as pd
from trade_model import trade_model
from tpo import create_tpo



def enter_logic(data: pd.DataFrame):
    #TODO implement 1h break after getting stopped out (here?)

    poc, vah, val = create_tpo(data)
    trade = None

    if data.iloc[-1]['high'] > vah and data.iloc[-2]['close'] <= vah:
        print(vah, val, poc)
        deviation = data.iloc[-1]['high'] - vah
        trade = trade_model(vah, data.iloc[-1]['timestamp'], False, deviation)

    #long
    elif data.iloc[-1]['low'] < val and data.iloc[-2]['close'] >= val:
        print(vah, val, poc)
        deviation = val - data.iloc[-1]['low']
        trade = trade_model(val, data.iloc[-1]['timestamp'], True, deviation)

    return trade




def handle_trade(data: pd.DataFrame, trade: trade_model):
    print('stay or exit on POC/Range')