def run_simulation(data):
    count_same = 0
    count_different = 0

    #new field macd hist on all

    for candle in range(1, len(data)):
        current_candle = data.iloc[candle]
        previous_candle = data.iloc[candle-1]
        pre_previous_candle = data.iloc[candle-2]

        current_is_green = current_candle['open'] - current_candle['close'] < 0
        previous_is_green = previous_candle['open'] - previous_candle['close'] < 0

        previous_macd_hist = 0 # previous_candle['hist']
        pre_previous_macd_hist = 0 # pre_previous_candle['hist']

        if previous_is_green and previous_macd_hist > pre_previous_macd_hist:
            if current_is_green == previous_is_green:
                count_same += 1
            else:
                count_different += 1
        
        if not previous_is_green and previous_macd_hist < pre_previous_macd_hist:
            if current_is_green == previous_is_green:
                count_same += 1
            else:
                count_different += 1


    print(f'same: {count_same}')
    print(f'different: {count_different}')