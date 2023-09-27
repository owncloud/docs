import os
import re
import requests
import subprocess
from urllib.parse import urljoin
import sys

# Default URL
default_url = "https://doc.owncloud.com/webui/next/classic_ui/"

# Check if any argument is passed, if not use default URL
url = sys.argv[1] if len(sys.argv) > 1 else default_url
urls = []

# Creating a temporary subdirectory in the /tmp folder
temp_directory = "/tmp/tmp/"
os.makedirs(temp_directory, exist_ok=True)

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

subprocess.run(["pdftk", *pdf_files, "cat", "output", output_pdf])

# Optionally, remove individual PDF files after merging
for pdf_file in pdf_files:
    os.remove(pdf_file)
