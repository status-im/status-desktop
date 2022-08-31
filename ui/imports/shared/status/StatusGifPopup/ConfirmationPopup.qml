import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0
import shared.stores 1.0
import shared.controls 1.0

Popup {
    id: root

    anchors.centerIn: parent
    height: 278
    width: 291

    horizontalPadding: 6
    verticalPadding: 32

    modal: false
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    SVGImage {
        id: gifImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        source: Style.svg(`gifs-${Style.current.name}`)
    }

    StatusBaseText {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: gifImage.bottom
        anchors.topMargin: 8
        text: qsTr("Enable Tenor GIFs?")
        font.weight: Font.Medium
        font.pixelSize: Style.current.primaryTextFontSize
    }

    StatusBaseText {
        id: headline
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: title.bottom
        anchors.topMargin: 4

        text: qsTr("Once enabled, GIFs posted in the chat may share your metadata with Tenor.")
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: 13
        color: Style.current.secondaryText
    }

    StatusButton {
        id: removeBtn
        objectName: "enableGifsButton"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: qsTr("Enable")

        size: StatusBaseButton.Size.Small

        onClicked: {
            RootStore.setIsTenorWarningAccepted(true)
            RootStore.updateWhitelistedUnfurlingSites("media.tenor.com", true)
            RootStore.getTrendingsGifs()
            root.close()
        }
    }
}
