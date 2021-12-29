import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    function readTextFile(path) {
        return globalUtils.readTextFile(path)
    }

    function writeTextFile(path, value) {
        globalUtils.writeTextFile(path, value)
    }
}
