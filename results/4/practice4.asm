section .data
    newline db 0xA
    prompt db 'Enter number: ', 0
    prompt_len equ $ - prompt

section .bss
    ; memory: буфери для вводу та виводу
    input_buffer resb 12
    output_buffer resb 12

section .text
global _start

_start:
    ; I/O: вивід підказки
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; I/O: читання рядка з консолі (sys_read)
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 12
    int 0x80

    ; parse: конвертація String -> Int
    ; logic: підготовка регістрів
    xor eax, eax            ; тут буде фінальне число
    xor ebx, ebx            ; тимчасовий регістр для цифри
    mov esi, input_buffer   ; адреса буфера

convert_to_int:
    movzx ebx, byte [esi]   ; беремо один символ
    cmp bl, 0xA             ; перевірка на символ нового рядка (Enter)
    je  start_printing      ; якщо Enter — закінчуємо
    cmp bl, '0'             ; перевірка, чи це цифра
    jl  start_printing
    cmp bl, '9'
    jg  start_printing

    ; math: основна логіка конвертації
    sub bl, '0'             ; перетворюємо символ '5' у число 5
    imul eax, 10            ; множимо поточний результат на 10
    add eax, ebx            ; додаємо нову цифру
    inc esi                 ; наступний символ
    jmp convert_to_int

start_printing:
    ; Тепер число лежить в EAX (включаючи AX).
    ; Використовуємо код з Практичної 3 для виводу.

    ; logic: підготовка до виводу
    mov ecx, 10
    mov edi, output_buffer + 10
    mov byte [edi], 0       ; термінатор рядка (опціонально)

convert_to_string:
    ; math: ділення на 10 для отримання цифр
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz convert_to_string

    ; I/O: вивід результату
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    ; рахуємо довжину рядка
    mov edx, output_buffer + 10
    sub edx, edi
    int 0x80

    ; I/O: перехід на новий рядок
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; logic: завершення програми
    mov eax, 1
    xor ebx, ebx
    int 0x80