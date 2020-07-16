# Translation scripts

These scripts are used to translate the app automatically by reusing the existing translation found in the Status-React repo: https://github.com/status-im/status-react/tree/develop/translations

## TLDR

1. Copy the translation files from https://github.com/status-im/status-react/tree/develop/translations to `/nim-status-client/scripts/translationScripts/status-react-translations`
2. `cd scripts/translationScripts`
3. Run `npm install`
4. Run `node qstrConverter.js`
5. Open another terminal and `cd ui`
6. In that second terminal, run `lupdate nim-status-client.pro`
7. Back in the first terminal, run `node xmlTranslator.js`
7. [Optional] Manually translate the remaining strings in QT Linguist
9. In the second terminal, run `lrelease -idbased i18n/*.ts` in the `ui/` directory

:tada: You're files are converted to use `qsTrId` and the translation files are updated.

## Changing strings to IDs

One major step is to change the literal strings we use in the code base to the IDs that are used in the translation JSON files.

For example, in our QML files, we would use `qsTr("Public chat")`, but in Status-React, that string in only represented as `public-chat`.

Thankfully, QML supports using string IDs instead of literral strings. The trick is to use `qsTrId` instead of `qsTr` and then use a comment to show the context/original string.

The script to do the change from `qsTr` to `qsTrId` is `qstrConverter.js`.

First, copy the translation files from https://github.com/status-im/status-react/tree/develop/translations to `/nim-status-client/scripts/translationScripts/status-react-translations`. Those are gitignored to show that we do not maintain those ourselves.

Then, run `node qstrConverter.js` in the `translationScripts/` directory.

## Updating translation files

Updating the QML translation files is then very easy, as it comes with QT directly. It will scan all files in the projects (those listed in the `SOURCE` section of the `.pro` file) and then add or modify them in the XML-like `.ts` files.

Just run `lupdate nim-status-client.pro` in the `ui/` directory.

## Run XML translator script

Most translations are already done in Status-React. To add those translations to the right `.ts` file, run `node xmlTranslator.js` in the `translationScripts/` directory. 

It will check all the TS files and get the good translation from the JSON file and set the translation as done.

Some translations will not be done, check the next section to know how to translate.

## Manually translate remaining strings

Since not all strings used in the desktop app are also used in Status-React, the remaining will need to be translated manually.

If the strings are not translated, it is not the end of the world, the English strings will be shown instead.

To do so, you can use QT Linguist to help with the process. Check here to see the Linguist docs: https://doc.qt.io/qt-5/linguist-translators.html

To open a TS file in QT Linguist, either open the software and use the `Open` feature it has, or go in the `ui/i18n` directory and run `linguist nameOfFile.ts`

## Generating binary translation files

To have the final translation files that will be used by the app, just run `lrelease -idbased i18n/*.ts` in the `ui/` directory
