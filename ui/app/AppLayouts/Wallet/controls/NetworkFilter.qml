import QtQuick 2.13
import shared 1.0
import shared.panels 1.0

import utils 1.0
import "../popups"

Item {
    id: root
    width: selectRectangle.width
    height: childrenRect.height
    signal toggleNetwork(int chainId)

    property var store
    
    Rectangle {
        id: selectRectangle
        border.width: 1
        border.color: Style.current.border
        radius: Style.current.radius
        width: text.width + Style.current.padding * 4
        height: text.height + Style.current.padding

        StyledText {
            id: text
            text: qsTr("All networks")
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Style.current.primaryTextFontSize
        }

        SVGImage {
            id: caretImg
            width: 10
            height: 6
            source: Style.svg("caret")
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }
    }

    MouseArea {
        anchors.fill: selectRectangle
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (selectPopup.opened) {
                selectPopup.close();
                return;
            }
            selectPopup.open();
        }
    }

    Grid {
        id: enabledNetworks
        columns: 2
        spacing: 2
        visible: (chainRepeater.count > 0)

        Repeater {
            id: chainRepeater
            model: store.enabledNetworks
            width: parent.width
            height: parent.height

            Rectangle {
                color: Utils.setColorAlpha(Style.current.blue, 0.1)
                width: text.width + Style.current.halfPadding
                height: text.height + Style.current.halfPadding
                radius: Style.current.radius

                StyledText {
                    id: text
                    text: model.chainName
                    color: Style.current.blue
                    font.pixelSize: Style.current.secondaryTextFontSize
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    NetworkSelectPopup {
        id: selectPopup
        x: (parent.width - width)
        y: (root.height - networkFilterPanel.height)
        model: store.allNetworks
        onToggleNetwork: {
            store.toggleNetwork(chainId)
        }
    }
}
