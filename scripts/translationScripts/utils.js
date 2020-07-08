const fs = require('fs');
const path = require("path")

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

module.exports = {
    getAllFiles
};
