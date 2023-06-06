import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

Item {
    id: root

    property alias model: listView.model
    property alias delegate: listView.delegate

    property alias suggestionsModel: suggestionsListView.model
    property alias suggestionsDelegate: suggestionsListView.delegate
    property alias suggestionsDialog: suggestionsDialog
    property size suggestionsDelegateSize: Qt.size(344, 64)

    readonly property alias label: label
    readonly property alias warningLabel: warningLabel
    readonly property alias edit: edit

    signal confirmed()
    signal rejected()

    signal enterKeyPressed()
    signal upKeyPressed()
    signal downKeyPressed()

    signal entryAccepted(var suggestionsDelegate)
    signal entryRemoved(var delegate)
    signal textPasted(string text)

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    QtObject {
        id: d

        function paste() {
            root.suggestionsDialog.forceHide = true
            edit.pasteOperation = true
            edit.paste()
            root.textPasted(edit.text)
            edit.pasteOperation = false
        }
    }

    RowLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: Style.current.padding

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Style.current.halfPadding
            color: Theme.palette.baseColor2
            radius: Style.current.radius
            RowLayout {
                anchors.fill: parent
                spacing: Style.current.halfPadding
                StatusBaseText {
                    id: label
                    Layout.leftMargin: Style.current.padding
                    Layout.alignment: Qt.AlignVCenter
                    visible: text !== ""
                    font.pixelSize: 15
                    color: Theme.palette.baseColor1
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    StatusScrollView {
                        id: scrollView

                        function positionViewAtEnd() {
                            if (scrollView.contentWidth > scrollView.width) {
                                scrollView.flickable.contentX = scrollView.contentWidth - scrollView.width
                            } else {
                                scrollView.flickable.contentX = 0
                            }
                        }

                        anchors.fill: parent
                        contentHeight: availableHeight
                        padding: 0

                        onContentWidthChanged: positionViewAtEnd()
                        onWidthChanged: positionViewAtEnd()

                        RowLayout {
                            height: scrollView.availableHeight
                            StatusListView {
                                id: listView
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                implicitWidth: contentWidth
                                orientation: ListView.Horizontal
                                spacing: Style.current.halfPadding
                                interactive: false
                            }

                            TextInput {
                                id: edit
                                property bool pasteOperation: false
                                Layout.minimumWidth: 4
                                Layout.fillHeight: true
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 15
                                color: Theme.palette.directColor1

                                selectByMouse: true
                                selectionColor: Theme.palette.primaryColor2
                                selectedTextColor: color
                                onCursorPositionChanged: {
                                    if (scrollView.contentX > cursorRectangle.x)
                                        scrollView.contentX = cursorRectangle.x;
                                    if (scrollView.contentX < ((cursorRectangle.x+Style.current.smallPadding)-scrollView.width) && ((cursorRectangle.x+Style.current.smallPadding) > scrollView.width))
                                        scrollView.contentX = (cursorRectangle.x-scrollView.width+Style.current.smallPadding);
                                }

                                cursorDelegate: StatusCursorDelegate {
                                    cursorVisible: edit.cursorVisible
                                }

                                onTextEdited: {
                                    if (suggestionsDialog.forceHide && !pasteOperation)
                                        suggestionsDialog.forceHide = false
                                }

                                Keys.onPressed: (event) => {

                                    if (event.matches(StandardKey.Paste)) {
                                        event.accepted = true
                                        d.paste()
                                        return
                                    }

                                    if (suggestionsDialog.visible) {
                                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                            root.entryAccepted(suggestionsListView.itemAtIndex(suggestionsListView.currentIndex))
                                        } else if (event.key === Qt.Key_Up) {
                                            suggestionsListView.decrementCurrentIndex()
                                        } else if (event.key === Qt.Key_Down) {
                                            suggestionsListView.incrementCurrentIndex()
                                        }
                                    } else {
                                        if (event.key === Qt.Key_Backspace && edit.text === "") {
                                            root.entryRemoved(listView.itemAtIndex(listView.count - 1))
                                        } else if (event.key === Qt.Key_Return || event.key === Qt.Enter)  {
                                            root.enterKeyPressed()
                                        } else if (event.key === Qt.Key_Escape)  {
                                            root.rejected()
                                        } else if (event.key === Qt.Key_Up) {
                                            root.upKeyPressed()
                                        } else if (event.key === Qt.Key_Down) {
                                            root.downKeyPressed()
                                        }
                                    }
                                }
                            }

                            // ensure edit cursor is visible
                            Item {
                                Layout.fillHeight: true
                                implicitWidth: 1
                            }
                        }

                        ScrollBar.horizontal: StatusScrollBar {
                            id: scrollBar
                            parent: scrollView.parent
                            anchors.top: scrollView.bottom
                            anchors.left: scrollView.left
                            anchors.right: scrollView.right
                            policy: ScrollBar.AsNeeded
                            visible: resolveVisibility(policy, scrollView.availableWidth, scrollView.contentWidth)
                        }
                    }
                }

                StatusBaseText {
                    id: warningLabel
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.rightMargin: Style.current.padding
                    visible: text !== ""
                    font.pixelSize: 10
                    color: Theme.palette.dangerColor1
                }
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: {
                    edit.forceActiveFocus()
                    mouse.accepted = false
                }
            }
        }

        StatusButton {
            objectName: "inlineSelectorConfirmButton"
            Layout.alignment: Qt.AlignVCenter
            enabled: (listView.count > 0)
            text: qsTr("Confirm")
            onClicked: root.confirmed()
        }

        StatusButton {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("Cancel")
            type: StatusBaseButton.Type.Danger
            onClicked: root.rejected()
        }
    }

    Popup {
        id: suggestionsDialog

        property bool forceHide: false

        parent: scrollView
        x: Math.min(parent.width, parent.contentWidth)
        y: parent.height + Style.current.halfPadding
        visible: edit.text !== "" && !forceHide
        padding: Style.current.halfPadding
        background: StatusDialogBackground {
            id: bg
            layer.enabled: true
            layer.effect: DropShadow {
                source: bg
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                spread: 0.2
                color: Theme.palette.dropShadow
            }
        }

        height: suggestionsListView.count ?
                    Math.min(400, suggestionsListView.count * suggestionsDelegateSize.height + 2 * padding) :
                    noResultsFoundText.height + 2 * padding
        width: suggestionsDelegateSize.width

        ColumnLayout {
            anchors.fill: parent

            StatusBaseText {
                id: noResultsFoundText

                Layout.fillWidth: true

                visible: root.suggestionsModel.count === 0
                text: qsTr("No results found")
                color: Theme.palette.baseColor1
            }

            StatusListView {
                id: suggestionsListView

                Layout.fillWidth: true
                Layout.fillHeight: true

                visible: root.suggestionsModel.count

                highlightMoveDuration: 0
                highlightMoveVelocity: -1

                verticalScrollBar {
                    visible: contentHeight > height
                    policy: ScrollBar.AlwaysOn
                }

                onVisibleChanged: currentIndex = 0
                onCountChanged: currentIndex = 0
            }
        }
    }
}
