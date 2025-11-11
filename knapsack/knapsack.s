.global knapsack
.equ ws, 4
.text

max:

    # ebp +3 b
    # ebp +2 a
    # ebp + 1 return address
    # ebp : old ebp
    prologue_max_start:
        push %ebp
        movl %esp, %ebp
        # make space for locals and saved regs
        # save saved regs
        .equ b, (3*ws) 
        .equ a, (2*ws)

    prologue_max_end:

    # if (a>b)
    # a - b < 0
    # neg: a - b >= 0

    # eax will be a
    # ecx will be b
    movl a(%ebp), %eax
    movl b(%ebp), %ecx
    cmpl %ecx, %eax
    jge else

    if:
        # return a
        # a already in eax
        jge epilogue_max

    else:
        # return b
        movl %ecx, %eax

    epilogue_max:
        # restore saved registers
        movl %ebp, %esp
        pop %ebp
        ret

knapsack: 
    # ebp +6cur_value
    # ebp +5 capacity
    # ebp +4 num_items
    # ebp +3 values
    # ebp +2 weights
    # ebp +1 return address
    # ebp: old ebp
    # ebp +1 : i
    # ebp +2 : best_value
    # ebp +3: old_ebx

    .equ num_locals, 2
    .equ used_ebx, 1
    .equ used_edi, 0
    .equ used_esi, 1
    .equ num_saved_regs(used_ebx + used_edi + used_esi)
    prologue_knapsack_start:
        push %ebp
        movl %esp, %ebp
        subl $num_locals * ws, %esp
        subl $num_saved_regs * ws, %esp

        .equ cur_value, (6*ws)
        .equ capacity, (5*ws)
        .equ num_items, (4*ws)
        .equ values (3*ws)
        .equ weights, (2*ws)
        .equ i, (-1 * ws)
        .equ best_value, (-2 * ws)
        .equ knap_result, (-3 *ws)
        .equ old_ebx, (-4 * ws)
        .equ old_esi, (-5 * ws)

        # make sure to save those registers
        movl %ebx, old_ebx(%ebp)
        movl %esi, old_esi(%ebp)
    
    prologue_knapsack_end:

    # eax will be i
    movl $0, %eax

    # ebx wil be best_value
    # unsigned int best_value = cur_value;
    movl cur_value(%ebp), %ebx # ebx = cur_value

    # for(i = 0; i < num_items; i++)
    outer_for_start:
        # i < num_items
        # i - num-items < 0
        # neg: i - num_items >= 0
        cmpl num_items(%ebp), %ecx
        jge outer_for_end

        if:
            # capacity will be ecx
            # weights will be edx
            movl capacity(%ebp), %ecx
            movl weights(%ebp), %edx

            # capacity - weights[i] >= 0
            # want neg: capacity - weights[i] <0
            cmpl (%edx, %eax, 1), %ecx
            jl else

            # knapsack(weights + i + 1, values + i + 1, num_items - i - 1, capacity - weights[i], cur_value + values[i]));
            # push reverse order

            # cur_value + values[i]
            movl cur_value(%ebp), %edx  # cur value = edx
            movl values(%ebp), %esi     # values = esi
            addl (%esi, %eax, ws), %edx # edx = cur_value = values[i]
            push %edx

            # capacity - weights[i]
            # capacity in edx
            # weights used to be in edx, but got overwritten, so re move to esi
            movl capacity(%ebp), %edx
            movl weights(%ebp), %esi    # esi = weights
            subl (%esi, %eax, ws), %edx  # ecx = capacity-weights[i]
            push %edx

            # num_items - i - 1
            movl num_items(%ebp), %edx  # edx = num_items
            subl %eax, $edx             # edx = num_items - i
            decl %edx                   # edx = num_items -i -1
            push %edx

            # values + i + 1
            movl values(%ebp), %edx     # edx = values
            leal ws(%edx, %eax, ws), %edx   # edx = values +i +1
            push %edx

            # weights + i +1 
            movl weights(%ebp), %edx    # edx = weights
            leal ws(%edx, %eax, ws), %edx   # edx = weights + i +1
            push %edx

            # call knapstack now, but need to check to see to save eax, ecx, or edx
            # need to save eax, but not really edx, , nor ecx 
            movl %eax, i(%ebp)  # saves i
            call knapsack
            addl $5*ws, %esp    # clear stack

            movl %eax, knap_result(%ebp)        # result of func saveed in knapresult

            movl i(%ebp), %eax  # restore I into eax

            # need to call max on whatever we had
            # max(best_value, knapsack(whatever)
            movl knap_result(%ebp), %edx    # edx = knapsack result
            push %edx
            push %ebx       # ebx was holding best_value, push in reverse

            call max
            addl $2*ws, %esp
            movl %eax, %ebx

        else:
            movl i(%ebp), %eax
            incl %eax
            movl %eax, i(%ebp)
            jmp outer_for_start


    outer_for_end:
        movl %ebx, %eax

    epilogue_knap_start:
    # restore saved registers
    movl old_ebx(%ebp), %ebx
    movl old_esi(%ebp), %esi
    
    movl %ebp, %esp
    pop %ebp
    ret
    epilogue_knap_end:

done:
    nop 



