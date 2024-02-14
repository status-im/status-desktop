import QtQuick 2.13

import StatusQ.Core.Utils 0.1

ListModel {
    id: root

    Component.onCompleted: {
        const words = StringUtils.readTextFile(":/imports/shared/stores/english.txt").split(/\r?\n|\r/);
        for (var i = 0; i < words.length; i++) {
            let word = words[i]
            if (word !== "") {
                insert(count, {"seedWord": word});
            }
        }
    }
}
