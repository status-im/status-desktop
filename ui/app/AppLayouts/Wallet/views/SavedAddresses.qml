import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls.Validators

import SortFilterProxyModel

import utils
import shared.controls
import shared.stores as SharedStores
import AppLayouts.Profile.stores as ProfileStores

import "../stores"
import "../controls"

ColumnLayout {
    id: root

    property ProfileStores.ContactsStore contactsStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    property SharedStores.NetworksStore networksStore

    signal sendToAddressRequested(string address)

    QtObject {
        id: d

        function reset() {
            RootStore.lastCreatedSavedAddress = undefined
        }
    }

    SearchBox {
        id: searchBox
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.padding
        visible: RootStore.savedAddresses.count > 0
        placeholderText: qsTr("Search for name, ENS or address")

        validators: [
            StatusValidator {
                property bool isEmoji: false

                name: "check-for-no-emojis"
                validate: (value) => {
                              if (!value) {
                                  return true
                              }

                              isEmoji = Constants.regularExpressions.emoji.test(value)
                              if (isEmoji){
                                  return false
                              }

                              return Constants.regularExpressions.alphanumericalExpanded1.test(value)
                          }
                errorMessage: isEmoji?
                                  qsTr("Your search is too cool (use A-Z and 0-9, single whitespace, hyphens and underscores only)")
                                : qsTr("Your search contains invalid characters (use A-Z and 0-9, single whitespace, hyphens and underscores only)")
            }
        ]
    }

    ShapeRectangle {
        id: noSavedAddresses
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        visible: RootStore.savedAddresses.count === 0
        text: qsTr("Your saved addresses will appear here")
    }

    ShapeRectangle {
        id: emptySearchResult
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        visible: RootStore.savedAddresses.count > 0 && listView.count === 0
        text: qsTr("No saved addresses found. Check spelling or address is correct.")
    }

    StatusLoadingIndicator {
        id: loadingIndicator
        Layout.alignment: Qt.AlignHCenter
        visible: RootStore.addingSavedAddress || RootStore.deletingSavedAddress
        color: Theme.palette.directColor4
    }

    Item {
        visible: noSavedAddresses.visible || emptySearchResult.visible
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    StatusListView {
        id: listView
        objectName: "SavedAddressesView_savedAddresses"
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 8
        visible: count > 0

        model: SortFilterProxyModel {
            sourceModel: RootStore.savedAddresses
            delayed: true

            sorters: RoleSorter {
                roleName: "name"
                sortOrder: Qt.AscendingOrder
            }

            filters: ExpressionFilter {

                function spellingTolerantSearch(data, searchKeyword) {
                    const regex = new RegExp(searchKeyword.split('').join('.{0,1}'), 'i')
                    return regex.test(data)
                }

                enabled: !!searchBox.text && searchBox.valid

                expression: {
                    searchBox.text
                    let keyword = searchBox.text.trim().toUpperCase()
                    return spellingTolerantSearch(model.name, keyword) ||
                            model.address.toUpperCase().includes(keyword) ||
                            model.ens.toUpperCase().includes(keyword)
                }
            }
        }

        section.property: "name"
        section.criteria: ViewSection.FirstCharacter
        section.delegate: Item {
            height: 34
            width: children.width
            StatusBaseText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: section.toUpperCase()
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.primaryTextFontSize
            }
        }

        delegate: SavedAddressesDelegate {
            id: savedAddressDelegate
            objectName: "savedAddressView_Delegate_" + name
            name: model.name
            address: model.mixedcaseAddress
            ens: model.ens
            colorId: model.colorId
            networkConnectionStore: root.networkConnectionStore
            activeNetworks: root.networksStore.activeNetworks
            onOpenSendModal: root.sendToAddressRequested(recipient)

            states: [
                State {
                    name: "highlighted"
                    when: RootStore.lastCreatedSavedAddress ? (!RootStore.lastCreatedSavedAddress.error &&
                                                               RootStore.lastCreatedSavedAddress.address.toLowerCase() === address.toLowerCase()) : false
                    PropertyChanges { target: savedAddressDelegate; color: Theme.palette.baseColor2 }
                    StateChangeScript {
                        script: Qt.callLater(d.reset)
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "highlighted"
                    ColorAnimation {
                        target: savedAddressDelegate
                        duration: 3000
                    }
                }
            ]
        }
    }
}
