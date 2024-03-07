from os import system
from os.path import isfile
from sys import stderr
from time import sleep

import argparse

from datetime import datetime, UTC 
import json
import csv
import requests
import plotly

from usage_monitoring_config import *

def create_os_token(token_file):
    return_val = system('openstack token issue -f json > {}'.format(token_file))
    # Sleep to give openstack the time to return the token
    sleep(5)
    if return_val != 0:
        raise

def get_os_token(token_file='/tmp/os-token.json', force_new_token=False):
    if isfile(token_file) and not force_new_token:
        with open(token_file, 'r') as f:
            f_json = json.load(f)
            date_format = '%Y-%m-%dT%H:%M:%S+0000'
            expires_str = f_json['expires']
            expire = datetime.strptime(expires_str, date_format).timestamp()
            now = datetime.now(UTC).timestamp()
            if expire > now:
                return f_json['id']
            else:
                print("Token expired. Creating new token", file=stderr)
                create_os_token(token_file)
    else:
        print('Creating new token file'.format(token_file), file=stderr)
        create_os_token(token_file)
        return get_os_token(token_file)

def query_accounting_api(token):
    url = 'https://js2.jetstream-cloud.org:9001'
    headers = { 'X-Auth-Token': '{}'.format(token) }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    query = json.loads(response.text)
    return query

def get_js2_resources(query):
    now = datetime.now()
    date_format = '%Y-%m-%d'
    all_resources = [ 
            resource for resource in query 
            if datetime.strptime(resource['start_date'],date_format) < now 
            and datetime.strptime(resource['end_date'],date_format) > now
        ]
    resource_list = [ resource['resource'] for resource in allocation_resources ]
    desired_resources = [
            resource for resource in all_resources
            if resource['resource'] in resource_list
        ]
    return desired_resources

def write_resource_csv(resources, data_file):
    '''Write the resource info into data_file with the csv format:
    timestamp,resource,service_units_used,service_units_allocated,start_date,end_date

    resources may be a dictionary or a list of dictionaries with the following keys:
        resource, service_units_used, service_units_allocated, start_date, end_date
    '''

    fieldnames = [
            'timestamp', 'resource', 'service_units_used',
            'service_units_allocated', 'start_date', 'end_date'
        ]
    now = datetime.now(UTC).timestamp()

    # Create file and write headers if it doesn't exist
    if not isfile(data_file):
        with open(data_file, 'w') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()

    with open(data_file, 'a') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        for resource in resources:
            writer.writerow({'timestamp': now,
                             'resource': resource['resource'],
                             'service_units_used': resource['service_units_used'],
                             'service_units_allocated': resource['service_units_allocated'],
                             'start_date': resource['start_date'],
                             'end_date': resource['end_date']})
    return 0

def read_resource_csv(data_file):
    '''Read in the resource info from data_file to be used in visualization, plotting, etc.
    File is in the following csv format:
    timestamp,resource,service_units_used,service_units_allocated,start_date,end_date
    '''
    with open(data_file, 'r') as f:
        resources = [ resource for resource in csv.DictReader(f) ]
    return resources

def generate_usage_plot():
    return 0

def print_usage_analysis():
    return 0

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--force-new-token', help='Force the creation of a new openstack token', action='store_true')
    parser.add_argument('-w', '--write', help='Query Jetstream2 for new allocation data and write to data file: {}'.format(data_file), action='store_true')
    parser.add_argument('-c', '--dump-csv', help='Dump the data from {} in csv format'.format(data_file), action='store_true')
    parser.add_argument('-j', '--dump-json', help='Dump the data from {} in json format'.format(data_file), action='store_true')
    parser.add_argument('-p', '--plot', help='Generate an interactive plot of SU usage data', action='store_true')
    parser.add_argument('-a', '--analysis', help='Print an analysis of SU usage data in json format', action='store_true')
    args = vars(parser.parse_args())

    if not any([ args[key] for key in args.keys() ]):
        parser.parse_args(['--help'])
        
    if args['write']:
        token = get_os_token(token_file,force_new_token=args['force_new_token'])
        query = query_accounting_api(token)
        resources = get_js2_resources(query)
        write_resource_csv(resources, data_file)

    if args['dump_csv']:
        system('cat {}'.format(data_file))

    if args['dump_json']:
        resources = read_resource_csv(data_file)
        print(json.dumps(resources, indent=2))

    if args['plot']:
        print('plot')

    if args['analysis']:
        print('analysis')

if __name__ == "__main__":
    main()
