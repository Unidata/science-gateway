import csv

from datetime import datetime, timedelta

import plotly.express as px

from usage_monitoring_config import *

'''
Create a test data set.

The data set is a piecewise linear function with SU usage meant to imitate a
typical academic year, with SU usage being higher during the fall and spring
semesters, and lower during the winter and summer breaks.

The parameters in this script are not representative of reality
'''

resource = 'jetstream2.indiana.xsede.org'
total_sus = 8000000
baseline_usage = 900*24 # 900 SUs/hr*24hr/day

allocation_start = '2023-10-01'
allocation_end = '2024-09-30'


date_format = '%Y-%m-%d'

# Parameters for the Fall semester
f_su_rate = baseline_usage
f_sus_begin = total_sus
f_begin = datetime.strptime('2023-08-25', date_format)
f_end = datetime.strptime('2023-12-12', date_format)
total_f = (f_end - f_begin).days

# Parameters for the Winter Break
w_su_rate = 0.25*baseline_usage
w_sus_begin = f_sus_begin - f_su_rate*total_f
w_begin = datetime.strptime('2023-12-13', date_format)
w_end = datetime.strptime('2024-01-19', date_format)
total_w = (w_end - w_begin).days

# Parameters for the Spring semester
sp_su_rate = baseline_usage
sp_sus_begin = w_sus_begin - w_su_rate*total_w
sp_begin = datetime.strptime('2024-01-20', date_format)
sp_end = datetime.strptime('2024-05-10', date_format)
total_sp = (sp_end - sp_begin).days

# Parameters for the Summer break
sm_su_rate = 0.4*baseline_usage
sm_sus_begin = sp_sus_begin - sp_su_rate*total_sp
sm_begin = datetime.strptime('2024-05-11', date_format)
sm_end = datetime.strptime('2024-08-24', date_format)
total_sm = (sm_end - sm_begin).days

#############################################
# Generate test data
#############################################

total_days = (sm_end - f_begin).days
dates = [ f_begin + timedelta(days=i) for i in range(total_days+1) ]
sus_remaining = [ 0.0 for i in range(total_days+1) ]

# Piecewise linear function
for i,date in enumerate(sus_remaining):
    # Fall
    if dates[i] >= f_begin and dates[i] <= f_end:
        ddays = (dates[i] - f_begin).days
        sus_remaining[i] = f_sus_begin - ddays*f_su_rate
    # Winter
    if dates[i] >= w_begin and dates[i] <= w_end:
        ddays = (dates[i] - w_begin).days
        sus_remaining[i] = w_sus_begin - ddays*w_su_rate
    # Spring
    if dates[i] >= sp_begin and dates[i] <= sp_end:
        ddays = (dates[i] - sp_begin).days
        sus_remaining[i] = sp_sus_begin - ddays*sp_su_rate
    # Summer
    if dates[i] >= sm_begin and dates[i] <= sm_end:
        ddays = (dates[i] - sm_begin).days
        sus_remaining[i] = sm_sus_begin - ddays*sm_su_rate

sus_used = [ total_sus - sus_rem for sus_rem in sus_remaining ]

# Visualize?
viz = False
if viz:
    fig = px.scatter(x=dates, y=sus_used)
    fig.show()

#############################################
# Export test data to csv
#############################################

ts = [ date.timestamp() for date in dates ]

with open(test_csv_file, 'w') as f:
    fieldnames = [
            'timestamp', 'resource', 'service_units_used',
            'service_units_allocated', 'start_date', 'end_date'
        ]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    for time,sus in zip(ts,sus_used):
        writer.writerow({'timestamp': time,
                         'resource': resource,
                         'service_units_used': sus,
                         'service_units_allocated': total_sus,
                         'start_date': allocation_start,
                         'end_date': allocation_end})
