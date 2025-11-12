/*
int** get_combs(int* items, int k, int len) {
    int combs = num_combs(len, k);
    int** result = (int**)malloc(combs * sizeof(int*));
    int index = 0;

    if (k == 1) {
        for (int i = 0; i < len; i++) {
            result[i] = (int*)malloc(k * sizeof(int));
            result[i][0] = items[i];
        }
        return result;
    }

    while(len > k) {
        int first = *items;
        items++;
        len--;
        int** last = get_combs(items, k - 1, len);
        int num_last = num_combs(len, k - 1);

        for (int y = 0; y < num_last; y++) {
            result[index] = (int*)malloc(k * sizeof(int));
            result[index][0] = first;
            for (int x = 0; x < k - 1; x++) {
                result[index][x + 1] = last[y][x];
            }
            index++;
        }
    }

    result[index] = (int*)malloc(k * sizeof(int));
    for (int i = 0; i < k; i++) {
        result[index][i] = items[i];
    }

    return result;
}

*/

.global get_combs
.equ ws, 4

.text
# ebp + 4 * ws: len
# ebp + 3 * ws: k
# ebp + 2 * ws: items
# ebp + 1 * ws: return address
# ebp ->: old ebp
# ebp - 1 * ws: combs
# ebp - 2 * ws: result
# ebp - 3 * ws: index
# ebp - 4 * ws: i
# ebp - 5 * ws: first
# ebp - 6 * ws: last
# ebp - 7 * ws: num_last
# ebp - 8 * ws: y
# ebp - 9 * ws: x
# ebp - 10 * ws: i_2

