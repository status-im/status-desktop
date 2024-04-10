import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../stores"
import "./dapps"

SettingsContentBase {
    id: root

    required property ProfileSectionStore profileSectionStore
    required property string mainSectionTitle

    titleRowComponentLoader.sourceComponent: stackLayout.currentIndex === d.mainViewIndex ||
                                             stackLayout.currentIndex === d.connectedDappsIndex?
                                                 d.headerButton : undefined

    function handleBackAction() {
        if (stackLayout.currentIndex !== d.mainViewIndex) {
            root.profileSectionStore.backButtonName = ""
            root.sectionTitle = root.mainSectionTitle
            stackLayout.currentIndex = d.mainViewIndex
        }
    }

    StackLayout {
        id: stackLayout

        currentIndex: d.mainViewIndex

        QtObject {
            id: d

            readonly property int mainViewIndex: 0
            readonly property int connectedDappsIndex: 1
            readonly property int approvalsIndex: 2
            readonly property int trustLevelsIndex: 3
            readonly property int securityIndex: 4

            function changeSubsection(title, index) {
                root.profileSectionStore.backButtonName = root.mainSectionTitle
                root.sectionTitle = title
                stackLayout.currentIndex = index
            }

            property Component headerButton: Component {
                StatusButton {
                    text: qsTr("Connect a dApp via WalletConnect")
                    onClicked: {
                        console.warn("TODO: run wallet connect popup...")
                    }
                }
            }
        }

        Main {
            Layout.preferredWidth: root.contentWidth

            onDisplayConnectedDapps: d.changeSubsection(title, d.connectedDappsIndex)
            onDisplayApprovals: d.changeSubsection(title, d.approvalsIndex)
            onDisplayTrustLevels: d.changeSubsection(title, d.trustLevelsIndex)
            onDisplaySecurity: d.changeSubsection(title, d.securityIndex)
        }

        ConnectedDapps {
            Layout.preferredWidth: root.contentWidth
        }

        Approvals {
            Layout.preferredWidth: root.contentWidth
        }

        TrustLevels {
            Layout.preferredWidth: root.contentWidth
        }

        Security {
            Layout.preferredWidth: root.contentWidth
        }
    }
}
