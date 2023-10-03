import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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

    ImagesGridView {
        id: grid

        anchors.fill: parent

        clip: true
        model: imagesModel
    }
}

// category: Components
