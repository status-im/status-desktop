#include "sandboxapp.h"

#include <QColor>

#include <Foundation/Foundation.h>
#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>
#include <AppKit/NSColor.h>

void SandboxApp::removeTitleBar(WId wid)
{
    NSView *nsView = reinterpret_cast<NSView*>(wid);
    NSWindow *window = [nsView window];

    window.titlebarAppearsTransparent = true;
    window.titleVisibility = NSWindowTitleHidden;
    window.styleMask |= NSWindowStyleMaskFullSizeContentView;
}
