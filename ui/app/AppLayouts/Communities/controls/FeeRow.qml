import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

import utils

Control {
    id: root

    property string title
    property string feeText

    property bool highlightFee: false
    property bool errorFee: false

    background: null

    contentItem: Item {
        implicitHeight: Math.max(titleText.implicitHeight,
                                 feeText.implicitHeight)

        readonly property int halfWidth: (width - Theme.padding) / 2

        StatusBaseText {
            id: titleText

            width: parent.halfWidth

            text: root.title
            wrapMode: Text.Wrap
            maximumLineCount: 2
            lineHeight: 22
            lineHeightMode: Text.FixedHeight
            font.pixelSize: Theme.primaryTextFontSize
            elide: Text.ElideRight
        }

        StatusBaseText {
            id: feeText

            readonly property color baseColor: root.highlightFee
                                               ? Theme.palette.directColor1
                                               : Theme.palette.baseColor1

            width: parent.halfWidth
            anchors.right: parent.right

            textFormat: Text.RichText
            text: `<span style="color:${baseColor};` +
                  `font-size:${Theme.tertiaryTextFontSize}px;">` +
                  `${qsTr("Max.")}</span> ${SQUtils.StringUtils.escapeHtml(root.feeText)}`

            visible: root.feeText !== ""
            horizontalAlignment: Text.AlignRight
            color: root.errorFee ? Theme.palette.dangerColor1 : baseColor

            font.pixelSize: Theme.primaryTextFontSize
            wrapMode: Text.Wrap
            maximumLineCount: 2

            // Setting text format to Text.RichText behaves similarly as
            // as adding vapid onLineLaidOut handler described in
            // https://bugreports.qt.io/browse/QTBUG-62057
            // lineHeight: 22
            // lineHeightMode: Text.FixedHeight
        }

        LoadingComponent {
            visible: root.feeText === ""

            anchors.right: parent.right
            anchors.verticalCenter: feeText.verticalCenter
            width: 160
            height: 11
        }
    }
}
