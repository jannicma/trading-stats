def run_simulation(data):
    count_same = 0
    count_different = 0

    for candle in range(1, len(data)):
        current_candle = data.iloc[candle]
        previous_candle = data.iloc[candle-1]

        current_is_green = current_candle['open'] - current_candle['close'] < 0
        previous_is_green = previous_candle['open'] - previous_candle['close'] < 0

        current_macd_hist = 0
        previous_macd_hist = 0

        #TODO Add hist comparison
        if current_is_green == previous_is_green:
            count_same += 1
        else:
            count_different += 1

    print(f'same: {count_same}')
    print(f'different: {count_different}')