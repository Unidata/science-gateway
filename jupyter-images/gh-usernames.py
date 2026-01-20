# Script to check if GitHub usernames actually exist.  Put usernames to check
# in co-located users.txt file.  Useful in workshop scenarios where the user
# may or may not have provided the correct username.

import requests


def check_username(username):
    url = f"https://api.github.com/users/{username}"
    response = requests.get(url)
    return response.status_code == 200


def check_usernames_from_file(filename):
    with open(filename, 'r') as file:
        usernames = file.read().splitlines()

    existing_users = []
    non_existing_users = []

    for username in usernames:
        if check_username(username):
            existing_users.append(username)
        else:
            non_existing_users.append(username)

    print(f"Existing users: {existing_users}")
    print(f"Non-existing users: {non_existing_users}")


# Call the function with the filename
check_usernames_from_file('users.txt')
