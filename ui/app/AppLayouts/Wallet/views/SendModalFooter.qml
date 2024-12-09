import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialogFooter {
    id: root

    /** property to set loading state **/
    property bool loading
    /** property to set estimated time **/
    property string estimatedTime
    /** property to set estimates fees in fiat **/
    property string estimatedFees
    /** property to set error state **/
    property bool error

    // Signal to propogate Send clicked
    signal reviewSendClicked()

    implicitHeight: 82
    spacing: Theme.bigPadding
    color: Theme.palette.baseColor3
    dropShadowEnabled: true

    QtObject {
        id: d

        readonly property string emptyText: "--"
        readonly property string loadingText: "XXXXXXXXXX"
    }

    leftButtons: ObjectModel {
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Theme.padding

            spacing: 0

            StatusBaseText {
                font.weight: Font.Medium
                color: Theme.palette.directColor5
                text: qsTr("Est time")
            }
            StatusTextWithLoadingState {
                id: estimatedTime

                font.weight: Font.Medium
                customColor: !!root.estimatedTime ? Theme.palette.directColor1:
                                                   Theme.palette.directColor5
                loading: root.loading

                text: !!root.estimatedTime ? root.estimatedTime:
                      root.loading ? d.loadingText : d.emptyText
            }
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter

            spacing: 0

            StatusBaseText {
                font.weight: Font.Medium
                color: Theme.palette.directColor5
                text: qsTr("Est fees")
            }
            StatusTextWithLoadingState {
                id: estimatedFees

                font.weight: Font.Medium
                customColor: root.error ? Theme.palette.dangerColor1:
                                          !!root.estimatedFees ?
                                              Theme.palette.directColor1:
                                              Theme.palette.directColor5
                loading: root.loading

                text: !!root.estimatedFees ? root.estimatedFees:
                      loading ? d.loadingText : d.emptyText
            }
        }
    }

    rightButtons: ObjectModel {
        StatusButton {
            objectName: "transactionModalFooterButton"

            Layout.rightMargin: Theme.padding

            disabledColor: Theme.palette.directColor8
            enabled: !!root.estimatedTime &&
                     !!root.estimatedFees &&
                     !root.loading

            text: qsTr("Review Send")

            onClicked: root.reviewSendClicked()
        }
    }
}
