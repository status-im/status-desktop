import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

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

        readonly property int halfWidth: (width - Style.current.padding) / 2

        StatusBaseText {
            id: titleText

            width: parent.halfWidth

            text: root.title
            wrapMode: Text.Wrap
            maximumLineCount: 2
            lineHeight: 22
            lineHeightMode: Text.FixedHeight
            font.pixelSize: Style.current.primaryTextFontSize
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
                  `font-size:${Style.current.tertiaryTextFontSize}px;">` +
                  `${qsTr("Max.")}</span> ${SQUtils.StringUtils.escapeHtml(root.feeText)}`

            visible: root.feeText !== ""
            horizontalAlignment: Text.AlignRight
            color: root.errorFee ? Theme.palette.dangerColor1 : baseColor

            font.pixelSize: Style.current.primaryTextFontSize
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
