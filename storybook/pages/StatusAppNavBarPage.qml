import QtQuick
import QtQuick.Controls

import StatusQ.Layout
import StatusQ.Controls
import StatusQ.Core.Theme

SplitView {
    orientation: Qt.Vertical

    StatusSectionLayout {
        navBar: StatusAppNavBar {
            anchors.fill: parent
            thirdpartyServicesDisabled: privacyModelCtrl.checked
            regularItemsModel: ListModel {
                ListElement {
                    sectionId: "mainApp"
                    sectionType: 100
                    name: "API Documentation"
                    active: true
                    image: ""
                    icon: "edit"
                    color: ""
                    hasNotification: false
                    notificationsCount: 0
                }
                ListElement {
                    sectionId: "examples"
                    sectionType: 101
                    name: "Examples"
                    active: false
                    image: ""
                    icon: "show"
                    color: ""
                    hasNotification: false
                    notificationsCount: 0
                }
                ListElement {
                    sectionId: "demoApp"
                    sectionType: 102
                    name: "Demo Application"
                    active: false
                    image: ""
                    icon: "status"
                    color: ""
                    hasNotification: false
                    notificationsCount: 0
                }
                ListElement {
                    sectionId: "qrScanner"
                    sectionType: 103
                    name: "QR Scanner"
                    active: false
                    image: ""
                    icon: "qr-scan"
                    color: ""
                    hasNotification: false
                    notificationsCount: 0
                }
            }
            regularItemDelegate: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
            }
            delegateHeight: 40
        }

        centerPanel: Rectangle {
            color: Theme.palette.statusAppNavBar.backgroundColor
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: "Dummy center Item"
            }
        }
    }

    Item {
        SplitView.preferredWidth: 300
        SplitView.preferredHeight: childrenRect.height

        CheckBox {
            id: privacyModelCtrl
            text: "Enable Privacy Mode"
            checked: false
        }
    }
}

// category: Panels
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=26301-22122&m=dev
