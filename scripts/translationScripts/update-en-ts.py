#!/usr/bin/python

import xml.etree.ElementTree as ET
import subprocess
import os

# 1) Runs lupdate on ../../ui/nim-status-client.pro
# 2) Fixups qml_base.ts: ensure each source has translation, otherwise Lokalise can't figure out base words
#
# usage: `python update-en-ts.py`


def fixupTranslations(enTsFile: str):
    tsXmlTree = ET.parse(enTsFile)

    messageNodes = tsXmlTree.findall('.//message')

    for messageNode in messageNodes:
        enString = messageNode.find('source').text
        trNode = messageNode.find('translation')
        if not trNode.text:
            trNode.text = enString  # add translation
            trNode.attrib = {}  # remove 'type="unfinished"'

    tsXmlTree.write(enTsFile)


if __name__ == "__main__":
    # full base TS file (has to come first as we're targetting the same language)
    basefile = "../../ui/i18n/qml_base.ts"
    p = subprocess.run(['lupdate', '../../ui/nim-status-client.pro', '-source-language', 'en', '-no-obsolete', '-target-language', 'en_GB', '-ts', basefile],
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True, text=True)
    print(p.stdout)
    fixupTranslations(basefile)

    # EN "translation" file, plurals only
    enfile = "../../ui/i18n/qml_en.ts"
    p = subprocess.run(['lupdate', '../../ui/nim-status-client.pro', '-source-language', 'en', '-pluralonly', '-target-language', 'en_GB', '-ts', enfile],
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True, text=True)
    print(p.stdout)
