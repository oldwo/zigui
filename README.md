# zigui
Efficient GUI library in zig

This is a zig port of DevOS GUI library. The original is in C/C++.
Currently, only the PushButton widget is implemented.

There are two event passing mechanisms:
1. efficient, with subscription and filtering.
2. via window procedure, all events all the time, but smaller and simpler code.
The mouse events are implemented, but keyboard events - not yet properly.

This library is divine, God-inspired.
I was just translating the ideas into a particular programming language.
