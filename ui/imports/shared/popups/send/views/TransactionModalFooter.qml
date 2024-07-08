import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

StatusDialogFooter {
    id: root

    property string maxFiatFees: "..."
    property string totalTimeEstimate
    property bool pending: true
    property string nextButtonText: qsTr("Next")
    property string nextButtonIconName: "password"

    signal nextButtonClicked()

    implicitHeight: 82
    spacing: Style.current.halfPadding
    color: Theme.palette.baseColor3
    dropShadowEnabled: true

    leftButtons: ObjectModel {
        ColumnLayout {
            Layout.leftMargin: Style.current.padding
            StatusBaseText {
                color: Theme.palette.directColor5
                text: qsTr("Estimated time:")
            }
            StatusBaseText {
                wrapMode: Text.WordWrap
                text: root.totalTimeEstimate
            }
        }
    }

    rightButtons: ObjectModel {
        RowLayout {
            spacing: Style.current.padding
            ColumnLayout {
                StatusBaseText {
                    color: Theme.palette.directColor5
                    text: qsTr("Max fees:")
                }
                StatusBaseText {
                    text: maxFiatFees
                    wrapMode: Text.WordWrap
                }
            }
            StatusButton {
                Layout.rightMargin: Style.current.padding
                text: root.nextButtonText
                objectName: "transactionModalFooterButton"
                enabled: !root.pending
                loading: root.pending
                onClicked: nextButtonClicked()
                icon.name: root.nextButtonIconName
            }
        }
    }
}
