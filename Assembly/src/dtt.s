.section .data
    prompt: .asciz "Enter data bit (0 or 1): "
    newline: .asciz "\n"
    detect_msg: .asciz "Rising edge detected!\n"
    invalid_msg: .asciz "Invalid input!\n"
.section .bss
    data_bit: .skip 2  // Increased to 2 bytes to accommodate null terminator
    q1: .skip 1
    q2: .skip 1
    y: .skip 1
.section .text
    .global _start
_start:
    // Initialize flip-flops and output to 0
    mov w2, #0
    ldr x1, =q1
    strb w2, [x1]
    ldr x1, =q2
    strb w2, [x1]
    ldr x1, =y
    strb w2, [x1]

input_loop:
    // Prompt for data bit
    mov x0, #1
    ldr x1, =prompt
    mov x2, #25
    mov x8, #64
    svc #0
    
    // Read user input
    mov x0, #0
    ldr x1, =data_bit
    mov x2, #2
    mov x8, #63
    svc #0
    
    // Validate input (must be '0' or '1')
    ldr x1, =data_bit
    ldrb w2, [x1]
    cmp w2, #'0'
    beq valid_input
    cmp w2, #'1'
    beq valid_input
    b invalid_input

valid_input:
    sub w2, w2, #'0'  // Convert ASCII to integer
    
    // Store previous Y value
    ldr x1, =y
    ldrb w7, [x1]    // W7 = Previous Y value
    
    // Load q1 into q2 (second flip-flop)
    ldr x1, =q2
    ldr x3, =q1
    ldrb w4, [x3]    // W4 = Current q1 value
    strb w4, [x1]    // Update q2 with q1 value
    
    // Load data into q1 (first flip-flop)
    ldr x1, =q1
    strb w2, [x1]    // Update q1 with Data bit
    
    // Compute AND operation (Y = q1 AND NOT q2)
    ldr x1, =q1
    ldrb w5, [x1]    // W5 = q1
    ldr x1, =q2
    ldrb w6, [x1]    // W6 = q2
    
    mov w8, #1
    eor w6, w6, w8   // NOT q2
    and w6, w5, w6   // q1 AND NOT q2
    
    // Store new Y value
    ldr x1, =y
    strb w6, [x1]
    
    // Check for rising edge (previous Y = 0 and current Y = 1)
    cmp w7, #0
    bne skip_check
    cmp w6, #1
    bne skip_check
    
    // Print "Rising edge detected!"
    mov x0, #1
    ldr x1, =detect_msg
    mov x2, #24
    mov x8, #64
    svc #0
    
skip_check:
    // Optional: print newline for better readability
    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    mov x8, #64
    svc #0
    
    // Loop back for next input
    b input_loop

invalid_input:
    // Print "Invalid input!"
    mov x0, #1
    ldr x1, =invalid_msg
    mov x2, #15
    mov x8, #64
    svc #0
    
    // Loop back instead of exiting
    b input_loop

exit:
    // Exit program (not reached in this loop implementation)
    mov x0, #0
    mov x8, #93
    svc #0
