from datetime import datetime
from typing import Union


class trade_model:
    def __init__(self, entry, entry_time, is_long, deviation, poc_hit = None, range_hit = None):
        self.entry: float = entry
        self.entry_time: datetime = entry_time
        self.is_long: bool = is_long
        self.deviation: float = deviation
        self.poc_hit: Union[float, None] = poc_hit
        self.range_hit: Union[float, None] = range_hit

    def print_trade(self):
        print(f'Time: {self.entry_time};\tEntry: {str(self.entry)};\tLong: {str(self.is_long)};\tDeviation: {self.deviation:.2f};\tPOC Hit: {self.poc_hit};\tRange Hit: {self.range_hit}')

    def finish_trade(self):
        self.print_trade()
        return None