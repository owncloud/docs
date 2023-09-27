#! /usr/bin/python3

import os
import re
import requests
import subprocess
from urllib.parse import urljoin
import sys
import tempfile
import shutil

# Check if any argument is passed, if not print usage and exit
if len(sys.argv) < 2:
    print("Requires Dependencies 'sudo apt-get install wkhtmltopdf pdftk'")
    print(f"Usage: python {sys.argv[0]} <URL>")
    print(f"Example: python {sys.argv[0]} https://doc.owncloud.com/webui/next/classic_ui/")
    sys.exit()

url = sys.argv[1]
urls = []

# Creating a temporary directory
temp_directory = tempfile.mkdtemp()

while url:
    response = requests.get(url)
    body = response.text

    # Add current URL to the list
    urls.append(url)

    # Step 2: Find next URL
    next_url_match = re.search(r'<span class="next"><a href="(.*?)"', body)
    next_url = next_url_match.group(1) if next_url_match else None
    if next_url:
        url = urljoin(url, next_url)  # join the base URL with the relative URL
        print(url)
    else:
        url = None  # no next URL found, break the loop

# Step 3: Generate PDFs for each URL
pdf_files = []
for i, url in enumerate(urls):
    output_filename = os.path.join(temp_directory, f"output_{i}.pdf")
    pdf_files.append(output_filename)
    subprocess.run(["wkhtmltopdf", url, output_filename])

# Step 4: Merge all PDFs into one
output_pdf = "output.pdf"
counter = 1
while os.path.exists(output_pdf):  # check if file already exists
    # If exists, change the filename
    output_pdf = f"output({counter}).pdf"
    counter += 1

print(f"Writing {output_pdf} ...")
subprocess.run(["pdftk", *pdf_files, "cat", "output", output_pdf])

# Optionally, remove individual PDF files and the temporary directory after merging
shutil.rmtree(temp_directory)
