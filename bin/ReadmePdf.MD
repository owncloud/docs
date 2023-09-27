# HTML to PDF

This script allows users to convert a sequence of web pages to PDF format. 
It navigates through pages by following a "next" link on each page and 
converts each page to a PDF. The PDFs are then merged into a single PDF 
file.

## How to Use

The script is executed from the command line. It accepts a 
URL as an argument.

```bash
python script_name.py [URL]
```

## Example

```python
python script_name.py https://doc.owncloud.com/webui/next/classic_ui/
```

## Dependencies

`Python (developed and tested with version 3.10)`

`wkhtmltopdf`

`pdftk`

`requests`

## Installing Dependencies

Install the Python requests library:

```bash
pip install requests
```
On Debian-based systems, install `wkhtmltopdf` and `pdftk` using:

```bash
sudo apt-get install wkhtmltopdf pdftk
```
On other systems, please refer to the documentation for `wkhtmltopdf` and 
`pdftk` for installation instructions.

Output
The script will output a PDF file named output.pdf in the current 
directory. If a file with that name already exists, the script will 
increment a number in parentheses until it finds an unused filename (like 
output(1).pdf, output(2).pdf, etc.).

Notes
The temporary PDF files generated for each page are stored under /tmp/ 
and are deleted after the final PDF is merged.
Ensure that you have write permissions in the directory where the script 
is run, as it will attempt to save the output PDF in that location.
