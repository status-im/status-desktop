#import "StatusQ/systemutilsinternal.h"

#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>
#include <AppKit/AppKit.h>

void SystemUtilsInternal::customWindowDecoration(QQuickWindow* windowObj)
{
    if (!windowObj) return;

    NSView *nsView = reinterpret_cast<NSView*>(windowObj->winId());
    NSWindow *window = [nsView window];

    NSView *content = window.contentView;
    content.wantsLayer               = YES;
    content.layer.cornerRadius      = 12.0;
    content.layer.masksToBounds     = YES;
}

void SystemUtilsInternal::defaultWindowDecoration(QQuickWindow* windowObj)
{
    if (!windowObj) return;

    NSView *nsView = reinterpret_cast<NSView*>(windowObj->winId());
    NSWindow *window = [nsView window];

    NSView *content = window.contentView;
    content.wantsLayer               = YES;
    content.layer.cornerRadius      = 0;      // pick your radius
    content.layer.masksToBounds     = YES;       // clip the view to that radius
}
