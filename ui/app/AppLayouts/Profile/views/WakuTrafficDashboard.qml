pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import "HttpTrafficReport.js" as Report

/*!
    Dashboard of Waku traffic, as libp2p counts it: totals, the protocol behind
    most of it, every protocol heaviest first, and the peers it went to.

    Colours follow the HTTP dashboard: sent is the danger colour, received the
    primary colour.
*/
Item {
    id: root

    //! A wakuext_getTrafficReport report, or null.
    property var stats: null

    readonly property real elapsedSeconds: Report.elapsedSeconds(stats)

    readonly property color sentColor: Theme.palette.dangerColor1
    readonly property color receivedColor: Theme.palette.primaryColor1
    readonly property var peerColors: [Theme.palette.miscColor2, Theme.palette.miscColor6,
                                       Theme.palette.miscColor3, Theme.palette.baseColor1]

    readonly property var totals: stats ? stats.totals : ({bytesSent: 0, bytesReceived: 0})
    readonly property var protocols: stats ? (stats.protocols || []) : []
    readonly property var peers: stats ? (stats.peers || []) : []
    readonly property real maxProtocolBytes: protocols.length > 0 ? Math.max(1, Report.bytesOf(protocols[0])) : 1

    //! A protocol id as a person would call it, and what it carries.
    function protocolLook(id) {
        const known = [
            ["/vac/waku/relay/", qsTr("Relay"), qsTr("messages of every chat on your shards pass through you")],
            ["/vac/waku/store", qsTr("Store"), qsTr("history fetched after start and after reconnects")],
            ["/vac/waku/filter-push/", qsTr("Filter"), qsTr("messages of your chats, pushed by a service node")],
            ["/vac/waku/filter-subscribe/", qsTr("Filter subscriptions"), qsTr("telling a service node which chats you follow")],
            ["/vac/waku/lightpush/", qsTr("Lightpush"), qsTr("your messages, handed to a service node to publish")],
            ["/vac/waku/peer-exchange/", qsTr("Peer exchange"), qsTr("asking peers for more peers")],
            ["/vac/waku/metadata/", qsTr("Metadata"), qsTr("comparing shards with a new peer")],
            ["/ipfs/id/", qsTr("Identify"), qsTr("peers telling each other what they support")],
            ["/ipfs/ping/", qsTr("Ping"), qsTr("keeping connections alive")]
        ]
        if (id === "")
            return {name: qsTr("Protocol negotiation"), about: qsTr("streams that have not agreed on a protocol yet")}
        const match = known.find(k => id.startsWith(k[0]))
        return match ? {name: match[1], about: match[2]} : {name: id, about: ""}
    }

    function formatBytes(bytes) {
        const precision = bytes >= 1024 * 1024 * 1024 ? 2 : (bytes >= 100 * 1024 * 1024 ? 0 : 1)
        return LocaleUtils.formattedDataSize(bytes, precision)
    }

    function formatRate(bytes) {
        const rate = Report.hourly(bytes, elapsedSeconds)
        return rate < 0 ? qsTr("—/h") : qsTr("%1/h").arg(formatBytes(rate))
    }

    function colored(text, color) {
        return "<font color=\"%1\">%2</font>".arg(color).arg(text)
    }

    function escaped(text) {
        return text.replace(/&/g, "&amp;").replace(/</g, "&lt;")
    }

    function sentText(bytes) {
        return colored(qsTr("↑ %1").arg(formatBytes(bytes)), sentColor)
    }

    function receivedText(bytes) {
        return colored(qsTr("↓ %1").arg(formatBytes(bytes)), receivedColor)
    }

    //! One sentence naming the heaviest protocol, its share and what it carries.
    function answerText() {
        const all = Report.bytesOf(totals)
        if (protocols.length === 0 || all <= 0)
            return qsTr("No Waku traffic yet.")
        const top = protocols[0]
        const look = protocolLook(top.protocol)
        let text = qsTr("<b>%1</b> — <b>%2</b> (%3), <b>%4%</b> of all traffic.")
                      .arg(escaped(look.name)).arg(formatBytes(Report.bytesOf(top)))
                      .arg(formatRate(Report.bytesOf(top))).arg(Math.round(100 * Report.bytesOf(top) / all))
        if (look.about)
            text += " " + qsTr("Mostly <b>%1</b>: %2.")
                            .arg(top.bytesSent >= top.bytesReceived ? colored(qsTr("upload"), sentColor)
                                                                    : colored(qsTr("download"), receivedColor))
                            .arg(look.about)
        if (protocols.length > 1)
            text += " " + qsTr("Next: <b>%1</b> %2.").arg(escaped(protocolLook(protocols[1].protocol).name))
                                                    .arg(formatBytes(Report.bytesOf(protocols[1])))
        return text
    }

    //! The peers the bar shows on their own; the rest are pooled as "other".
    function peerShares() {
        const rows = peers.map(p => ({host: p.peer, bytesSent: p.bytesSent, bytesReceived: p.bytesReceived}))
        return Report.hostShares(rows, peerColors.length - 1).map((p, i) => ({
            label: p.host || qsTr("%n other peer(s)", "", p.others), color: peerColors[i], share: p.share
        }))
    }

    component Chip: Rectangle {
        id: chip

        property alias text: chipText.text

        implicitWidth: chipText.implicitWidth + 12
        implicitHeight: chipText.implicitHeight + 4
        radius: height / 2
        color: Theme.palette.baseColor2

        StatusBaseText {
            id: chipText
            anchors.centerIn: parent
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.baseColor1
        }
    }

    component Caption: StatusBaseText {
        Layout.fillWidth: true
        font.pixelSize: Theme.tertiaryTextFontSize
        font.capitalization: Font.AllUppercase
        color: Theme.palette.baseColor1
    }

    component KpiCard: Rectangle {
        id: kpi

        property string label
        property real bytes
        property color accent
        property string role

        Layout.fillWidth: true
        implicitHeight: kpiColumn.implicitHeight + 16
        radius: Theme.radius

        ColumnLayout {
            id: kpiColumn

            anchors.fill: parent
            anchors.margins: 8
            spacing: 2

            Caption {
                text: kpi.label
            }
            StatusBaseText {
                objectName: "wakuTrafficKpiTotal:" + kpi.role
                text: root.formatBytes(kpi.bytes)
                font.pixelSize: 22
                font.bold: true
                color: kpi.accent
            }
            Chip {
                objectName: "wakuTrafficKpiRate:" + kpi.role
                text: root.formatRate(kpi.bytes)
            }
        }
    }

    StatusScrollView {
        id: overview

        objectName: "wakuTrafficOverview"
        anchors.fill: parent
        contentWidth: availableWidth
        padding: 0

        ColumnLayout {
            width: overview.availableWidth
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                KpiCard {
                    label: qsTr("↑ Sent")
                    bytes: root.totals.bytesSent
                    accent: root.sentColor
                    color: Theme.palette.dangerColor3
                    role: "bytesSent"
                }
                KpiCard {
                    label: qsTr("↓ Received")
                    bytes: root.totals.bytesReceived
                    accent: root.receivedColor
                    color: Theme.palette.primaryColor3
                    role: "bytesReceived"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: answerColumn.implicitHeight + 16
                radius: Theme.radius
                color: Theme.palette.baseColor2

                Rectangle {
                    width: 3
                    height: parent.height
                    color: root.protocols.length > 0 && root.protocols[0].bytesSent >= root.protocols[0].bytesReceived
                           ? root.sentColor : root.receivedColor
                }
                ColumnLayout {
                    id: answerColumn

                    anchors.fill: parent
                    anchors.margins: 8
                    anchors.leftMargin: 12
                    spacing: 2

                    Caption {
                        text: qsTr("Where does the traffic go?")
                    }
                    StatusBaseText {
                        objectName: "wakuTrafficAnswer"
                        Layout.fillWidth: true
                        text: root.answerText()
                        textFormat: Text.StyledText
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Caption {
                text: qsTr("Protocols")
                visible: root.protocols.length > 0
            }

            Repeater {
                model: root.protocols
                delegate: ColumnLayout {
                    id: protocolRow

                    required property var modelData
                    readonly property var look: root.protocolLook(modelData.protocol)

                    objectName: "wakuTrafficProtocolRow:" + modelData.protocol
                    Layout.fillWidth: true
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true

                        StatusBaseText {
                            objectName: "wakuTrafficProtocolName"
                            Layout.fillWidth: true
                            text: protocolRow.look.name
                            textFormat: Text.PlainText
                            font.weight: Font.Medium
                            elide: Text.ElideMiddle
                        }
                        Chip {
                            text: root.formatRate(Report.bytesOf(protocolRow.modelData))
                        }
                        StatusBaseText {
                            objectName: "wakuTrafficProtocolTotal"
                            text: root.formatBytes(Report.bytesOf(protocolRow.modelData))
                            font.bold: true
                        }
                    }
                    Rectangle {
                        id: track

                        Layout.fillWidth: true
                        implicitHeight: 8
                        radius: height / 2
                        color: Theme.palette.baseColor2
                        clip: true

                        Row {
                            height: track.height

                            Rectangle {
                                width: track.width * protocolRow.modelData.bytesSent / root.maxProtocolBytes
                                height: track.height
                                color: root.sentColor
                            }
                            Rectangle {
                                width: track.width * protocolRow.modelData.bytesReceived / root.maxProtocolBytes
                                height: track.height
                                color: root.receivedColor
                            }
                        }
                    }
                    StatusBaseText {
                        objectName: "wakuTrafficProtocolDetails"
                        Layout.fillWidth: true
                        // A known protocol shows its id here; an unknown one already has it as the name.
                        text: [root.sentText(protocolRow.modelData.bytesSent), root.receivedText(protocolRow.modelData.bytesReceived),
                               protocolRow.look.name === protocolRow.modelData.protocol ? "" : root.escaped(protocolRow.modelData.protocol)]
                              .filter(part => part !== "").join(" · ")
                        textFormat: Text.StyledText
                        font.pixelSize: Theme.tertiaryTextFontSize
                        color: Theme.palette.baseColor1
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Caption {
                Layout.topMargin: 4
                text: qsTr("Which peers")
                visible: root.peers.length > 0
            }

            Row {
                id: peerBar

                readonly property var shares: root.peerShares()

                Layout.fillWidth: true
                Layout.preferredHeight: 12
                visible: root.peers.length > 0

                Repeater {
                    model: peerBar.shares
                    delegate: Rectangle {
                        required property var modelData

                        width: peerBar.width * modelData.share
                        height: peerBar.height
                        color: modelData.color
                    }
                }
            }

            Repeater {
                model: peerBar.shares
                delegate: RowLayout {
                    id: peerRow

                    required property var modelData

                    objectName: "wakuTrafficPeerRow:" + modelData.label
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 10
                        Layout.preferredHeight: 10
                        radius: 3
                        color: peerRow.modelData.color
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        text: peerRow.modelData.label
                        font.pixelSize: Theme.additionalTextSize
                        elide: Text.ElideMiddle
                    }
                    StatusBaseText {
                        text: qsTr("%1%").arg((100 * peerRow.modelData.share).toFixed(peerRow.modelData.share < 0.1 ? 1 : 0))
                        font.pixelSize: Theme.additionalTextSize
                        font.bold: true
                    }
                }
            }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: 4
                text: qsTr("%1 sent · %2 received · bold = total since start · chip = per hour. Counted inside libp2p streams: encryption and connection overhead are not included.")
                        .arg(root.colored(qsTr("↑"), root.sentColor))
                        .arg(root.colored(qsTr("↓"), root.receivedColor))
                textFormat: Text.StyledText
                font.pixelSize: Theme.tertiaryTextFontSize
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
            }
        }
    }
}
