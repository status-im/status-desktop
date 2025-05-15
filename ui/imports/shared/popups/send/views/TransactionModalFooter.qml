import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared.panels 1.0

StatusDialogFooter {
    id: root

    property string maxFiatFees: d.emptyValue
    property string totalTimeEstimate
    property bool pending: true
    property string nextButtonText: qsTr("Next")
    property string nextButtonIconName: "password"

    signal nextButtonClicked()

    implicitHeight: 82
    spacing: Theme.halfPadding
    color: Theme.palette.baseColor3
    dropShadowEnabled: true

    QtObject {
        id: d

        readonly property string emptyValue: "..."
    }

    leftButtons: ObjectModel {
        ColumnLayout {
            Layout.leftMargin: Theme.padding
            StatusBaseText {
                color: Theme.palette.directColor5
                text: qsTr("Estimated time:")
            }
            StatusBaseText {
                id: estimatedTime
                wrapMode: Text.WordWrap
                text: root.totalTimeEstimate

                onTextChanged: {
                    if (estimatedTime.text === "" || estimatedTime.text === d.emptyValue) {
                        return
                    }
                    estimatedTimeAnimation.restart()
                }

                StatusColorAnimation {
                    id: estimatedTimeAnimation
                    target: estimatedTime
                }
            }
        }
    }

    rightButtons: ObjectModel {
        RowLayout {
            spacing: Theme.padding
            ColumnLayout {
                StatusBaseText {
                    color: Theme.palette.directColor5
                    text: qsTr("Max fees:")
                }
                StatusBaseText {
                    id: fees
                    text: maxFiatFees
                    wrapMode: Text.WordWrap

                    onTextChanged: {
                        if (fees.text === "" || fees.text === d.emptyValue) {
                            return
                        }
                        feesAnimation.restart()
                    }

                    StatusColorAnimation {
                        id: feesAnimation
                        target: fees
                    }
                }
            }
            StatusButton {
                Layout.rightMargin: Theme.padding
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
