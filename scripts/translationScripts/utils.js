const fs = require('fs');
const path = require("path")

const getAllFiles = function(dirPath, ext, arrayOfFiles = []) {
    const files = fs.readdirSync(dirPath)

    files.forEach(file => {
        if (fs.statSync(path.join(dirPath, file)).isDirectory()) {
            arrayOfFiles = getAllFiles(path.join(dirPath, file), ext, arrayOfFiles)
        } else if (!ext || file.endsWith(ext)) {
            arrayOfFiles.push(path.join(__dirname, dirPath, file))
        }
    })

    return arrayOfFiles
}

module.exports = {
    getAllFiles
};
