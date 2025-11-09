.global matMult
.equ ws, 4

.text
# ebp + 7 * ws: num_cols_b
# ebp + 6 * ws: nums_rows_b
# ebp + 5 * ws: b
# ebp + 4 * ws: num_cols_a
# ebp + 3 * ws: nums_rows_a
# ebp + 2 * ws: a
# ebp + 1 * ws: return address
# ebp ->: old ebp
# ebp - 1 * ws: n
# ebp - 2 * ws: i
# ebp - 3 * ws: j
# ebp - 4 * ws: k
# ebp - 5 * ws: C <- esp

matMult:
    .equ num_locals, 5
    .equ used_ebx, 1
    .equ used_edi, 1
    .equ used_esi, 1
    .equ num_saved_regs, (used_ebx + used_edi + used_esi)

    prologue_start:
        push %ebp
        movl %esp, %ebp
        subl $num_locals * ws, %esp
        subl $num_saved_regs * ws, %esp
        .equ a, (2 * ws) # (%ebp)
        .equ num_rows_a, (3 * ws) # (%ebp)
        .equ num_cols_a, (4 * ws) # (%ebp)
        .equ b, (5 * ws) # (%ebp)
        .equ num_rows_b, (6 * ws) # (%ebp)
        .equ num_cols_b, (7 * ws) # (%ebp)
        .equ n, (-1 * ws) # (%ebp)
        .equ i, (-2 * ws) # (%ebp)
        .equ j, (-3 * ws) # (%ebp)
        .equ k, (-4 * ws) # (%ebp)
        .equ c, (-5 * ws) # (%ebp)
        .equ old_esi, (-6 * ws) # (%ebp)
        .equ old_ebx, (-7 * ws) # (%ebp)
        .equ old_edi, (-8 * ws) # (%ebp)

        # Save registers
        movl %esi, old_esi(%ebp)
        movl %ebx, old_ebx(%ebp)
        movl %edi, old_edi(%ebp)
    prologue_end:

    // int **c = malloc(num_rows_a * sizeof(int*));
    # eax = num_rows_a * sizeof(int*);
    movl num_rows_a(%ebp), %eax # eax = num_rows_a;
    shll $2, %eax # eax = num_rows_a * sizeof(int*);
    push %eax # Set parameter to malloc
    call malloc
    addl $1 *ws, %esp # Clear malloc's arg from stack
    movl %eax, c(%ebp)

    // for (int n = 0; n < num_rows_a; ++n)
    movl $0, %ecx # n = 0
    init_for_start:
        # n < num_rows_a
        # n - num_rows_a < 0
        # neg: n - num_rows_a >= 0
        cmpl num_rows_a(%ebp), %ecx
        jge init_for_end

        // c[n] = malloc(num_cols_b * sizeof(int));
        // *(c + n) = malloc(num_cols_b * sizeof(int));
        movl num_cols_b(%ebp), %edx # edx = num_cols_b;
        shll $2, %edx
        push %edx
        movl %ecx, n(%ebp) # Save n
        call malloc
        addl $1 *ws, %esp # Clear malloc's arg from stack
        movl c(%ebp), %eax # Restore c in eax
        movl n(%ebp), %ecx # Restore n in ecx
        movl %edx, (%eax, %ecx, ws) # *(c + n) = edx

        incl %ecx
        jmp init_for_start
    init_for_end:

    # for (int i = 0; i < num_rows_a; ++i)
    movl $0, %ecx # i = 0
    outer_outer_for_start:
        # i < num_rows_a
        # i - num_rows_a < 0
        # neg: i - num_rows_a >= 0
        cmpl num_rows_a(%ebp), %ecx
        jge outer_outer_for_end

        // for (int j = 0; j < num_cols_b; ++j)
        movl $0, %esi # j = 0
        outer_for_start:
            cmpl num_cols_b(%ebp), %esi
            jge outer_for_end
            // c[i][j] = 0;
            // *(*(c + i) + j) = 0
            movl (%eax, %ecx, ws), %eax  # eax = *(c + i)
            movl $0, (%eax, %esi, ws) # *(*(c + i) + j) = 0

            // for (int k = 0; k < num_cols_a; ++k)
            movl $0, %ebx # k = 0
            inner_for_start:
                cmpl num_cols_a(%ebp), %ebx
                jge inner_for_end
                // c[i][j] += a[i][k] * b[k][j];
                // *(*(c + i) + j) += *(*(a + i) + k) * *(*(b + k) + j);

                // eax = *(*(a + i) + k)
                movl a(%ebp), %eax # eax = a
                movl (%eax, %ecx, ws), %eax # eax = *(a + i)
                movl (%eax, %ebx, ws), %eax # eax = *(*(a + i) + k)

                // edi = *(*(b + k) + j)
                movl b(%ebp), %edi # edi = b
                movl (%edi, %ebx, ws), %edi # edi = *(b + k)
                movl (%edi, %esi, ws), %edi # edi = *(*(b + k) + j)

                // edx = *(*(c + i) + j)
                movl c(%ebp), %edx # Restore c in edx
                movl (%edx, %ecx, ws), %edx # edx = *(c + i)
                movl (%edx, %esi, ws), %edx # edx = *(*(c + i) + j)

                // edx:eax = edi * eax
                imull %edi

                // edx = edx + eax
                addl %eax, %edx

                movl c(%ebp), %eax # Restore c in eax
                movl (%eax, %ecx, ws), %eax # eax = *(c + i)
                movl %edx, (%eax, %esi, ws) # *(*(c + i) + j) = edx
                # *(*(c + i) + j) = *(*(c + i) + j) + edi * eax

                incl %ebx
                jmp inner_for_start
            inner_for_end:
            incl %esi
            jmp outer_for_start
        outer_for_end:
        incl %ecx
        jmp outer_outer_for_start
    outer_outer_for_end:
    // return c;
    movl c(%ebp), %eax # set return value to c

    epilogue_start:
    # Restore saved registers
    movl old_edi(%ebp), %edi
    movl old_ebx(%ebp), %ebx
    movl old_esi(%ebp), %esi

    movl %ebp, %esp # Remove the space for locals from stack
    pop %ebp # Restore old stack frame
    epilogue_end:

done:
    nop
