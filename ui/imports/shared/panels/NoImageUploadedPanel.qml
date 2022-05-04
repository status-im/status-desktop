import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
  /brief Image icon and ulopad text hints for banner and logo
 */
Item {
    id: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    property bool showARHint: false

    ColumnLayout {
        id: mainLayout

        Image {
            id: imageImg
            source: Style.svg("images_icon")
            width: 20
            height: 18
            sourceSize.width: width || undefined
            sourceSize.height: height || undefined
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }

        StatusBaseText {
            id: uploadText
            text: qsTr("Upload")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.topMargin: 5
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            id: optimalARText
            text: qsTr("Wide aspect ratio is optimal")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            visible: root.showARHint
            Layout.topMargin: 5
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }
    }
}
