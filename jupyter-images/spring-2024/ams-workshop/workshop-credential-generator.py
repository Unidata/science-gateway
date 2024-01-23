#!/usr/bin/env python

import argparse
import random
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas


def generate_hex_string(existing_hex):
    """Generate a unique 4-character hexadecimal string."""
    while True:
        # 0 and 1 can be confused with letters. Skipping those
        hex_string = ''.join(random.choices('23456789abcdef', k=4))
        if hex_string not in existing_hex:
            return hex_string


def create_pdf(filename, usernames):
    c = canvas.Canvas(filename, pagesize=letter)
    width, height = letter
    margin, line_height, current_height = 72, 14, height - 72

    c.setFont("Courier", 12)

    for i, hex_string in enumerate(usernames):
        if i % 10 == 0 and i != 0:
            c.showPage()
            current_height = height - margin
            c.setFont("Courier", 12)

        lines = ["https://pyaos-workshop.unidata.ucar.edu/",
                 f"username: ams-{hex_string}",
                 "password: xxx"]

        # Position for the line (midway between entries)
        line_y_position = current_height - line_height * len(lines)
        - line_height / 2

        for line in lines:
            c.drawString(margin, current_height, line)
            current_height -= line_height

        # Draw the line after writing the entry
        if i != 0:  # Avoid drawing a line before the first entry
            c.line(margin, line_y_position, width - margin, line_y_position)

        # Additional spacing after each entry
        current_height -= line_height * 2

    c.save()


def write_usernames_to_text(filename, usernames):
    with open(filename, 'w') as f:
        f.write("hub:\n  config:\n    Authenticator:\n      allowed_users:\n")
        f.writelines([f"        - ams-{username}\n" for username in usernames])


def main():
    parser = argparse.ArgumentParser(description="Generate a PDF of unique, "
                                     "alphabetically ordered user "
                                     "credentials.")
    parser.add_argument("total_entries", type=int, help="Number of total "
                        "unique entries to generate.")
    args = parser.parse_args()

    existing_hex = set()
    usernames = sorted(generate_hex_string(existing_hex)
                       for _ in range(args.total_entries))

    create_pdf("usernames.pdf", usernames)
    write_usernames_to_text("usernames.txt", usernames)


if __name__ == "__main__":
    main()
