section .data
    newline db 0xA
    msg_sum db "Sum of digits: ", 0
    msg_sum_len equ $ - msg_sum
    msg_len db "Length: ", 0
    msg_len_len equ $ - msg_len

section .bss
    ; memory: буфери для роботи
    input_buffer resb 12
    output_buffer resb 12
    num_x resd 1
    sum_digits resd 1
    count_digits resd 1

section .text
global _start

_start:
    ; I/O: читання числа з консолі
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 12
    int 0x80

    ; parse: конвертація String -> Int (atoi)
    xor eax, eax
    mov esi, input_buffer
atoi_loop:
    movzx ebx, byte [esi]
    cmp bl, 0xA
    je  math_init
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp atoi_loop

math_init:
    ; math: підготовка до обчислення суми та довжини
    mov [num_x], eax
    xor ebx, ebx            ; тут буде сума (sum)
    xor ecx, ecx            ; тут буде кількість (len)
    mov edi, 10             ; дільник

    ; loops: цикл while x > 0
calculation_loop:
    test eax, eax           ; перевірка x > 0
    jz  print_results

    xor edx, edx            ; обов'язково обнуляємо EDX перед div
    div edi                 ; EDX:EAX / 10 -> EAX (квота), EDX (залишок)

    add ebx, edx            ; додаємо залишок (цифру) до суми
    inc ecx                 ; збільшуємо лічильник довжини
    jmp calculation_loop

print_results:
    mov [sum_digits], ebx
    mov [count_digits], ecx

    ; logic: вивід першого рядка (сума)
    push msg_sum
    push msg_sum_len
    call print_string

    mov eax, [sum_digits]
    call print_number

    ; logic: вивід другого рядка (довжина)
    push msg_len
    push msg_len_len
    call print_string

    mov eax, [count_digits]
    call print_number

    ; logic: вихід
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Підпрограми ---

print_string:
    pop ebp
    pop edx
    pop ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    push ebp
    ret

print_number:
    ; logic: ітоа (Int -> String)
    mov ecx, 10
    mov edi, output_buffer + 10
    mov byte [edi], 0

    ; якщо число 0
    test eax, eax
    jnz itoa_convert
    dec edi
    mov byte [edi], '0'
    jmp itoa_done

itoa_convert:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz itoa_convert

itoa_done:
    ; I/O: вивід числа
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, output_buffer + 10
    sub edx, edi
    int 0x80

    ; I/O: новий рядок
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret