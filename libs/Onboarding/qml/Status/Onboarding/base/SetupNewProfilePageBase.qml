import QtQuick

import Status.Onboarding

/*! Proposal on how to templetize the alignment requirement of some views
 */
OnboardingPageBase {
    // TODO: fix error "Unable to assign Status::Onboarding::NewAccountController to Status::Onboarding::NewAccountController" then enable typed properties
    required property var newAccountController

    /// Common reference item that doesn't change between common views/pages
    readonly property Item alignmentItem: alignmentBaselineItem

    Item {
        id: alignmentBaselineItem

        width: 1
        height: 1

        anchors.horizontalCenter: parent.horizontalCenter
        y: (root.height * 477/770) - baselineOffset
    }
}
