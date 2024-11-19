import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

StatusTextField {
    id: root

    required property bool valid
    required property var seedSuggestions // [{seedWord:string}, ...]

    placeholderText: qsTr("Enter word")

    leftPadding: Theme.padding
    rightPadding: Theme.padding + rightIcon.width + spacing
    topPadding: Theme.smallPadding
    bottomPadding: Theme.smallPadding

    background: Rectangle {
        radius: Theme.radius
        color: d.isEmpty ? Theme.palette.baseColor2 : root.valid ? Theme.palette.successColor2 : Theme.palette.dangerColor3
        border.width: 1
        border.color: {
            if (d.isEmpty)
                return Theme.palette.primaryColor1
            if (root.valid)
                return Theme.palette.successColor3
            return Theme.palette.dangerColor2
        }
    }

    QtObject {
        id: d
        readonly property int delegateHeight: 33
        readonly property bool isEmpty: root.text === ""
    }

    Keys.onPressed: {
        switch (event.key) {
            case Qt.Key_Tab:
            case Qt.Key_Return:
            case Qt.Key_Enter: {
                if (filteredModel.count > 0) {
                    event.accepted = true
                    root.text = filteredModel.get(suggestionsList.currentIndex).seedWord
                    root.accepted()
                    return
                }
                break
            }
            case Qt.Key_Space: {
                event.accepted = !event.text.match(/^[a-zA-Z]$/)
                break
            }
        }
    }
    Keys.forwardTo: [suggestionsList]

    StatusDropdown {
        x: 0
        y: parent.height + 4
        width: parent.width
        contentHeight: ((suggestionsList.count <= 5) ? suggestionsList.count : 5) * d.delegateHeight // max 5 delegates
        visible: filteredModel.count > 0 && root.cursorVisible && !d.isEmpty && !root.valid
        verticalPadding: Theme.halfPadding
        horizontalPadding: 0
        contentItem: StatusListView {
            id: suggestionsList
            currentIndex: 0
            model: SortFilterProxyModel {
                id: filteredModel
                sourceModel: root.seedSuggestions
                filters: RegExpFilter {
                    pattern: `^${root.text}`
                    caseSensitivity: Qt.CaseInsensitive
                }
                sorters: StringSorter {
                    roleName: "seedWord"
                }
            }
            delegate: StatusItemDelegate {
                width: ListView.view.width
                height: d.delegateHeight
                text: model.seedWord
                font.pixelSize: Theme.additionalTextSize
                highlightColor: Theme.palette.primaryColor1
                highlighted: hovered || index === suggestionsList.currentIndex
                onClicked: {
                    root.text = text
                    root.accepted()
                }
            }
            onCountChanged: currentIndex = 0
        }
    }

    StatusIcon {
        id: rightIcon
        width: 20
        height: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        visible: !d.isEmpty
        icon: root.valid ? "checkmark-circle" : root.activeFocus ? "clear" : "warning"
        color: root.valid ? Theme.palette.successColor1 :
                            root.activeFocus ? Theme.palette.directColor9 : Theme.palette.dangerColor1

        HoverHandler {
            id: hhandler
            cursorShape: hovered ? Qt.PointingHandCursor : undefined
        }
        TapHandler {
            enabled: rightIcon.icon === "clear"
            onSingleTapped: root.clear()
        }
        StatusToolTip {
            text: root.valid ? qsTr("Correct word") : root.activeFocus ? qsTr("Clear") : qsTr("Wrong word")
            visible: hhandler.hovered && rightIcon.visible
        }
    }
}
