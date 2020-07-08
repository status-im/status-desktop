const convert = require('xml-js');
const fs = require('fs');
const {getAllFiles} = require('./utils');

console.log('Scanning TS files...');
const tsFiles = getAllFiles('../../ui/i18n', 'ts');

const options = {compact: true, spaces: 4};

tsFiles.forEach(file => {
    if (file.endsWith('base.ts')) {
        // We skip the base file
        return;
    }
    const fileContent = fs.readFileSync(file).toString();

    const json = convert.xml2js(fileContent, options);

    const doctype = json["_doctype"];
    const language = json[doctype]._attributes.language;

    let translations;
    try {
        translations = require(`./status-react-translations/${language}.json`)
    } catch (e) {
        // No translation file for the exact match, let's use the file name instead
        const fileParts = file.split('_');
        console.log('Filep', fileParts);
        let langString = fileParts[fileParts.length - 1];
        // Remove the .ts
        langString = langString.substring(0, langString.length - 3)
        try {
            translations = require(`./status-react-translations/${langString}.json`)
        } catch (e) {
            console.error(`No translation file found for ${language}`);
            return;
        }
    }

    const messages = json[doctype].context.message;

    messages.forEach(message => {
        if (!message._attributes || !message._attributes.id) {
            return;
        }
        const messageId = message._attributes.id;
        if (!translations[messageId]) {
            // Skip this message, as we have no translation
            return;
        }

        message.translation = {
            "_text": translations[messageId]
        }
    });

    const xml = convert.js2xml(json, options);

    fs.writeFileSync(file, xml);
});
