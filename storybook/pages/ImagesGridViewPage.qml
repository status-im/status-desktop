import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

Pane {
    id: root

    ListModel {
        id: imagesModel
    }

    Instantiator {
        model: 20

        delegate: Rectangle {
            parent: root

            width: 150
            height: 150

            color: 'whitesmoke'
            border.width: 1
            visible: false

            Label {
                anchors.centerIn: parent
                text: "image " + index
                font.pixelSize: 20
            }

            Image {
                id: keepUrlAlive
                visible: false
            }

            Component.onCompleted: {
                imagesModel.append({
                    imageLink: "",
                    rawLink: `raw link ${index}`
                })

                Qt.callLater(grabToImage, imageResult => {
                    keepUrlAlive.source = imageResult.url
                    imagesModel.setProperty(index, "imageLink",
                                            Qt.resolvedUrl(imageResult.url))
                })
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true

            CheckBox {
                id: selectableCheckBox

                Layout.alignment: Qt.AlignVCenter

                text: "selectable"
            }

            ToolSeparator {
                Layout.alignment: Qt.AlignVCenter
            }

            Label {
                id: selectionText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                property string selectionAsString: ""

                text: `selected indexes: [${selectionAsString}]`

                Connections {
                    target: grid.selection

                    function onSelectionChanged() {
                        const indexes = grid.selection.selectedIndexes
                        const rows = indexes.map(idx => idx.row)

                        selectionText.selectionAsString = rows.join(", ")
                    }
                }
            }

            Button {
                text: "Clear selection"

                onClicked: grid.selection.clear()
            }
        }

        ImagesGridView {
            id: grid

            Layout.fillWidth: true
            Layout.fillHeight: true

            selectable: selectableCheckBox.checked
            clip: true
            model: imagesModel
        }
    }
}
