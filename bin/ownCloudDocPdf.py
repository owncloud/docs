#! /usr/bin/python3
#
# ownCloudDocPDF.py
#
# Generate a PDF version by traversing the web rendering.
# this is a workaround for missing PDF export in antora 2.
#
# (c) 2023 Elcin Asgarov, 2024 Jürgen Weigert
# Distribute under GPLv2 or ask.

# v0.1  2023-09-27       Initial draft
# v0.2  2024-04-24, jw   Output PDF name is derived from the given URL,
#                        EndIndex introduced, so that e.g. the admin manual does not continue into the developer manual.

import os
import re
import requests
import subprocess
from urllib.parse import urljoin
import sys
import tempfile
import shutil

next_search_pattern = r'<span class="next"><a href="(.*?)"'

# Check if any argument is passed, if not print usage and exit
if len(sys.argv) < 2:
    print(f"""
Requires Dependencies: 'sudo apt-get install wkhtmltopdf pdftk'

Usage: python {sys.argv[0]} <URL> [<EndIndex>]

Examples:
        python {sys.argv[0]} https://doc.owncloud.com/webui/next/classic_ui/
        python {sys.argv[0]} https://doc.owncloud.com/server/10.14/admin_manual 167

Starting with the given URL, a list of "next" URLs is generated, by searching for {next_search_pattern}
The list ends, when the page content does not contain a next url.
You can optionally specify an EndIndex, this limits how many URLs will be processed in total.

The resulting PDF file will be named like the given URL with https:// removed and some characters replaced.
""")
    sys.exit()

url = sys.argv[1]
endindex = 0
if len(sys.argv) > 2:
  endindex = int(sys.argv[2])
  print(f" ... will stop after {endindex} urls")
urls = []

# Creating a temporary directory
temp_directory = tempfile.mkdtemp()

# output_pdf = "output.pdf"
## convert 'https://doc.owncloud.com/server/10.14/admin_manual/'
#  into doc-owncloud-com_server_10-14_admin_manual
output_base = '_'.join(url.replace('.', '-').rstrip('/').split('/')[2:])
output_pdf = output_base + '.pdf'

counter = 1
while os.path.exists(output_pdf):  # check if file already exists
    # If exists, change the filename
    output_pdf = f"{output_base}({counter}).pdf"
    counter += 1

print(f"Output file: {output_pdf}\n")

print(f"{len(urls)+1}: {url}")
while url:
    response = requests.get(url)
    body = response.text

    # Add current URL to the list
    urls.append(url)

    if endindex and len(urls) >= endindex:
        break

    # Step 2: Find next URL
    next_url_match = re.search(r'<span class="next"><a href="(.*?)"', body)
    next_url = next_url_match.group(1) if next_url_match else None
    if next_url:
        url = urljoin(url, next_url)  # join the base URL with the relative URL
        print(f"{len(urls)+1}: {url}")
    else:
        url = None  # no next URL found, break the loop


# Step 3: Generate PDFs for each URL
pdf_files = []
for i, url in enumerate(urls):
    output_filename = os.path.join(temp_directory, f"output_{i}.pdf")
    pdf_files.append(output_filename)
    subprocess.run(["wkhtmltopdf", url, output_filename])
    print(f"{i+1}/{len(urls)}")

# Step 4: Merge all PDFs into one
print(f"Writing {output_pdf} ...")
subprocess.run(["pdftk", *pdf_files, "cat", "output", output_pdf])

# Remove individual PDF files and the temporary directory after merging
shutil.rmtree(temp_directory)
