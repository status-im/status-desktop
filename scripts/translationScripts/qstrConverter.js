const fs = require('fs');
const path = require("path")
const enTranslations = require('./status-react-translations/en.json');

const getAllFiles = function(dirPath, ext, arrayOfFiles = []) {
    const files = fs.readdirSync(dirPath)

    files.forEach(file => {
        if (fs.statSync(dirPath + "/" + file).isDirectory()) {
            arrayOfFiles = getAllFiles(dirPath + "/" + file, ext, arrayOfFiles)
        } else if (!ext || file.endsWith(ext)) {
            arrayOfFiles.push(path.join(__dirname, dirPath, "/", file))
        }
    })

    return arrayOfFiles
}

console.log('Scanning files...')
const qmlFiles = getAllFiles('../../ui', 'qml');

const translationKeys = Object.keys(enTranslations)
const translationValues = Object.values(enTranslations)

// Match all qsTr("...") functions and get the string inside
const qstrRegex = /qsTr\(["'](.*?)["']\)/g
const tabsRegex = /\n([\s]+)/
let numberOfFilesDone = 0

console.log(`Modifying ${qmlFiles.length} files...`)
qmlFiles.forEach(file => {
    let fileContent = fs.readFileSync(file).toString();

    let match, replaceableText, enTranslationIndex, lastSpace, tabSubstring, spaces, replacementId, quote;
    let modified = false;
    
    while ((match = qstrRegex.exec(fileContent)) !== null) {
        modified = true;
        replaceableText = match[1];

        enTranslationIndex = translationValues.indexOf(replaceableText)
        if (enTranslationIndex > -1) {
            replacementId = translationKeys[enTranslationIndex]
        } else {
            // We need to replace all qsTr because we can't mix qsTrId and qsTr
            replacementId = replaceableText.replace(/[^a-zA-Z\d]/g, '-').toLowerCase();
        }

        quote = match[0][5];
        // Replace the  qsTr by a qsTrId and a comment
        fileContent = fileContent.replace(`qsTr(${quote}${replaceableText}${quote})`, `qsTrId("${replacementId}")`)

        // Find the place where to put the comment
        lastSpace = fileContent.lastIndexOf('\n  ', match.index);
        tabSubstring = fileContent.substring(lastSpace, match.index);

        spaces = tabsRegex.exec(tabSubstring);
        fileContent = fileContent.substring(0, lastSpace + 1) +
        spaces[1] + `//% "${replaceableText}"` +
        fileContent.substring(lastSpace);

        // Increase the last index of the regex as we increased the size of the file and so if the next qstr is on the same line,
        //   the chances are high that the next match willl be the same word, creating an infinite loop
        qstrRegex.lastIndex += spaces[1].length + 6 + replaceableText.length
    }


    fs.writeFileSync(file, fileContent);
    numberOfFilesDone++;
    if (numberOfFilesDone % 10 === 0) {
        console.log(`\t${numberOfFilesDone}/${qmlFiles.length} completed...`)
    }
});
console.log('Allo done!')
