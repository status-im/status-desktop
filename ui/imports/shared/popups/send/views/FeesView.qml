import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.popups.send.controls 1.0

Rectangle {
    id: root

    property double gasFiatAmount
    property bool isLoading: false
    property var bestRoutes
    property var selectedAsset
    property int errorType: Constants.NoError
    property string currentCurrency

    property var formatFiat: function () {}
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}
    property var getNetworkName: function () {}

    radius: 13
    color: Theme.palette.indirectColor1
    implicitHeight: columnLayout.height + feesIcon.height

    RowLayout {
        id: feesLayout

        spacing: 10
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Style.current.padding

        StatusRoundIcon {
            id: feesIcon

            Layout.alignment: Qt.AlignTop
            radius: 8
            asset.name: "fees"
            asset.color: Theme.palette.directColor1
        }

        Column {
            id: columnLayout
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.preferredWidth: root.width - feesIcon.width - Style.current.xlPadding
            spacing: isLoading ? 4 : 0

            Item {
                width: parent.width
                height: childrenRect.height

                StatusBaseText {
                    id: text

                    anchors.left: parent.left
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Theme.palette.directColor1
                    text: qsTr("Fees")
                    wrapMode: Text.WordWrap
                }

                StatusBaseText {
                    id: totalFeesAdvanced

                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding

                    text: root.isLoading ? "..." : root.formatFiat(root.gasFiatAmount, root.currentCurrency)
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    visible: !!root.bestRoutes && root.bestRoutes !== undefined && root.bestRoutes.count > 0
                }
            }

            GasSelector {
                id: gasSelector

                width: parent.width
                currentCurrency: root.currentCurrency
                visible: root.errorType === Constants.NoError && !root.isLoading
                bestRoutes: root.bestRoutes
                selectedAsset: root.selectedAsset
                getGasEthValue: root.getGasEthValue
                getFiatValue: root.getFiatValue
                getNetworkName: root.getNetworkName
                formatFiat: root.formatFiat
            }

            GasValidator {
                id: gasValidator

                width: parent.width
                isLoading: root.isLoading
                errorType: root.errorType
            }
        }
    }
}
