#!/usr/bin/python

import xml.etree.ElementTree as ET
import sys

def main():
    # Relative paths from project root
    base_file = "../../ui/i18n/qml_base_en.ts"
    plural_file = "../../ui/i18n/qml_en.ts"
    output_file = "../../ui/i18n/qml_base_lokalise_en.ts"

    # Parse the base TS file
    try:
        base_tree = ET.parse(base_file)
        base_root = base_tree.getroot()
    except ET.ParseError as e:
        print(f"Error parsing {base_file}: {e}", file=sys.stderr)
        sys.exit(1)

    # Parse the plural TS file
    try:
        plural_tree = ET.parse(plural_file)
        plural_root = plural_tree.getroot()
    except ET.ParseError as e:
        print(f"Error parsing {plural_file}: {e}", file=sys.stderr)
        sys.exit(1)

    # Create a dictionary for quick lookup of plural translations by source
    plural_lookup = {}
    for context in plural_root.findall('context'):
        for message in context.findall('message'):
            source = message.find('source')
            if source is not None and source.text:
                plural_lookup[source.text] = message.find('translation')

    # Process each message in the base file
    for context in base_root.findall('context'):
        for message in context.findall('message'):
            numerus = message.get('numerus')
            source = message.find('source')
            translation = message.find('translation')

            if numerus == 'yes' and source is not None and source.text in plural_lookup:
                # Copy translation from plural file
                plural_translation = plural_lookup[source.text]
                if plural_translation is not None:
                    # Clear existing translation content
                    translation.clear()
                    # Copy attributes and subelements
                    for attr, value in plural_translation.attrib.items():
                        translation.set(attr, value)
                    for child in plural_translation:
                        translation.append(child)
                    # Remove unfinished if present
                    if 'type' in translation.attrib and translation.attrib['type'] == 'unfinished':
                        del translation.attrib['type']
            else:
                # For non-numerus or unmatched, set translation to source
                if translation is not None and source is not None:
                    translation.text = source.text
                    # Remove unfinished
                    if 'type' in translation.attrib and translation.attrib['type'] == 'unfinished':
                        del translation.attrib['type']

    # Fixup the "language" attribute
    base_root.set('language', 'en')

    # Write the modified XML to output file
    try:
        base_tree.write(output_file, encoding='utf-8', xml_declaration=True)
        print(f"Successfully transformed {base_file} to {output_file}")
    except Exception as e:
        print(f"Error writing to {output_file}: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
