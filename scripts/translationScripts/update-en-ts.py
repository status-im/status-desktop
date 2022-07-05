import xml.etree.ElementTree as ET
import subprocess

# 1) Runs lupdate ../../ui/nim-status-client.pro -target-language en
# 2) Fixups qml_en.ts: ensure each source has translation, otherwise Lokalise can't figure out base words
#
# usage: `python update-en-ts.py`


def fixupTranslations(enTsFile: str):
    tsXmlTree = ET.parse(enTsFile)

    messageNodes = tsXmlTree.findall('.//message')

    for messageNode in messageNodes:
        enString = messageNode.find('source').text
        trNode = messageNode.find('translation')
        trNode.text = enString  # add translation
        trNode.attrib = {}  # remove 'type="unfinished"'

    tsXmlTree.write(enTsFile)


if __name__ == "__main__":
    p = subprocess.run(['lupdate', '../../ui/nim-status-client.pro', '-target-language', 'en'],
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True, text=True)

    print(p.stdout)

    fixupTranslations('../../ui/i18n/qml_en.ts')
