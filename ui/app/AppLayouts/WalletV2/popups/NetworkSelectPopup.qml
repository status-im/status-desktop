import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import "../../../../imports"
import "../../../../shared"

Popup {
    id: popup
    modal: false
    width: 360
    height: 432
    closePolicy: Popup.CloseOnEscape
    property var model
    signal toggleNetwork(int chainId)

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow{
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    contentItem: ScrollView {
        id: scrollView
        contentHeight: content.height
        width: popup.width
        height: popup.height

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        Column {
            id: content
            width: popup.width
            spacing: Style.current.padding

             Repeater {
                id: chainRepeater
                model: popup.model
            
                Item {
                    width: content.width
                    height: 40
                    StyledText {
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Style.current.primaryTextFontSize
                        text: model.chainName
                    }

                    StatusCheckBox {
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.bigPadding
                        anchors.verticalCenter: parent.verticalCenter
                        checked: model.enabled
                        onCheckedChanged: {
                            if(checked !== model.enabled){
                                popup.toggleNetwork(model.chainId)
                            }
                        }
                    }
                }
            }
        }
    }
}
