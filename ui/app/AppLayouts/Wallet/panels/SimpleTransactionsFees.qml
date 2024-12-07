import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Control {
    id: root

    /** property to set fees in fiat along with fiat symbol **/
    property string cryptoFees
    /** property to set fees in crypto along with crypto symbol **/
    property string fiatFees
    /** property to set loading state in the fees component **/
    property bool loading

    QtObject {
        id: d

        readonly property string loadingText: "----------"
    }

    implicitHeight: 64

    padding: Theme.padding
    topPadding: 12
    bottomPadding: 12

    background: Rectangle {
        color: Theme.palette.indirectColor1
        radius: 8
    }

    contentItem: RowLayout {
        width: parent.width
        spacing: 12

        StatusRoundIcon {
            Layout.alignment: Qt.AlignTop

            radius: 8
            asset.name: "gas"
            asset.color: Theme.palette.directColor1
        }
        ColumnLayout {
            Layout.fillWidth: true

            spacing: 0

            StatusBaseText {
                Layout.fillWidth: true

                lineHeightMode: Text.FixedHeight
                lineHeight: 22

                text: qsTr("Est Mainnet transaction fee")
            }
            StatusTextWithLoadingState {
                id: cryptoFeesText

                Layout.fillWidth: true

                loading: root.loading
                customColor: Theme.palette.baseColor1
                lineHeightMode: Text.FixedHeight
                lineHeight: 22

                text: !!root.cryptoFees ? root.cryptoFees:
                                          d.loadingText
            }
        }
        StatusTextWithLoadingState {
            id: fiatFeesText

            Layout.alignment: Qt.AlignRight

            loading: root.loading
            customColor: Theme.palette.baseColor1
            lineHeightMode: Text.FixedHeight
            lineHeight: 22

            text: !!root.fiatFees ? root.fiatFees:
                                   d.loadingText
        }
    }
}
