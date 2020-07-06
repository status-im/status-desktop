# Translation scripts

These scripts are used to translate the app automatically by reusing the existing translation found in the Status-React repo: https://github.com/status-im/status-react/tree/develop/translations

## TLDR

1. Copy the translation files from https://github.com/status-im/status-react/tree/develop/translations to `/nim-status-client/scripts/translationScripts/status-react-translations`
2. Run `node qstrConverter.js` in the `translationScripts/` directory
3. Run `lupdate` in the `ui/` directory

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

Just run `lupdate` in the `ui/` directory.

