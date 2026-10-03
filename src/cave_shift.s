.intel_syntax noprefix
.code32
# WM_RBUTTONUP handler hook (stack is at the window-proc frame: wParam at [esp+0x3b8])
cave:
  test dword ptr [esp+0x3b8], 4      # MK_SHIFT held?
  jz orig                            # no: original right-click (recruit / upgrade)
  mov eax, dword ptr ds:0x436ce0
  test eax, eax
  je 0x40d096                        # shift + empty hand: do nothing
undo_loop:
  cmp dword ptr ds:0x4441d8, 0
  jle manual
  call 0x418ff0                      # game's own undo
  cmp dword ptr ds:0x436ce0, 0
  je done
  jmp undo_loop
manual:
  cmp dword ptr ds:0x436ce0, 8       # no undo history left
  jne 0x40d096                       # man in hand: leave it alone
  mov eax, dword ptr ds:0x436cdc
  test eax, eax
  je clear
  movsx eax, word ptr [eax*8+0x4454ea]
  imul eax, eax, 0x2c
  add word ptr [eax+0x436d0e], 15    # refund the keep
clear:
  mov dword ptr ds:0x436ce0, 0
done:
  mov dword ptr ds:0x436cec, 0
  mov dword ptr ds:0x441a10, 0
  mov ebp, dword ptr [esp+0x3b0]
  xor edi, edi
  jmp 0x4108d9                       # game's own "item dropped back" redraw
orig:
  mov edx, dword ptr ds:0x436cdc
  jmp 0x411d3e
