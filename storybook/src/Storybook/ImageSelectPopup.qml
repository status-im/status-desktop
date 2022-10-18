import QtQuick 2.14
import QtQuick.Controls 2.14

Popup {
    id: root

    property alias model: repeater.model

    signal selected(string icon)

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true

        contentWidth: width
        contentHeight: flow.implicitHeight

        Flow {
            id: flow
            width: flickable.width

            Button {
                text: "NO IMAGE"
                onClicked: {
                    root.selected("")
                }
            }

            Repeater {
                id: repeater

                delegate: Item {
                    width: iconImage.width + 10
                    height: iconImage.height + 10

                    Rectangle {
                        anchors.fill: iconImage
                        anchors.margins: -1
                        border.color: 'gray'
                    }

                    Image {
                        id: iconImage
                        source: model.image
                        anchors.centerIn: parent
                        asynchronous: true

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            onClicked: root.selected(model.image)
                        }
                    }
                }
            }
        }
    }
}
