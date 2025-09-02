#!/usr/bin/env python

import argparse
import glob
import json
import os
import re


def update_kernelspec_in_notebooks(directory, new_name):
    """
    Updates the kernelspec in all Jupyter Notebook files within the specified
    directory and its subdirectories, while preserving the original file
    formatting.

    Args:
    directory (str): The path to the directory containing .ipynb files.
    new_name (str): The new name to set in the kernelspec.
    """
    for file_path in glob.glob(f'{directory}/**/*.ipynb', recursive=True):
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                file_contents = file.read()
                notebook = json.loads(file_contents)

            if 'kernelspec' not in notebook.get('metadata', {}):
                print(f"No kernelspec found in {file_path}. Skipping file.")
                continue

            kernelspec = notebook['metadata']['kernelspec']
            kernelspec['display_name'] = f"Python [conda env:{new_name}]"
            kernelspec['name'] = f"conda-env-{new_name}-py"

            # Convert the updated kernelspec dictionary to a JSON-formatted
            # string with indentation
            updated_kernelspec = json.dumps(kernelspec, indent=4)

            # Replace the existing kernelspec section in the original file
            # contents with the updated JSON string. The regular expression
            # looks for the "kernelspec" key and replaces its entire value
            # (including nested structures), preserving the overall structure
            # and formatting of the file.
            updated_contents = re.sub(
                r'"kernelspec": *\{.*?\}',
                f'"kernelspec": {updated_kernelspec}',
                file_contents, flags=re.DOTALL
            )

            with open(file_path, 'w', encoding='utf-8') as file:
                file.write(updated_contents)

        except Exception as e:
            print(f"Error processing file {file_path}: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update the kernel name in "
                                     "Jupyter Notebook files in directory "
                                     "tree.")
    parser.add_argument("new_kernel_name", help="New kernel name to set.")
    parser.add_argument("directory_path", nargs='?', default=os.getcwd(),
                        help="Directory containing .ipynb files (default: "
                        "current directory).")

    args = parser.parse_args()

    update_kernelspec_in_notebooks(args.directory_path, args.new_kernel_name)
