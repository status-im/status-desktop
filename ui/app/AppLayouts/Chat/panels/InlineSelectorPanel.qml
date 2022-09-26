import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
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

    readonly property alias label: label
    readonly property alias warningLabel: warningLabel
    readonly property alias edit: edit

    signal confirmed()
    signal rejected()

    signal entryAccepted(var suggestionsDelegate)
    signal entryRemoved(var delegate)

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

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
                        anchors.fill: parent
                        padding: 0
                        onContentWidthChanged: {
                            if (scrollView.contentWidth > scrollView.width) {
                                scrollView.contentX = scrollView.contentWidth - scrollView.width
                            } else {
                                scrollView.contentX = 0
                            }
                        }

                        RowLayout {
                            height: scrollView.height
                            StatusListView {
                                id: listView
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                implicitWidth: contentWidth
                                orientation: ListView.Horizontal
                                spacing: Style.current.halfPadding
                            }

                            TextInput {
                                id: edit
                                Layout.minimumWidth: 4
                                Layout.fillHeight: true
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 15
                                color: Theme.palette.directColor1
                                cursorDelegate: Rectangle {
                                    color: Theme.palette.primaryColor1
                                    implicitWidth: 2
                                    radius: 1
                                    visible: edit.cursorVisible
                                    SequentialAnimation on visible {
                                        loops: Animation.Infinite
                                        running: edit.cursorVisible
                                        PropertyAnimation { to: false; duration: 600; }
                                        PropertyAnimation { to: true; duration: 600; }
                                    }
                                }

                                Keys.onPressed: {
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
                                            root.confirmed()
                                        } else if (event.key === Qt.Key_Escape)  {
                                            root.rejected()
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
                            visible: resolveVisibility(policy, scrollView.width, scrollView.contentWidth)
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
            Layout.alignment: Qt.AlignVCenter
            enabled: (listView.count > 0)
            text: qsTr("Confirm")
            onClicked: root.confirmed()
        }

        StatusButton {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("Reject")
            type: StatusBaseButton.Type.Danger
            onClicked: root.rejected()
        }
    }

    Popup {
        id: suggestionsDialog
        parent: edit
        x: (parent.contentWidth - Style.current.halfPadding)
        y: (parent.height + Style.current.halfPadding)
        visible: edit.text !== "" && root.suggestionsModel.count
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

        StatusListView {
            id: suggestionsListView
            anchors.fill: parent
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height
            onVisibleChanged: currentIndex = 0
        }
    }
}
