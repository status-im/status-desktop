import QtQuick 2.14

import StatusQ.Controls 0.1

StatusInput {
    placeholderText: qsTr("Search")
    input.asset.name: "search"
    input.clearable: true
    leftPadding: 0
    rightPadding: 4
}
