import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

Control {
    id: root

    /** property to set fees in fiat along with fiat symbol **/
    property string cryptoFees
    /** property to set fees in crypto along with crypto symbol **/
    property string fiatFees
    /** property to set loading state in the fees component **/
    property bool loading
    /** property to set error state in the fees component **/
    property bool error
    property string networkName

    QtObject {
        id: d

        readonly property string loadingText: "XXXXXXXXXX"
    }

    implicitHeight: 64

    padding: Theme.padding
    verticalPadding: 12

    background: Rectangle {
        objectName: "background"

        color: Theme.palette.indirectColor1
        radius: Theme.radius
    }

    contentItem: RowLayout {
        width: parent.width
        spacing: 12

        StatusRoundIcon {            
            objectName: "gasIcon"

            Layout.alignment: Qt.AlignTop

            radius: 8
            asset.name: "gas"
            asset.color: Theme.palette.directColor1
        }
        ColumnLayout {
            Layout.fillWidth: true

            spacing: 0

            StatusBaseText {
                objectName: "infoText"

                Layout.fillWidth: true

                lineHeightMode: Text.FixedHeight
                lineHeight: 22

                text: qsTr("Est %1 transaction fee").arg(root.networkName)
            }
            StatusTextWithLoadingState {
                id: cryptoFeesText

                objectName: "cryptoFeesText"

                Layout.fillWidth: true

                loading: root.loading || !root.cryptoFees
                customColor: root.error ? Theme.palette.dangerColor1:
                                          Theme.palette.baseColor1
                lineHeightMode: Text.FixedHeight
                lineHeight: 22

                text: !!root.cryptoFees ? root.cryptoFees:
                                          d.loadingText
            }
        }
        StatusTextWithLoadingState {
            id: fiatFeesText

            objectName: "fiatFeesText"

            Layout.alignment: Qt.AlignRight

            loading: root.loading || !root.fiatFees
            customColor: root.error ? Theme.palette.dangerColor1:
                                      Theme.palette.baseColor1
            lineHeightMode: Text.FixedHeight
            lineHeight: 22

            text: !!root.fiatFees ? root.fiatFees:
                                   d.loadingText
        }
    }
}
