import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.controls 1.0
import utils 1.0


Control {
    id: root

    // expected roles:
    //
    // title (string) - e.g. ""Airdropping 2 on Optimism"
    // feeText (string) - e.g. "0.0015 ($75.54)
    // error (bool), optional
    property alias model: repeater.model
    readonly property alias count: repeater.count

    property alias placeholderText: placeholderText.text

    property Item footer

    states: State {
        when: root.footer

        ParentChange {
            target: root.footer
            parent: contentItem
        }

        PropertyChanges {
            target: root.footer
            Layout.fillWidth: true
            Layout.topMargin: -Style.current.padding
        }
    }

    QtObject {
        id: d

        readonly property int delegateHeight: 28
    }

    contentItem: ColumnLayout {
        spacing: Style.current.padding

        StatusBaseText {
            id: placeholderText

            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(implicitHeight, d.delegateHeight)

            visible: repeater.count === 0

            font.pixelSize: Style.current.primaryTextFontSize
            wrapMode: Text.Wrap
            color: Theme.palette.baseColor1
            verticalAlignment: Text.AlignVCenter
        }

        Repeater {
            id: repeater

            FeeRow {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(implicitHeight,
                                                 d.delegateHeight)

                title: model.title
                feeText: model.feeText
                errorFee: !!model.error
                highlightFee: repeater.count === 1
            }
        }
    }
}
