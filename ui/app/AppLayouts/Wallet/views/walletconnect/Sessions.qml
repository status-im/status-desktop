import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

ListView {
    id: root

    signal disconnect(string topic)
    signal ping(string topic)

    spacing: 48

    delegate: Item {

        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight

        ListModel {
            id: namespacesListModel
        }

        Component.onCompleted: {
            for (var key of Object.keys(model.namespaces)) {
                let namespace = model.namespaces[key]

                let obj = {
                    "eip": "",
                    "chain": "",
                    "methods": namespace.methods.join(", "),
                    "events": namespace.events.join(", ")
                }

                if (namespace.chains.length > 0) {
                    let data = namespace.chains[0].split(":")
                    if (data.length === 2) {
                        obj["eip"] = data[0]
                        obj["chain"] = data[1]
                    }
                }

                namespacesListModel.append(obj)
            }
        }

        ColumnLayout {
            id: delegateLayout
            width: root.width

            spacing: 8

            StatusIcon {
                icon: model.peer.metadata.icons.length > 0? model.peer.metadata.icons[0] : ""
                visible: !!icon
            }

            StatusBaseText {
                text: `Pairing topic:${SQUtils.Utils.elideText(model.pairingTopic, 6, 6)}\n${model.peer.metadata.name}\n${model.peer.metadata.url}`
            }

            StatusBaseText {
                text: `Session topic:${SQUtils.Utils.elideText(model.topic, 6, 6)}\nExpire:${new Date(model.expiry * 1000).toLocaleString()}`
            }

            Rectangle {
                color: "transparent"
                border.color: "grey"
                border.width: 1

                Layout.fillWidth: true
                Layout.preferredHeight: allNamespaces.implicitHeight

                ColumnLayout {
                    id: allNamespaces

                    Repeater {
                        model: namespacesListModel

                        delegate: Rectangle {
                            id: namespaceDelegateRoot

                            property bool expanded: false

                            color: "transparent"
                            border.color: "grey"
                            border.width: 1

                            Layout.fillWidth: true
                            Layout.preferredHeight: namespace.implicitHeight

                            ColumnLayout {
                                id: namespace

                                spacing: 8

                                RowLayout {
                                    StatusBaseText {
                                        text: `Review ${model.eip} permissions`
                                    }

                                    StatusIcon {
                                        icon: namespaceDelegateRoot.expanded? "chevron-up" : "chevron-down"

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true

                                            onClicked: {
                                                namespaceDelegateRoot.expanded = !namespaceDelegateRoot.expanded
                                            }
                                        }
                                    }
                                }

                                StatusBaseText {
                                    Layout.fillWidth: true
                                    visible: namespaceDelegateRoot.expanded
                                    text: `Chain ${model.chain}`
                                }

                                StatusBaseText {
                                    Layout.fillWidth: true
                                    visible: namespaceDelegateRoot.expanded
                                    text: `Methods: ${model.methods}\nEvents: ${model.events}`
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                StatusButton {
                    text: "Disconnect"

                    onClicked: {
                        root.disconnect(model.topic)
                    }
                }

                StatusButton {
                    text: "Ping"

                    onClicked: {
                        root.ping(model.topic)
                    }
                }
            }
        }
    }
}
