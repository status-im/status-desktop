import QtQuick

import StatusQ.Core.Utils

ListModel {
    id: root

    Component.onCompleted: {
        const words = StringUtils.readTextFile(":/imports/shared/stores/english.txt").split(/\r?\n|\r/)
        for (var i = 0; i < words.length; i++) {
            let word = words[i]
            if (word !== "") {
                append({"seedWord": word})
            }
        }
    }
}
