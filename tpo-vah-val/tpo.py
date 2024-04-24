from helpers import closest_number
import matplotlib.pyplot as plt
import seaborn as sns
from math import floor
import settings


def print_tpo(tpo_dict):
        # Extract data as lists
    keys = list(tpo_dict.keys())
    values = list(tpo_dict.values())

    # Create bar chart with Seaborn
    sns.barplot(x=values, y=keys, orient='h')  # Use 'h' for horizontal bars

    # Set chart labels and title
    plt.xlabel('Value')
    plt.ylabel('Key')
    plt.title('Seaborn Bar Chart (Keys vs. Values)')

    # Make bars thicker
    sns.despine(left=True)  # Remove unnecessary left spine

    # Optional: Rotate x-axis labels for better readability
    plt.xticks(rotation=45)  # Rotate labels by 45 degrees

    # Show the chart
    plt.tight_layout()
    plt.show()



def calculate_poc(tpo_dict):
    tpo_height = len(tpo_dict)

    max_tpos = max(tpo_dict.values())
    highest_tpos = {}
    i = 0
    for price, tpos in tpo_dict.items():
        if tpos == max_tpos:
            highest_tpos[i] = price
        i+=1

    poc = 0
    if len(highest_tpos) > 1:
        keys = highest_tpos.keys()
        key = closest_number(keys, tpo_height/2)
        poc = highest_tpos[key]
    else:
        poc = list(highest_tpos.values())[0]

    return poc



def calculate_value_area(tpos, va, poc, block_size):
    tpo_count = sum(tpos.values())
    tpo_va = floor(tpo_count / 100 * va)
    tpos_done = 0
    upper_level = poc
    lower_level = poc

    while tpos_done <= tpo_va:
        if tpos_done == 0:
            tpos_done += tpos[poc]
            upper_level += block_size
            lower_level -= block_size
        else:
            if lower_level not in tpos.keys() or (upper_level in tpos.keys() and tpos[upper_level] >= tpos[lower_level]):
                tpos_done += tpos[upper_level]
                upper_level += block_size
            else:
                tpos_done += tpos[lower_level]
                lower_level -= block_size

    return upper_level, lower_level



def calculate_tpo_values(tpo_dict, tpo_size, value_area=70):
    tpo_dict = dict(sorted(tpo_dict.items()))

    #calculate POC
    poc = calculate_poc(tpo_dict)

    #calculate VAH / VAL
    vah, val = calculate_value_area(tpo_dict, value_area, poc, tpo_size)

    # Return results
    return vah, val, poc



def create_tpo(df, tpo_size = 21):
    max_val: int = df['high'].max()
    min_val: int = df['low'].min()

    tpo_size = floor((max_val - min_val) / 30)

    max_box_level = floor(max_val / tpo_size) * tpo_size
    min_box_level = floor(min_val / tpo_size) * tpo_size

    tpo_dict = {}
    for num in range(min_box_level, max_box_level+1, tpo_size):
        tpo_dict[num] = 0

    for _ , row in df.iterrows():
        high: int = row['high']
        low = row['low']

        for key in tpo_dict:
            if low < (key + tpo_size) and high >= key:
                tpo_dict[key]+=1
        
    if settings.print_tpo:
        print_tpo(tpo_dict)
    
    vah, val, poc = calculate_tpo_values(tpo_dict, tpo_size, 70)
    return poc, vah, val
