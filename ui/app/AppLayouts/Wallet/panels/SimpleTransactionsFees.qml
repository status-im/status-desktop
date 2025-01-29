import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
    /** property to set error state in the fees component **/
    property bool error

    QtObject {
        id: d

        readonly property string loadingText: "XXXXXXXXXX"
        readonly property string emptyText: "--"
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

                text: qsTr("Est Mainnet transaction fee")
            }
            StatusTextWithLoadingState {
                id: cryptoFeesText

                objectName: "cryptoFeesText"

                Layout.fillWidth: true

                loading: root.loading
                customColor: {
                    if(!!root.cryptoFees && root.error) {
                        return  Theme.palette.dangerColor1
                    }
                    return Theme.palette.baseColor1
                }
                lineHeightMode: Text.FixedHeight
                lineHeight: 22

                text: !!root.cryptoFees ? root.cryptoFees:
                                          root.loading ? d.loadingText:
                                                         d.emptyText
            }
        }
        StatusTextWithLoadingState {
            id: fiatFeesText

            objectName: "fiatFeesText"

            Layout.alignment: Qt.AlignRight

            loading: root.loading
            customColor: {
                if(!!root.cryptoFees && root.error) {
                    return  Theme.palette.dangerColor1
                }
                return Theme.palette.baseColor1
            }
            lineHeightMode: Text.FixedHeight
            lineHeight: 22

            text: !!root.fiatFees ? root.fiatFees:
                                    root.loading ? d.loadingText:
                                                   d.emptyText
        }
    }
}
