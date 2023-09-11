"""
Tesseract provides various configuration parameters that can be used to customize the OCR process. These parameters are passed as command-line arguments to Tesseract through the --oem and --psm options or through the config parameter in pytesseract. Here are some commonly used Tesseract configuration parameters:

--oem (OCR Engine Mode): This parameter specifies the OCR engine mode to use. The available options are:

0: Original Tesseract only.
1: Neural nets LSTM only.
2: Tesseract + LSTM.
3: Default, based on what is available.
--psm (Page Segmentation Mode): This parameter defines the page layout analysis mode to use. The available options are:

0: Orientation and script detection (OSD) only.
1: Automatic page segmentation with OSD.
2: Automatic page segmentation, but no OSD or OCR.
3: Fully automatic page segmentation, but no OSD. (Default)
4: Assume a single column of text of variable sizes.
5: Assume a single uniform block of vertically aligned text.
6: Assume a single uniform block of text.
7: Treat the image as a single text line.
8: Treat the image as a single word.
9: Treat the image as a single word in a circle.
10: Treat the image as a single character.
--lang (Language): This parameter specifies the language(s) to use for OCR. Multiple languages can be specified separated by plus (+) signs. For example, --lang eng+fra for English and French.

--tessdata-dir (Tessdata Directory): This parameter sets the path to the directory containing Tesseract's language data files.

These are just a few examples of the commonly used configuration parameters in Tesseract. There are many more options available for advanced customization and fine-tuning of OCR results. You can refer to the official Tesseract documentation for a comprehensive list of configuration parameters and their descriptions: https://tesseract-ocr.github.io/tessdoc/Command-Line-Usage.html
"""

text_on_profile_image = r'--oem 3  --psm 10'
