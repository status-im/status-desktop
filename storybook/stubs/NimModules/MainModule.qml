import QtQuick 2.14

QtObject {
    id: root

    signal resolvedENS

    property var getContactDetailsAsJson: function() {
        return JSON.stringify({
            alias: "alias",
            isAdded: false
        })
    }
}
