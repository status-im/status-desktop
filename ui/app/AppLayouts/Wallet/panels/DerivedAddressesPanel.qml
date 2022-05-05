import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import utils 1.0

import "../stores"

Item {
    id: derivedAddresses

    property string pathSubFix: ""
    function reset() {
        RootStore.resetDerivedAddressModel()
        _internal.nextSelectableAddressIndex = 0
        selectedDerivedAddress.pathSubFix = 0
        selectedDerivedAddress.title = "---"
        selectedDerivedAddress.subTitle = qsTr("No activity")
    }

    QtObject {
        id: _internal
        property int pageSize: 6
        property int noOfPages: Math.ceil(RootStore.derivedAddressesList.count/pageSize)
        property int lastPageSize: RootStore.derivedAddressesList.count - ((noOfPages -1) * pageSize)
        property bool isLastPage: stackLayout.currentIndex == (noOfPages - 1)
        property int nextSelectableAddressIndex: RootStore.getNextSelectableDerivedAddressIndex()

        onNextSelectableAddressIndexChanged: {
            stackLayout.currentIndex = nextSelectableAddressIndex/_internal.pageSize
            if(nextSelectableAddressIndex >= 0 && nextSelectableAddressIndex < RootStore.derivedAddressesList.count) {
                selectedDerivedAddress.title = RootStore.getDerivedAddressData(nextSelectableAddressIndex)
                selectedDerivedAddress.hasActivity = RootStore.getDerivedAddressHasActivityData(nextSelectableAddressIndex)
                selectedDerivedAddress.subTitle = RootStore.getDerivedAddressHasActivityData(nextSelectableAddressIndex) ? qsTr("Has Activity"): qsTr("No Activity")
                selectedDerivedAddress.enabled = !RootStore.getDerivedAddressAlreadyCreatedData(nextSelectableAddressIndex)
                selectedDerivedAddress.pathSubFix = nextSelectableAddressIndex
            }
        }

        // dimensions
        property int popupWidth: 359
        property int maxAddressWidth: 102
    }

    Connections {
        target: RootStore.derivedAddressesList
        onModelReset: {
            _internal.pageSize = 0
            _internal.pageSize = 6
            _internal.nextSelectableAddressIndex = -1
            _internal.nextSelectableAddressIndex = RootStore.getNextSelectableDerivedAddressIndex()
        }
    }

    ColumnLayout {
        id: layout
        width: parent.width
        spacing: 7
        StatusBaseText {
            id: inputLabel
            width: parent.width
            text: qsTr("Account")
            font.pixelSize: 15
            color: selectedDerivedAddress.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
        }
        StatusListItem {
            id: selectedDerivedAddress
            property int pathSubFix: 0
            property bool hasActivity: false
            implicitWidth: parent.width
            color: "transparent"
            border.width: 1
            border.color: Theme.palette.baseColor2
            title: "---"
            subTitle: selectedDerivedAddress.hasActivity ? qsTr("Has Activity"): qsTr("No Activity")
            statusListItemSubTitle.color: selectedDerivedAddress.hasActivity ?  Theme.palette.primaryColor1 : Theme.palette.baseColor1
            statusListItemTitle.wrapMode: Text.NoWrap
            statusListItemTitle.width: _internal.maxAddressWidth
            statusListItemTitle.elide: Qt.ElideMiddle
            statusListItemTitle.anchors.left: undefined
            statusListItemTitle.anchors.right: undefined
            components: [
                StatusIcon {
                    width: 24
                    height: 24
                    icon: "chevron-down"
                    color: Theme.palette.baseColor1
                }
            ]
            onClicked: derivedAddressPopup.popup(derivedAddresses.x - layout.width - Style.current.bigPadding , derivedAddresses.y + layout.height + 8)
            enabled: RootStore.derivedAddressesList.count > 0
            Component.onCompleted: derivedAddresses.pathSubFix = Qt.binding(function() { return pathSubFix})
        }
    }

    StatusPopupMenu {
        id: derivedAddressPopup
        width: _internal.popupWidth
        contentItem: Column {
            StackLayout {
                id: stackLayout
                Layout.fillWidth:true
                Layout.fillHeight: true
                Repeater {
                    id: pageModel
                    model: _internal.noOfPages
                    delegate: Page {
                        id: page
                        contentItem: ColumnLayout {
                            Repeater {
                                id: repeater
                                model: _internal.isLastPage ? _internal.lastPageSize : _internal.pageSize
                                delegate: StatusListItem {
                                    id: element
                                    property int actualIndex: index + (stackLayout.currentIndex* _internal.pageSize)
                                    property bool hasActivity: RootStore.getDerivedAddressHasActivityData(actualIndex)
                                    implicitWidth: derivedAddressPopup.width
                                    statusListItemTitle.wrapMode: Text.NoWrap
                                    statusListItemTitle.width: _internal.maxAddressWidth
                                    statusListItemTitle.elide: Qt.ElideMiddle
                                    statusListItemTitle.anchors.left: undefined
                                    statusListItemTitle.anchors.right: undefined
                                    title: RootStore.getDerivedAddressData(actualIndex)
                                    subTitle: element.hasActivity ? qsTr("Has Activity"): qsTr("No Activity")
                                    statusListItemSubTitle.color: element.hasActivity ?  Theme.palette.primaryColor1 : Theme.palette.baseColor1
                                    enabled: !RootStore.getDerivedAddressAlreadyCreatedData(actualIndex)
                                    components: [
                                        StatusBaseText {
                                            text: element.actualIndex
                                            font.pixelSize: 15
                                            color: Theme.palette.baseColor1
                                        },
                                        Rectangle {
                                            radius: width/2
                                            height: 5
                                            width: 5
                                            color: Theme.palette.primaryColor1
                                            visible: element.hasActivity
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    ]
                                    onClicked: {
                                        selectedDerivedAddress.title = title
                                        selectedDerivedAddress.subTitle = subTitle
                                        selectedDerivedAddress.pathSubFix = actualIndex
                                        selectedDerivedAddress.hasActivity = element.hasActivity
                                        derivedAddressPopup.close()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            PageIndicator {
                id: pageIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                interactive: true
                currentIndex: stackLayout.currentIndex
                count: stackLayout.count
                onCurrentIndexChanged: stackLayout.currentIndex = currentIndex
            }
        }
    }
}



