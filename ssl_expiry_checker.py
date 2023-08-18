#!/usr/bin/env python3

import ssl
import socket
import datetime
import yaml
import subprocess
import argparse


def get_ssl_expiry_date(host, port=443):
    context = ssl.create_default_context()
    conn = context.wrap_socket(socket.socket(socket.AF_INET),
                               server_hostname=host)
    conn.settimeout(3.0)

    try:
        conn.connect((host, port))
        ssl_info = conn.getpeercert()
        return datetime.datetime.strptime(
            ssl_info['notAfter'], '%b %d %H:%M:%S %Y %Z')
    finally:
        conn.close()


def send_email_via_sendmail(recipients, sender, subject, body):
    if not isinstance(recipients, list):
        recipients = [recipients]

    recipients_str = ', '.join(recipients)
    message = (f"From: {sender}\nTo: {recipients_str}\n"
               f"Subject: {subject}\n\n{body}")

    process = subprocess.Popen(["/usr/sbin/sendmail"] + recipients,
                               stdin=subprocess.PIPE)
    process.communicate(message.encode('utf-8'))


def main():
    description_text = 'SSL certificate expiry checker.'
    parser = argparse.ArgumentParser(description=description_text)
    parser.add_argument('config_file',
                        help='Path to the YAML configuration file.')
    args = parser.parse_args()

    with open(args.config_file, 'r') as file:
        config = yaml.safe_load(file)

    for site in config['websites']:
        try:
            expiry_date = get_ssl_expiry_date(site)
        except socket.gaierror:
            print(f"Failed to resolve domain: {site}. Skipping...")
            continue

        expiry_date = get_ssl_expiry_date(site)
        now = datetime.datetime.now()

        if (expiry_date - now).days <= config.get('warning_days', 30):
            sender = config['email_sender']
            recipients = config['email_recipients']
            subject = "SSL Certificate Expiry Alert"
            body = (f"The SSL certificate for {site} "
                    f"is expiring on {expiry_date}.")

            send_email_via_sendmail(recipients, sender, subject, body)

            print(f"Alert sent for {site} to "
                  f"{', '.join(config['email_recipients'])}!")
        else:
            print(f"Certificate for {site} is valid till {expiry_date}.")


if __name__ == '__main__':
    main()
