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

    property bool highlightFees: count === 1

    property Item footer

    states: State {
        // Setting condition on root.footer doesn't work for some configurations (macOS or specific qt version)
        // Setting when directly to true seems to be relable option because ParentChange and PropertyChanges tolerate target set to null
        // when: root.footer
        when: true

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

        readonly property int placeholderHeight: 24
    }

    contentItem: ColumnLayout {
        spacing: Style.current.padding

        StatusBaseText {
            id: placeholderText

            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(implicitHeight,
                                             d.placeholderHeight)

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

                title: model.title
                feeText: model.feeText
                errorFee: !!model.error
                highlightFee: root.highlightFees
            }
        }
    }
}
