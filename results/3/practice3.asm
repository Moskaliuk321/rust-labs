section .data
    ; memory: Буфер для збереження цифр (макс 6 цифр + символ нового рядка)
    newline db 0xA
    buffer db '      '

section .text
global _start

_start:
    ; math: Вхідне число (за завданням AX, але для 999999 використовуємо EAX)
    mov eax, 123456         ; Приклад числа (0...999999)

    ; parse: Початкові налаштування для конвертації
    mov ecx, 10             ; Дільник
    mov edi, buffer + 5     ; Починаємо заповнювати буфер з кінця

convert_loop:
    ; math: Ділимо число на 10
    xor edx, edx            ; Очищаємо залишок
    div ecx                 ; EAX / 10. Частка в EAX, залишок в EDX

    ; logic: Перетворюємо цифру в ASCII символ
    add dl, '0'
    mov [edi], dl           ; Зберігаємо символ у буфер
    dec edi                 ; Зсуваємо вказівник вліво

    ; loops: Перевіряємо, чи залишилися ще цифри
    test eax, eax
    jnz convert_loop

print:
    ; I/O: Виводимо число на консоль (sys_write)
    mov eax, 4              ; Номер системного виклику sys_write
    mov ebx, 1              ; stdout (екран)

    ; Розраховуємо адресу початку числа та його довжину
    lea ecx, [edi + 1]      ; Адреса першої цифри
    mov edx, buffer + 6     ; Кінцева точка
    sub edx, ecx            ; Довжина = Кінець - Початок
    int 0x80                ; Виклик ядра

    ; I/O: Вивід символу нового рядка
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

exit:
    ; I/O: Завершення програми (sys_exit)
    mov eax, 1
    xor ebx, ebx
    int 0x80