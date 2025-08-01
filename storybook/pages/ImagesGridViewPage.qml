import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook
import StatusQ.Core.Theme

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
                font.pixelSize: Theme.fontSize20
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

    ImagesGridView {
        id: grid

        anchors.fill: parent

        clip: true
        model: imagesModel
    }
}

// category: Components
