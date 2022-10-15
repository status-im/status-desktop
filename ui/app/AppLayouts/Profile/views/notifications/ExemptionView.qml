import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0

import "../../stores"
import "../../controls"
import "../../panels"
import "../../popups"

Item {
    id: root

    property int contentWidth
    property NotificationsStore notificationsStore
    property var exemptionsModel

    ColumnLayout {
        Layout.preferredWidth: root.contentWidth
        Layout.preferredHeight: 400

        Loader {
            id: exemptionNotificationsModal
            active: false

            function open(item) {
                active = true
                exemptionNotificationsModal.item.item = item
                exemptionNotificationsModal.item.open()
            }
            function close() {
                active = false
            }

            sourceComponent: ExemptionNotificationsModal {
                anchors.centerIn: parent
                notificationsStore: root.notificationsStore

                onClosed: {
                    exemptionNotificationsModal.close();
                }
            }
        }

        Component {
            id: exemptionDelegateComponent
            StatusListItem {
                property string lowerCaseSearchString: searchBox.text.toLowerCase()

                width: parent.width
                height: visible ? implicitHeight : 0
                visible: lowerCaseSearchString === "" ||
                            model.itemId.toLowerCase().includes(lowerCaseSearchString) ||
                            model.name.toLowerCase().includes(lowerCaseSearchString)
                title: model.name

                subTitle: {
                    if(model.type === Constants.settingsSection.exemptions.community)
                        return qsTr("Community")
                    else if(model.type === Constants.settingsSection.exemptions.oneToOneChat)
                        return qsTr("1:1 Chat")
                    else if(model.type === Constants.settingsSection.exemptions.groupChat)
                        return qsTr("Group Chat")
                    else
                        return ""
                }

                label: {
                    if(!model.customized)
                        return ""

                    let l = ""
                    if(model.muteAllMessages)
                        l += qsTr("Muted")
                    else {
                        let nbOfChanges = 0

                        if(model.personalMentions !== Constants.settingsSection.notifications.sendAlertsValue)
                        {
                            nbOfChanges++
                            let valueText = model.personalMentions === Constants.settingsSection.notifications.turnOffValue?
                                    qsTr("Off") :
                                    qsTr("Quiet")
                            l = qsTr("Personal @ Mentions %1").arg(valueText)
                        }

                        if(model.globalMentions !== Constants.settingsSection.notifications.sendAlertsValue)
                        {
                            nbOfChanges++
                            let valueText = model.globalMentions === Constants.settingsSection.notifications.turnOffValue?
                                    qsTr("Off") :
                                    qsTr("Quiet")
                            l = qsTr("Global @ Mentions %1").arg(valueText)
                        }

                        if(model.otherMessages !== Constants.settingsSection.notifications.turnOffValue)
                        {
                            nbOfChanges++
                            let valueText = model.otherMessages === Constants.settingsSection.notifications.sendAlertsValue?
                                    qsTr("Alerts") :
                                    qsTr("Quiet")
                            l = qsTr("Other Messages %1").arg(valueText)
                        }

                        if(nbOfChanges > 1)
                            l = qsTr("Multiple Exemptions")
                    }

                    return l
                }

                ringSettings.ringSpecModel: (typeof(model.ring) === 'string' && model.ring.length > 0 ? JSON.parse(model.ring) : (model.ring || undefined))

                asset: StatusAssetSettings {
                    name: model.image
                    isImage: !!model.image && model.image !== ""
                    color: model.color

                    charactersLen: model.type === Constants.settingsSection.exemptions.oneToOneChat? 2 : 1
                    isLetterIdenticon: !model.image || model.image === ""
                    height: 40
                    width: 40
                }

                components: [
                    StatusIcon {
                        visible: model.customized
                        icon: "next"
                        color: Theme.palette.baseColor1
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                exemptionNotificationsModal.open(model)
                            }
                        }
                    },
                    StatusIcon {
                        visible: !model.customized
                        icon: "add"
                        color: Theme.palette.primaryColor1
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                exemptionNotificationsModal.open(model)
                            }
                        }
                    }]

            }
        }

        StatusBaseText {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            text: qsTr("Exemptions")
            font.pixelSize: Constants.settingsSection.subHeaderFontSize
            color: Theme.palette.directColor1
        }

        SearchBox {
            id: searchBox
            Layout.preferredWidth: root.contentWidth - 2 * Style.current.padding
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            placeholderText: qsTr("Search Communities, Group Chats and 1:1 Chats")
        }

        StatusBaseText {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            text: qsTr("Most recent")
            font.pixelSize: Constants.settingsSection.subHeaderFontSize
            color: Theme.palette.baseColor1
        }

        StatusListView {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: 400
            visible: root.exemptionsModel.count > 0
            model: root.exemptionsModel
            delegate: exemptionDelegateComponent
        }
    }
}
