import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

ColumnLayout {
    id: root

    RowLayout {
        Layout.fillWidth: true

        StatusIconTextButton {
            id: sortBtn

            property int sortOrder: -1
            statusIcon: {
                if (sortOrder == Qt.AscendingOrder) return "chevron-down"
                if (sortOrder == Qt.DescendingOrder) return "chevron-up"
                return "remove"
            }

            onClicked: {
                var st = sortOrder + 1
                sortOrder = st > 1 ? -1 : st
            }
        }

        StatusInput {
            id: searchInput

            Layout.fillWidth: true
            input.icon.name: "search"
            placeholderText: "nickname.."
        }

        StatusIconTabButton {
            id: contactBtn

            icon.name: "tiny/tiny-contact"
            identicon.icon.color: Theme.palette.primaryColor1
            onClicked: highlighted = !highlighted
        }

        StatusIconTabButton {
            id: verifiedBtn

            icon.name: "tiny/tiny-checkmark"
            identicon.icon.color: Theme.palette.primaryColor1
            onClicked: highlighted = !highlighted
        }
    }

    ListView {
        Layout.fillWidth: true
        implicitHeight: contentItem.childrenRect.height
        spacing: 4

        model: SortFilterProxyModel {
            sourceModel: d.users
            sorters: StringSorter {
                enabled: sortBtn.sortOrder !== -1
                roleName: "nick"
                sortOrder: sortBtn.sortOrder
            }
            filters: [
                ExpressionFilter {
                    expression: model.nick.startsWith(searchInput.text)
                },
                AllOf {
                    enabled: contactBtn.highlighted || verifiedBtn.highlighted
                    ValueFilter {
                        enabled: contactBtn.highlighted
                        roleName: "isContact"
                        value: true
                    }
                    ValueFilter {
                        enabled: verifiedBtn.highlighted
                        roleName: "isVerified"
                        value: true
                    }
                }
            ]
        }

        delegate: StatusMemberListItem {
            width: parent.width
            userName: model.name
            nickName: model.nick
            isVerified: model.isVerified
            isContact: model.isContact
        }
    }

    QtObject {
        id: d

        readonly property ListModel users: ListModel {
            ListElement {
                name: "Richard"
                nick: "Ricky"
                isVerified: true
                isContact: true
            }
            ListElement {
                name: "Susan"
                nick: "Sue"
                isVerified: false
                isContact: false
            }
            ListElement {
                name: "Edward"
                nick: "Ed"
                isVerified: true
                isContact: false
            }
            ListElement {
                name: "Toomas"
                nick: "Tommy"
                isVerified: false
                isContact: false
            }
            ListElement {
                name: "Elizabeth"
                nick: "Bess"
                isVerified: true
                isContact: true
            }
            ListElement {
                name: "Thomas"
                nick: "Tom"
                isVerified: false
                isContact: true
            }
            ListElement {
                name: "Fernando"
                nick: "Alonso"
                isVerified: false
                isContact: true
            }
            ListElement {
                name: "Alexander"
                nick: "Alex"
                isVerified: true
                isContact: false
            }
        }
    }
}
