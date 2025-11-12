; ============================
; AHK Settings for Naya Create
; ============================
;
; This is my AutoHotkey script to configure key mapping for Naya Create.
; Naya provides "Naya Flow" that is key mapper, but it can configure to map from key type to mouse operations.
;
; I use this to configure key mapping rules that Naya Flow cannot work.

; Metadata
; ========
#Requires AutoHotkey v2.0

; Mouse emulation
; ===============

; Consts
; ------
global MOUSE_SPEED_SLOW := 1
global MOUSE_SPEED_MIDDLE := 5
global MOUSE_SPEED_FAST := 20

; Cursor movement
; ---------------
F20 & i::MouseMove(0, -(GetKeyState("Shift", "P") ? MOUSE_SPEED_FAST : MOUSE_SPEED_MIDDLE), 10, "R")
F20 & k::MouseMove(0, (GetKeyState("Shift", "P") ? MOUSE_SPEED_FAST : MOUSE_SPEED_MIDDLE), 10, "R")
F20 & j::MouseMove(-(GetKeyState("Shift", "P") ? MOUSE_SPEED_FAST : MOUSE_SPEED_MIDDLE), 0, 10, "R")
F20 & l::MouseMove((GetKeyState("Shift", "P") ? MOUSE_SPEED_FAST : MOUSE_SPEED_MIDDLE), 0, 10, "R")

; Cursor click
; ------------
F20 & u::LButton
F20 & o::RButton
