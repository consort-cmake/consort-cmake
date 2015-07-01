section .text

%ifdef CONSORT_LINUX
global is_asm_enabled:function
%else
global is_asm_enabled
%endif

%ifdef CONSORT_WINDOWS_X86_64
proc_frame is_asm_enabled
%endif

is_asm_enabled:
	mov eax, 1
	ret

%ifdef CONSORT_WINDOWS_X86_64
endproc_frame
%endif


