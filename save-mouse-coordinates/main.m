//
//  main.m
//  save-mouse-coordinates
//  simple cli app to write a file with the coordinates of mousedown and mouseup
//
//  Created by Ramiro Araujo on 2/19/14.
//  Copyright (c) 2014 Ramiro Araujo. All rights reserved.
//

int x_ini;
int y_ini;
int x_end;
int y_end;

static CGEventRef eventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {

    CGPoint mouse = CGEventGetLocation(event);

    if (type == kCGEventLeftMouseDown) {
        x_ini = (int) floor(mouse.x);
        y_ini = (int) floor(mouse.y);
    } else if (type == kCGEventLeftMouseUp) {
        x_end = (int) ceil(mouse.x);
        y_end = (int) ceil(mouse.y);

        // write the coordinates and exit
        NSString *string = [NSString stringWithFormat:@"%i %i %i %i", x_ini, x_end, y_ini, y_end];
        NSError *error = nil;
        NSString *fileName = @"coordinates";
        [string writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
        exit(0);
    } else {
        CGKeyCode keyCode = (CGKeyCode) CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        if (keyCode == 53) {
            // exit on ESC
            exit(0);
        }
    }

    return event;
}


int main(int argc, char **argv) {

    CGEventMask mouseDownMask;
    CGEventMask mouseUpMask;
    CGEventMask keyUpMask;

    CFMachPortRef eventTap;

    CFRunLoopSourceRef eventTapRLSrc;

    // subscribe to mousedown, mouseup and keydown events
    mouseDownMask = CGEventMaskBit(kCGEventLeftMouseDown);
    mouseUpMask = CGEventMaskBit(kCGEventLeftMouseUp);
    keyUpMask = CGEventMaskBit(kCGEventKeyDown);

    // Create the Taps
    eventTap = CGEventTapCreate(
            kCGSessionEventTap,
            kCGTailAppendEventTap,
            kCGEventTapOptionListenOnly,
            mouseDownMask | mouseUpMask | keyUpMask,
            &eventTapCallback,
            NULL
    );

    // runloop
    eventTapRLSrc = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            eventTap,
            0
    );

    CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            eventTapRLSrc,
            kCFRunLoopDefaultMode
    );

    CFRunLoopRun();

    return 0;
}