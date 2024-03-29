import pandas as pd
from trade_model import trade_model
from tpo import create_tpo
from indicators import calc_atr, calc_rsi



def enter_logic(data: pd.DataFrame, full_data):
    poc, vah, val = create_tpo(data)
    trade = None

    if data.iloc[-1]['high'] > vah and data.iloc[-2]['close'] <= vah:
        deviation = data.iloc[-1]['high'] - vah

        atr = calc_atr(full_data, data.iloc[-1]['timestamp'])
        rsi= calc_rsi(full_data, data.iloc[-1]['timestamp'])

        trade = trade_model(vah, data.iloc[-1]['timestamp'], False, deviation, atr, rsi)

    #long
    elif data.iloc[-1]['low'] < val and data.iloc[-2]['close'] >= val:
        deviation = val - data.iloc[-1]['low']

        atr = calc_atr(full_data, data.iloc[-1]['timestamp'])
        rsi= calc_rsi(full_data, data.iloc[-1]['timestamp'])

        trade = trade_model(val, data.iloc[-1]['timestamp'], True, deviation, atr, rsi)

    return trade



def handle_trade(data: pd.DataFrame, trade: trade_model):
    poc, vah, val = create_tpo(data)
    end_trade: bool = False

    #in long
    if trade.is_long:
        #update deviation
        if trade.entry - data.iloc[-1]['low'] > trade.deviation:
            trade.deviation = trade.entry - data.iloc[-1]['low']
            if trade.deviation > 1300:
                end_trade = True

        #poc hit
        if data.iloc[-1]['high'] >= poc and trade.poc_hit is None:
            trade.poc_hit = poc

        #entry after poc hit
        if trade.poc_hit is not None and trade.poc_hit > 0 and data.iloc[-1]['low'] <= trade.entry:
            end_trade = True

        #vah hit
        if data.iloc[-1]['high'] >= vah:
            trade.range_hit = vah
            end_trade = True


    #in short
    else:
        #update deviation
        if data.iloc[-1]['high'] - trade.entry > trade.deviation:
            trade.deviation = data.iloc[-1]['high'] - trade.entry
            if trade.deviation > 1300:
                end_trade = True

        #poc hit
        if data.iloc[-1]['low'] <= poc and trade.poc_hit is None:
            trade.poc_hit = poc

        #entry after poc hit
        if trade.poc_hit is not None and trade.poc_hit > 0 and data.iloc[-1]['high'] >= trade.entry:
            end_trade = True

        #val hit
        if data.iloc[-1]['low'] <= val:
            trade.range_hit = val
            end_trade = True

    if end_trade:
        last_datetime = trade.entry_time
        trade.finish_trade()
        print('-----------')
        return trade, True
    
    return trade, False