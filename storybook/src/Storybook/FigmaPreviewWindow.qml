import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

ApplicationWindow {
    id: root

    width: 1024
    height: 768
    visible: true

    property var model

    signal removeLinksRequested(var indexes)
    signal appendLinksRequested(var links)

    readonly property var urlRegex:
        /^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/


    SwipeView {
        id: topSwipeView

        anchors.fill: parent

        orientation: Qt.Vertical
        interactive: false

        Page {
            ImagesGridView {
                id: grid

                anchors.fill: parent

                clip: true
                model: root.model

                onClicked: {
                    imagesSwipeView.setCurrentIndex(index)
                    topSwipeView.incrementCurrentIndex()
                }
            }

            footer: ToolBar {
                RowLayout {
                    anchors.fill: parent

                    Button {
                        id: removeButton

                        readonly property int selectionCount:
                            grid.selection.selectedIndexes.length

                        text: "Remove selected"
                              + (enabled ? ` (${selectionCount})` : "")
                        enabled: grid.selection.hasSelection

                        onClicked: removeConfirmDialog.open()
                    }

                    ToolSeparator {}

                    Button {
                        text: "Add new links"

                        onClicked: addNewLinksDialog.open()
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Item {
            SwipeView {
                id: imagesSwipeView

                anchors.fill: parent
                currentIndex: imageNavigationLayout.currentIndex

                Repeater {
                    id: repeater

                    model: root.model

                    FlickableImage {
                        source: model.imageLink
                    }
                }
            }

            ImagesNavigationLayout {
                id: imageNavigationLayout

                anchors.bottom: imagesSwipeView.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                count: imagesSwipeView.count
                currentIndex: imagesSwipeView.currentIndex

                onUp: topSwipeView.decrementCurrentIndex()
                onLeft: imagesSwipeView.decrementCurrentIndex()
                onRight: imagesSwipeView.incrementCurrentIndex()
            }
        }
    }

    Dialog {
        id: removeConfirmDialog

        readonly property var selected: grid.selection.selectedIndexes

        anchors.centerIn: Overlay.overlay

        title: "Links removal"
        standardButtons: Dialog.Ok | Dialog.Cancel

        Label {
            text: "Are you sure that you want to remove "
                  + removeButton.selectionCount + " link(s)?"
        }

        onAccepted: root.removeLinksRequested(selected.map(idx => idx.row))
        onSelectedChanged: close()
    }

    Dialog {
        id: addNewLinksDialog

        anchors.centerIn: Overlay.overlay

        title: "Add new Figma links"
        standardButtons: Dialog.Save | Dialog.Cancel

        width: parent.width * 0.8
        height: parent.height * 0.4

        GroupBox {
            anchors.fill: parent

            title: "Figma links, 1 per line"

            ScrollView {
                id: scrollView

                anchors.fill: parent
                clip: true

                contentHeight: linksTextEdit.implicitHeight
                contentWidth: linksTextEdit.implicitWidth

                TextEdit {
                    id: linksTextEdit

                    property var links: []

                    width: scrollView.width
                    height: scrollView.height

                    font.pixelSize: 13
                    selectByMouse: true

                    onTextChanged: {
                        const allLines = text.split("\n")
                        const nonEmptyLines = allLines.filter(
                                                line => line.trim().length > 0)
                        const trimmed = nonEmptyLines.map(line => line.trim())

                        links = trimmed.every(line => root.urlRegex.test(line))
                                ? trimmed : []
                    }
                }
            }
        }

        onClosed: Qt.callLater(linksTextEdit.clear)
        onAccepted: root.appendLinksRequested(linksTextEdit.links)

        Component.onCompleted: {
            standardButton(Dialog.Save).enabled
                    = Qt.binding(() => linksTextEdit.links.length > 0)
        }
    }
}
