import QtQuick 2.13

import utils 1.0
import "."

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

StatusInput {
    id: searchBox
    input.placeholderText: qsTr("Search")
    input.icon.name: "search"
    input.clearable: true
    leftPadding: 0
    rightPadding: 0
}
