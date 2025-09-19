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

        ColumnLayout {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            // --- Example 1: Text only ---
            NotificationContentBlock {
                Layout.alignment: Qt.AlignHCenter
                Tracer {
                    visible: baseEditor.showTracer
                }
                Layout.preferredWidth: baseEditor.cardWidth
                preImageSource: premImageVisible.checked ? "https://picsum.photos/seed/colors/600/600" : ""
                contentHtml: textField.text
                maxLines: 3 // TODO: It does nothing
                attachments: [
                    "https://picsum.photos/320/240?3",
                    "https://picsum.photos/320/240?4",
                    "https://picsum.photos/320/240?5",
                    "https://picsum.photos/320/240?6",
                    "https://picsum.photos/320/240?7"
                ]

                onLinkActivated: href => logs.logEvent("NotificationContentBlock::onLinkActivated --> Link clicked: " + href)
            }

            // --- Example 2: Hero banner above text ---
            /*NotificationContentBlock {
                Tracer {
                    visible: editor.showTracer
                }
                Layout.preferredWidth: editor.cardWidth
                heroSource: "https://picsum.photos/720/404?rnd=1"
                contentHtml: "hey, <a href='status:user:robert'>@robertf.ox.eth</a>, same text here…"
                maxLines: 3
                onHeroClicked: console.log("Hero clicked")
            }

            // --- Example 3: Single image with badge ---
            NotificationContentBlock {
                Tracer {
                    visible: editor.showTracer
                }
                Layout.preferredWidth: editor.cardWidth
                contentHtml: "hey, <a href='status:user:robert'>@robertf.ox.eth</a>, same text here…"
                attachments: [ "https://picsum.photos/320/240?2" ]
                showSingleBadge: true
                singleBadgeText: "M"
                maxLines: 3
                onAttachmentClicked: (idx, src) => console.log("Single thumb clicked", idx, src)
            }

            // --- Example 4: Gallery with overflow (5+) ---
            NotificationContentBlock {
                Tracer {
                    visible: editor.showTracer
                }
                Layout.preferredWidth: editor.cardWidth
                contentHtml: "hey, <a href='status:user:robert'>@robertf.ox.eth</a>, same text here…"
                attachments: [
                    "https://picsum.photos/320/240?3",
                    "https://picsum.photos/320/240?4",
                    "https://picsum.photos/320/240?5",
                    "https://picsum.photos/320/240?6",
                    "https://picsum.photos/320/240?7"
                ]
                maxLines: 3
                onAttachmentClicked: (idx, src) => console.log("Gallery clicked", idx, src)
            }

            // --- Example 5: 4 lines clamp ---
            NotificationContentBlock {
                Tracer {
                    visible: editor.showTracer
                }
                Layout.preferredWidth: editor.cardWidth
                contentHtml: "hey, <a href='status:user:robert'>@robertf.ox.eth</a>, " +
                             "This message is intentionally longer to demonstrate a 4-line clamp. " +
                             "Adding more filler text so you can see the ellipsis at the end of line 4."
                maxLines: 4
            }*/
        }
        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 160
            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            NotificationCardBaseEditor {
                id: baseEditor
                Layout.rightMargin: 8
                Layout.fillWidth: true
            }

            CheckBox {
                id: premImageVisible
                text: "Is Pre-Image?"
                checked: true
            }

            Label {
                text: "Text Content:"
            }

            TextField {
                id: textField
                Layout.rightMargin: 8
                Layout.fillWidth: true
                text: "hey, <a href='status:user:robert'>@robertf.ox.eth</a>, " +
                      "Do we still plan to ship this with v2.1 or postpone to the next release cycle?"
            }


        }
    }
}
// category: Activity Center
// status: good
// https://www.figma.com/design/SGyfSjxs5EbzimHDXTlj8B/Qt-Responsive---v?node-id=1912-363062&m=dev
