import QtQuick
import QtQuick.Controls
import QtTest

import StatusQ.Core.Theme

import shared.popups

Item {
    id: root

    width: 800
    height: 900

    Component {
        id: notificationComponent

        QtObject {
            property string id: "1"
            property string newsTitle: "Swaps around the corner!"
            property string newsContent: "Status Desktop's next release brings the app up-to-speed with Status Mobile. That means: SWAPS! Now you can trade Ethereum, Arbitrum and Optimism tokens directly in-app."
            property string newsLink: "https://status.app/"
            property string newsLinkLabel: "Read our blog post"
            property string newsImageUrl
            property double timestamp: Date.now()
        }
    }

    Component {
        id: popupComponent

        NewsMessagePopup {}
    }

    property NewsMessagePopup controlUnderTest: null

    TestCase {
        name: "NewsMessagePopup"
        when: windowShown

        function cleanup() {
            if (controlUnderTest) {
                controlUnderTest.close();
                controlUnderTest.destroy();
                controlUnderTest = null;
            }
        }

        function createAndOpen(imageUrl) {
            const notification = createTemporaryObject(notificationComponent, root, { newsImageUrl: imageUrl });
            controlUnderTest = createTemporaryObject(popupComponent, root, { notification });
            controlUnderTest.open();
            tryCompare(controlUnderTest, "opened", true);
            return controlUnderTest;
        }

        function test_height_is_stable_after_image_loads_data() {
            return [
                // 512x512, height capped at 300
                { tag: "square", source: Assets.png("community/mint2_1"), capped: true },
                // 2880x1540, fits below the cap
                { tag: "wide", source: Assets.png("wallet/placeholders/mainView-light"), capped: false }
            ];
        }

        // Regression test for https://github.com/status-im/status-app/issues/22816
        function test_height_is_stable_after_image_loads(data) {
            createAndOpen(data.source);

            const image = findChild(controlUnderTest, "newsImage");
            verify(!!image);
            tryCompare(image.image, "status", Image.Ready);
            tryVerify(() => image.imageAspectRatio > 0);
            waitForRendering(controlUnderTest.contentItem);

            const settledHeight = controlUnderTest.height;
            const settledImageHeight = image.height;
            for (let i = 0; i < 10; ++i) {
                wait(20);
                compare(controlUnderTest.height, settledHeight);
                compare(image.height, settledImageHeight);
            }

            compare(image.width, image.parent.width);
            const naturalImageHeight = Math.round((image.width - 2 * image.border.width) * image.imageAspectRatio)
                                     + 2 * image.border.width;
            if (data.capped) {
                verify(naturalImageHeight > 300);
                compare(image.height, 300);
            } else {
                verify(naturalImageHeight < 300);
                compare(image.height, naturalImageHeight);
            }
        }

        function test_no_image_when_url_is_empty() {
            createAndOpen("");
            verify(!findChild(controlUnderTest, "newsImage"));
        }

        // The custom footer must be accounted for so the text is not squeezed into a scrolling viewport
        function test_text_is_fully_visible_without_scrolling() {
            createAndOpen("");

            const contentHost = findChild(controlUnderTest, "statusAdaptiveDialogContentHost");
            const scrollFlickable = findChild(controlUnderTest, "statusAdaptiveDialogScrollFlickable");
            verify(!!contentHost);
            verify(!!scrollFlickable);
            verify(controlUnderTest.footer.visible);

            tryCompare(contentHost, "height", contentHost.implicitHeight);
            compare(controlUnderTest.height, controlUnderTest.header.height + contentHost.height + controlUnderTest.footer.height);
            verify(!scrollFlickable.interactive);
            verify(scrollFlickable.contentHeight + scrollFlickable.topMargin + scrollFlickable.bottomMargin <= scrollFlickable.height);
        }
    }
}
