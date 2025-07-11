import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

import utils
import shared.panels

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
