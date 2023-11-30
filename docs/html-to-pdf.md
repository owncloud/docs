# HTML to PDF

The script `bin/ownCloudDocPdf.py`, temporarily necessary until Antora is upgraded to version 3, allows users to convert a sequence of web pages to the PDF format. It navigates through pages of a manual by following a "next" link on each page and converts each page to a PDF. The PDFs are then merged into a single PDF file for further use. Note that this script has a chance to miss pages as it is based on continuous chains of "next" links compared to Antora generated pdf which accesses a full content catalogue.

## How to Use

The script requires Python to be installed and some libraries provided by the OS and is executed from the command line. It accepts a URL as an argument.

```bash
python bin/ownCloudDocPdf.py [URL]
```

## Example

```python
python bin/ownCloudDocPdf.py https://doc.owncloud.com/webui/next/classic_ui/
```

## Dependencies

- `Python (Script developed and tested with version 3.10)`
- `wkhtmltopdf`
- `pdftk`
- `requests`

## Installing Dependencies

Install the Python requests library:

```bash
python -m pip install requests
```
On Debian-based systems, install `wkhtmltopdf` and `pdftk` using:

```bash
sudo apt-get install wkhtmltopdf pdftk
```
On other systems, please refer to the documentation for `wkhtmltopdf` and `pdftk` for installation instructions.

**Output**
The script will output a PDF file named output.pdf in the current directory. If a file with that name already exists, the script will increment a number in parentheses until it finds an unused filename (like output(1).pdf, output(2).pdf, etc.).

**Notes**
The temporary PDF files generated for each page are stored under /tmp/ and are deleted after the final PDF is merged.
Ensure that you have write permissions in the directory where the script is run, as it will attempt to save the output PDF in that location.

