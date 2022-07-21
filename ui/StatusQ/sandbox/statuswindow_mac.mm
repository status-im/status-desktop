#include "statuswindow.h"

#include <QColor>

#include <QDebug>

#include <Foundation/Foundation.h>
#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSToolbar.h>
#include <AppKit/NSButton.h>
#include <AppKit/AppKit.h>

void StatusWindow::removeTitleBarMac()
{
    NSView *nsView = reinterpret_cast<NSView*>(this->winId());
    NSWindow *window = [nsView window];

    window.titlebarAppearsTransparent = true;
    window.titleVisibility = NSWindowTitleHidden;
    window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    NSButton* close = [window standardWindowButton:NSWindowCloseButton];
    NSView* titleBarContainerView = close.superview.superview;
    [titleBarContainerView setHidden:YES];
}

void StatusWindow::showTitleBarMac()
{
    NSView *nsView = reinterpret_cast<NSView*>(this->winId());
    NSWindow *window = [nsView window];

    window.titlebarAppearsTransparent = true;
    window.titleVisibility = NSWindowTitleHidden;
    window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    NSButton* close = [window standardWindowButton:NSWindowCloseButton];
    NSView* titleBarContainerView = close.superview.superview;
    [titleBarContainerView setHidden:NO];
}
