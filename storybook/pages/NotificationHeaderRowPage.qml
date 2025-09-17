import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.ActivityCenter.controls
import Models
import Storybook

import StatusQ.Core.Theme
import StatusQ.Components

import utils

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            NotificationHeaderRow {
                Tracer {
                    visible: baseEditor.showTracer
                }
                anchors.centerIn: parent
                width: baseEditor.cardWidth
                title: editor.titleField
                chatKey: editor.chatkeyTextField
                isContact: editor.isContactCheck
                trustIndicator: editor.isTrustedCheck ? StatusContactVerificationIcons.TrustedType.Verified :
                                                          editor.isUntTrustCheck ? StatusContactVerificationIcons.TrustedType.Untrustworthy :
                                                                                   StatusContactVerificationIcons.TrustedType.None
                titleColor: editor.changeTitleColor ? "red" : Theme.palette.directColor1
                keyColor: editor.changeKeyColor ? "green" : Theme.palette.directColor5
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 160
            logsView.logText: logs.logText
        }
    }

    ScrollView {
        id: scroll
        SplitView.minimumWidth: 350
        SplitView.preferredWidth: 350
        clip: true

        Pane {
            ColumnLayout {
                width: scroll.width

                NotificationCardBaseEditor {
                    id: baseEditor
                    Layout.rightMargin: 8
                    Layout.fillWidth: true
                }

                NotificationHeaderRowEditor {
                    id: editor
                    Layout.rightMargin: 8
                    Layout.fillWidth: true
                }
            }
        }
    }
}
// category: Activity Center
// status: good
// https://www.figma.com/design/SGyfSjxs5EbzimHDXTlj8B/Qt-Responsive---v?node-id=1786-63536&m=dev
