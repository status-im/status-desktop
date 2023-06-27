import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0

import SortFilterProxyModel 0.2

import "../stores"

StatusMenu {
    id: root

    property AddAccountStore store

    property int itemsPerPage: 5

    signal selected(string address)

    QtObject {
        id: d

        property int currentPage: 0
        readonly property int totalPages: Math.ceil(root.store.derivedAddressModel.count / root.itemsPerPage)
    }

    SortFilterProxyModel {
        id: proxyModel
        sourceModel: root.store.derivedAddressModel
        filters: ExpressionFilter {
            expression: {
                let lowerBound = root.itemsPerPage * d.currentPage
                return model.index >= lowerBound  && model.index < lowerBound + root.itemsPerPage
            }
        }
    }

    contentItem: Column {
        width: root.width

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: Constants.addAccountPopup.itemHeight - root.topPadding

            Row{
                anchors.centerIn: parent
                spacing: Style.current.halfPadding

                StatusIcon {
                    visible: !root.store.addAccountModule.scanningForActivityIsOngoing ||
                             root.store.derivedAddressModel.loadedCount > 0
                    width: 20
                    height: 20
                    icon: "flash"
                    color: root.store.derivedAddressModel.loadedCount === 0?
                               Theme.palette.primaryColor1 : Theme.palette.successColor1
                }

                StatusLinkText {
                    visible: !root.store.addAccountModule.scanningForActivityIsOngoing
                    font.pixelSize: Constants.addAccountPopup.labelFontSize1
                    text: qsTr("Scan addresses for activity")
                    color: Theme.palette.primaryColor1
                    onClicked: {
                        root.store.startScanningForActivity()
                    }
                }

                StatusLoadingIndicator {
                    visible: root.store.addAccountModule.scanningForActivityIsOngoing &&
                             root.store.derivedAddressModel.loadedCount === 0
                }

                StatusBaseText {
                    visible: root.store.addAccountModule.scanningForActivityIsOngoing
                    color: root.store.derivedAddressModel.loadedCount === 0?
                               Theme.palette.baseColor1 : Theme.palette.successColor1
                    font.pixelSize: Constants.addAccountPopup.labelFontSize1
                    text: root.store.derivedAddressModel.loadedCount === 0?
                              qsTr("Scanning for activity...")
                            : qsTr("Activity fetched for %1 / %2 addresses").arg(root.store.derivedAddressModel.loadedCount).arg(root.store.derivedAddressModel.count)
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: Theme.palette.baseColor2
            }
        }

        Repeater {
            model: proxyModel

            Rectangle {
                objectName: "AddAccountPopup-GeneratedAddress-%1".arg(model.addressDetails.order)
                anchors.left: parent.left
                anchors.right: parent.right
                height: Constants.addAccountPopup.itemHeight
                enabled: !model.addressDetails.alreadyCreated
                radius: Style.current.halfPadding
                color: {
                    if (sensor.containsMouse) {
                        return Theme.palette.baseColor2
                    }
                    return "transparent"
                }

                GridLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Style.current.padding
                    anchors.rightMargin: Style.current.padding
                    columnSpacing: Style.current.padding
                    rowSpacing: 0

                    StatusBaseText {
                        Layout.preferredWidth: 208
                        color: model.addressDetails.alreadyCreated? Theme.palette.baseColor1 : Theme.palette.directColor1
                        font.pixelSize: Constants.addAccountPopup.labelFontSize1
                        text: StatusQUtils.Utils.elideText(model.addressDetails.address, 15, 4)
                    }

                    Row {
                        Layout.preferredWidth: 108
                        spacing: Style.current.halfPadding * 0.5

                        StatusIcon {
                            visible: model.addressDetails.loaded && model.addressDetails.hasActivity
                            width: 20
                            height: 20
                            icon: "flash"
                            color: Theme.palette.successColor1
                        }

                        StatusTextWithLoadingState {
                            width: 84
                            font.pixelSize: Constants.addAccountPopup.labelFontSize1
                            text: {
                                if (!root.store.addAccountModule.scanningForActivityIsOngoing) {
                                    return ""
                                }
                                if (!model.addressDetails.loaded) {
                                    return qsTr("loading...")
                                }
                                if (model.addressDetails.hasActivity) {
                                    return qsTr("Has activity")
                                }
                                return qsTr("No activity")
                            }
                            color: {
                                if (!root.store.addAccountModule.scanningForActivityIsOngoing || !model.addressDetails.loaded) {
                                    return "transparent"
                                }
                                if (model.addressDetails.hasActivity) {
                                    return Theme.palette.successColor1
                                }
                                return Theme.palette.warningColor1
                            }
                            loading: root.store.addAccountModule.scanningForActivityIsOngoing && !model.addressDetails.loaded
                        }
                    }

                    StatusBaseText {
                        Layout.preferredWidth: 20
                        color: Theme.palette.baseColor1
                        font.pixelSize: Constants.addAccountPopup.labelFontSize1
                        text: model.addressDetails.order
                    }

                    StatusFlatRoundButton {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        type: StatusFlatRoundButton.Type.Tertiary
                        icon.name: "external"
                        icon.width: 16
                        icon.height: 16
                        onClicked: {
                            Qt.openUrlExternally("https://etherscan.io/address/%1".arg(model.addressDetails.address))
                        }
                    }
                }

                MouseArea {
                    id: sensor
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selected(model.addressDetails.address)
                    }
                }
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: Constants.addAccountPopup.itemHeight - root.bottomPadding

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: Theme.palette.baseColor2
            }

            StatusPageIndicator {
                objectName: "AddAccountPopup-GeneratedAddressesListPageIndicatior"
                anchors.top: parent.top
                anchors.topMargin: (Constants.addAccountPopup.itemHeight - height) * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                totalPages: d.totalPages

                onCurrentIndexChanged: {
                    d.currentPage = currentIndex
                }
            }
        }
    }
}