get_combs:
    prologue_start:
        .equ num_locals, 10
        .equ used_ebx, 1
        .equ used_esi, 1
        .equ used_edi, 1
        .equ num_saved_regs, (used_ebx + used_esi + used_edi)

        push %ebp 
        movl %esp, %ebp
        subl $num_locals * ws, %esp
        subl $num_saved_regs * ws, %esp
        .equ len, (4 * ws) # (%ebp)
        .equ k, (3 * ws) # (%ebp)
        .equ items, (2 * ws) # (%ebp)
        .equ combs, (-1 * ws) # (%ebp)
        .equ result, (-2 * ws) # (%ebp)
        .equ index, (-3 * ws) # (%ebp)
        .equ i, (-4 * ws) # (%ebp)
        .equ first, (-5 * ws) # (%ebp)
        .equ last, (-6 * ws) # (%ebp)
        .equ num_last, (-7 * ws) # (%ebp)
        .equ y, (-8 * ws) # (%ebp)
        .equ x, (-9 * ws) # (%ebp)
        .equ i_2, (-10 * ws) # (%ebp)
        .equ old_ebx, (-11 * ws) # (%ebp)
        .equ old_esi, (-12 * ws) # (%ebp)
        .equ old_edi, (-13 * ws) # (%ebp)

        # Saved Registers
        movl %ebx, old_ebx(%ebp)
        movl %esi, old_esi(%ebp)
        movl %edi, old_edi(%ebp)
    prologue_end:

    // int combs = num_combs(len, k);
    movl k(%ebp), %ecx # ecx = k;
    push %ecx # Put k on the stack as an arg
    movl len(%ebp), %edx # edx = len;
    push %edx # Put len on the stack as an arg
    call num_combs
    addl $2 * ws, %esp # Clear args on stack
    # eax = num_combs(len, k)
    movl %eax, combs(%ebp) # combs = eax;

    // int** result = (int**)malloc(combs * sizeof(int*));
    movl combs(%ebp), %ecx # ecx = combs;
    shll $2, %ecx # ecx = combs * sizeof(int*);
    push %ecx # Put combs * sizeof(int*) on the stack as an arg
    call malloc
    addl $1 * ws, %esp # Clear args on stack
    movl %eax, result(%ebp) # result = eax;

    // int index = 0;
    movl $0, index(%ebp) # index = 0;

    // if (k == 1)
    if:
    # k - 1 == 0
    # neg: k - 1 != 0
    cmpl $1, k(%ebp) # k - 1
    jne while_start

    // for (int i = 0; i < len; i++)
    movl $0, %ecx # i = 0;
    for0_start:
        # i - len < 0
        # neg: i - len >= 0
        cmpl len(%ebp), %ecx # i - len
        jge for0_end

        // result[i] = (int*)malloc(k * sizeof(int));
        // *(result + i) = (int*)malloc(k * sizeof(int));
        movl k(%ebp), %edx # Restore k in edx
        shll $2, %edx # edx = k * sizeof(int)
        push %edx # Put edx on stack as an arg
        movl %ecx, i(%ebp)
        call malloc
        addl $1 * ws, %esp # Clear arg from the stack
        # eax = (int*)malloc(k * sizeof(int));
        # *(result + i) = eax;
        movl result(%ebp), %edx # Restore result in edx
        movl i(%ebp), %ecx # Restore i in ecx
        movl %eax, (%edx, %ecx, ws) #  result[i] = eax

        // result[i][0] = items[i];
        // *(*(result + i) + 0) = *(items + i);
        movl items(%ebp), %eax # eax = items
        movl (%eax, %ecx, ws), %eax # eax = *(items + i)
        movl result(%ebp), %edx # edx = result
        movl (%edx, %ecx, ws), %edx # edx = *(result + i)
        movl %eax, (%edx) # result[i][0] = items[i]

        incl %ecx
        jmp for0_start
    for0_end:
    // return result
    movl result(%ebp), %eax
    jmp epilogue_start

    
    movl len(%ebp), %edx # edx = len
    movl items(%ebp), %eax # eax = items
    movl k(%ebp), %ecx  # ecx = k
    while_start:
        // while(len > k)
        # len - k > 0
        # neg: len - k <= 0
        cmpl %ecx, %edx # len - k
        jle while_end

        // int first = *items;
        movl (%eax), %edx # Load value pointed by eax into edx
        movl %edx, first(%ebp) # Store edx into first
        movl len(%ebp), %edx # Restore len in edx

        // items++;
        incl %eax 

        // len--;
        decl %edx

        // int** last = get_combs(items, k - 1, len);
        push %edx # Put len on the stack as an arg
        movl %edx, len(%ebp) # Save edx in len
        decl %ecx # ecx = k - 1
        push %ecx # Put k - 1 on the stack as an arg
        push %eax # Put items on the stack as an arg
        movl %eax, items(%ebp) # Save eax in items
        call get_combs
        addl $3 * ws, %esp # Clear args from stack
        movl %eax, last(%ebp) # last = eax;

        // int num_last = num_combs(len, k - 1);
        movl k(%ebp), %ecx # ecx = k;
        decl %ecx # ecx = k - 1
        push %ecx # Put k - 1 on the stack as an arg
        movl len(%ebp), %edx # edx = len;
        push %edx # Put len on the stack as an arg
        call num_combs
        addl $2 * ws, %esp # Clear args on stack
        movl %eax, num_last(%ebp) # num_last = eax

        // for (int y = 0; y < num_last; y++)
        movl $0, y(%ebp) # y = 0;
        movl y(%ebp), %ecx
        outer_for_start:
            # y - num_last < 0
            # neg: y - num_last >= 0
            cmpl num_last(%ebp), %ecx
            jge outer_for_end

            // result[index] = (int*)malloc(k * sizeof(int));
            movl k(%ebp), %eax # eax = k;
            shll $2, %eax # eax = k * sizeof(int);
            push %eax # Put k * sizeof(int) on the stack as an arg
            movl %ecx, y(%ebp)
            call malloc
            addl $1 * ws, %esp # Clear arg from stack
            movl y(%ebp), %ecx # Restore y in ecx
            movl result(%ebp), %edx # Restore result in edx
            movl index(%ebp), %ebx # Restore index in ebx
            movl %eax, (%edx, %ebx, ws) # result[index] = eax;

            // result[index][0] = first;
            // *(*(result + index) + 0) = first;
            // *(eax) = first;
            movl first(%ebp), %edx # edx = first;
            movl %edx, (%eax) # result[index][0] = edx

            // for (int x = 0; x < k - 1; x++)
            movl $0, x(%ebp) # x = 0;
            movl x(%ebp), %esi # esi = x;
            inner_for_start:
                movl k(%ebp), %edi # edi = k;
                decl %edi # edi = k - 1
                # esi - edi < 0
                # neg: esi - edi >= 0
                cmpl %edi, %esi # x - k + 1
                jge inner_for_end

                // result[index][x + 1] = last[y][x];
                // *(*(result + index) + x + 1) = *(*(last + y) + x)
                movl last(%ebp), %edx # Restore last in edx
                movl (%edx, %ecx, ws), %edx # edx = *(last + y)
                movl (%edx, %esi, ws), %edx # edx = *(*(last + y) + x)
                incl %esi # esi = x + 1;
                movl result(%ebp), %eax # eax = result;
                movl (%eax, %ebx, ws), %eax # eax = *(result + index)
                movl %edx, (%eax, %esi, ws) # *(*(eax) + esi) = edx
                decl %esi # Revert x + 1 to just x

                incl %esi # x++
                jmp inner_for_start
            inner_for_end: 
            incl %ebx # index++

            incl %ecx # y++
            jmp outer_for_start
        outer_for_end:
    while_end:

    // result[index] = (int*)malloc(k * sizeof(int));
    movl k(%ebp), %edi # edi = k
    shll $2, %edi # edi = k * sizeof(int)
    push %edi # Put k * sizeof(int) on the stack as an arg
    call malloc
    addl $1 * ws, %esp # Remove arg from stack
    movl result(%ebp), %edx # Restore result in edx
    movl %eax, (%edx, %ebx, ws) # result[index] = eax

    // for (int i = 0; i < k; i++) 
    movl $0, %ecx # i = 0;
    movl k(%ebp), %esi # esi = k
    for1_start:
        # i - k < 0
        # neg: i - k >= 0
        cmpl %esi, %ecx # i - k
        jge for1_end

        // result[index][i] = items[i];
        movl (%edx, %ebx, ws), %edx # edx = *(result + index);
        movl items(%ebp), %edi # edi = items;
        movl (%edi, %ecx, ws), %edi # edi = *(items + i);
        movl %edi, (%edx, %ecx, ws) # *(*(result + index) + i) = edi;

        incl %ecx # i++
        jmp for1_start
    for1_end:

    // return result;
    movl result(%ebp), %eax
    jmp epilogue_start

    epilogue_start:
        movl old_edi(%ebp), %edi
        movl old_esi(%ebp), %esi
        movl old_ebx(%ebp), %ebx

        movl %ebp, %esp # Remove the space for locals from stack
        pop %ebp # Restore old stack frame
    epilogue_end:
    ret

    done:
        nop
