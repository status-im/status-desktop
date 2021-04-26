import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import "../../imports"
import "../../shared"

Item {
    id: root
    property string packThumb: "QmfZrHmLR5VvkXSDbArDR3TX6j4FgpDcrvNz2fHSJk1VvG"
    property string packName: "Status Cat"
    property string packAuthor: "cryptoworld1373"
    property int packNameFontSize: 15 * scaleAction.factor
    property int spacing: Style.current.padding

    height: childrenRect.height
    width: parent.width

    RoundedImage {
        id: imgThumb
        anchors.left: parent.left
        width: 40 * scaleAction.factor
        height: 40 * scaleAction.factor
        source: "https://ipfs.infura.io/ipfs/" + packThumb
    }
    
    Column {
        anchors.left: imgThumb.right
        anchors.leftMargin: root.spacing
        StyledText {
            id: txtPackName
            text: packName
            font.family: Style.current.fontBold.name
            font.weight: Font.Bold
            font.pixelSize: packNameFontSize
        }
        StyledText {
            color: Style.current.secondaryText
            text: packAuthor
            font.family: Style.current.fontRegular.name
            font.pixelSize: 15 * scaleAction.factor
        }
    }

    Separator {
        anchors.top: imgThumb.bottom
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: -Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
    }
}
