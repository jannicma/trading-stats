from datetime import time


def closest_number(numbers, target):
    def distance(num):
        return abs(num - target)
    
    return min(numbers, key=distance)


def add_minutes(original_time, min = 30):
    total_minutes: int = original_time.hour * 60 + original_time.minute
    total_minutes += min
    new_hours: int = total_minutes // 60
    new_minutes: int = total_minutes % 60
    new_time: time = time(new_hours, new_minutes)
    return new_time
