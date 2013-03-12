#include <malloc.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <string.h>
#include <ruby.h>
#include "compile.h"


static int hash(cchar)  // {{{1
    const char  cchar;
{
    switch (cchar) {
        case '\\':
            return 0;
        case '[':
            return 1;
        case ']':
            return 2;
        case '*':
            return 3;
        case '?':
            return 4;
        default:
            return 5;
    }
}


static void push(type, cchar, wildcard)  // {{{1
    const WildcardType  type;
    const char          cchar;
    Wildcard *          wildcard;
{
    Wildcard_enlarge(wildcard);
    *wildcard->last        = (char) type;
    *(wildcard->last + 1)  = cchar;
}


static void do_transition(transition, input, state, wildcard)  // {{{1
    const char  transition;
    const char  input;
    int *       state;
    Wildcard *  wildcard;
{
    switch (transition) {
        case 0:
            *state = 1;
            break;
        case 1:
            *state = 2;
            break;
        case 2:
            push(Fixed, input, wildcard);
            rb_warning("wildcard has `]' without escape");
            break;
        case 3:
            // refactor ** --> *
            if (wildcard->last == NULL || *wildcard->last != (char) Kleene) {
                push(Kleene, '*', wildcard);
            }
            break;
        case 4:
            push(Wild, '?', wildcard);
            break;
        case 5:
            push(Fixed, input, wildcard);
            break;
        case 6:
            *state = -1;
            break;
        case 7:
            *state = 0;
            push(Fixed, input, wildcard);
            break;
        case 8:
            *state = 0;
            push(Fixed, '\\', wildcard);
            push(Fixed, input, wildcard);
            break;
        case 9:
            *state = -1;
            push(Fixed, '\\', wildcard);
            break;
        case 10:
            *state = 3;
            break;
        case 11:
            push(Group, input, wildcard);
            rb_warning("character class has `[' without escape");
            break;
        case 12:
            *state = 0;
            break;
        case 13:
            push(Group, input, wildcard);
            break;
        case 14:
            *state = -1;
            rb_raise(rb_eSyntaxError, "premature end of wildcard");
            break;
        case 15:
            *state = 2;
            push(Group, input, wildcard);
            break;
        case 16:
            *state = 2;
            push(Group, '\\', wildcard);
            push(Group, input, wildcard);
            break;
        default:
            rb_fatal("Wildcard compilation state machine failure. This is a bug in Joker!");
    }
}


Wildcard * Wildcard_compile(cstring, len)  // {{{1
    const char *    cstring;
    const long int  len;
{
    // the table that maps (state x input) -> transition
    const char transition_table[4][7] = {
    //    \   [   ]   *   ? any EOS
        { 0,  1,  2,  3,  4,  5,  6},
        { 7,  7,  7,  7,  7,  8,  9},
        {10, 11, 12, 13, 13, 13, 14},
        {15, 15, 15, 16, 16, 16, 14}
    };
    int state = 0;

    Wildcard * wildcard;
    long int   p;
    char       input;
    int        hashed;
    char       transition;

    wildcard = malloc(sizeof(Wildcard));
    wildcard->length = 0;
    wildcard->first  = NULL;
    wildcard->last   = NULL;

    // for each char:
    for (p = 0; p < len; p++) {
        // get the input, it's type and what transition to make
        input = cstring[p];
        hashed = hash(input);
        transition = transition_table[state][hashed];
        // and execute the transition
        do_transition(transition, input, &state, wildcard);
    }

    // finally: execute the finishing transition
    transition = transition_table[state][6];
    do_transition(transition, '\0', &state, wildcard);
    return wildcard;
}

