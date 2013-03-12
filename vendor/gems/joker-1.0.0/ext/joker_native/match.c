#include <malloc.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <ruby.h>
#include <ctype.h>
#include "match.h"

#define SUCCESS_STATE 42
#define FAILURE_STATE 23


typedef struct {
    const char *  input;
    const char *  wildcard;
    const char *  pushed_input;
    const char *  pushed_wildcard;
    int           state;
    void (*inc)(const char **, int);
} StateMachine;


typedef struct {
    StateMachine *  left;
    StateMachine *  right;
    StateMachine *  active;
} MatchData;


static void left_inc(pointer, offset) // {{{1
    const char **  pointer;
    int            offset;
{
    (*pointer) += offset;
}


static void right_inc(pointer, offset) // {{{1
    const char **  pointer;
    int            offset;
{
    (*pointer) -= offset;
}

static int matches(type, data, input, eos, casefold)  // {{{1
    WildcardType type;
    const char   data;
    const char   input;
    bool         eos;
    bool         casefold;
{
    switch(type) {
        case Fixed:
        case Group:
            if (casefold) {
                return !eos && tolower(input) == tolower(data);
            } else {
                return !eos && input == data;
            }
        case Wild:
            return !eos && input != '\0';
        case Kleene:
            return 1;
        case EOW:
            return eos;
        default:
            rb_raise(rb_eSyntaxError, "corrupted wildcard");
            return 0;
    }
}


static bool eow(match_data) // {{{1
    MatchData * match_data;
{
    return match_data->left->wildcard == NULL || match_data->left->wildcard > match_data->right->wildcard;
}


static bool eos(match_data) // {{{1
    MatchData * match_data;
{
    return match_data->left->input > match_data->right->input;
}


static void push(match_data) // {{{1
    MatchData * match_data;
{
    StateMachine * sm;
    
    if (!eos(match_data)) {
        sm                  = match_data->active;
        sm->pushed_input    = sm->input;
        sm->pushed_wildcard = sm->wildcard;
    }
}


static void pull(match_data) // {{{1
    MatchData * match_data;
{
    StateMachine * sm;

    sm = match_data->active;
    if (sm->pushed_input == NULL) {
        sm->state            = FAILURE_STATE;
    } else {
        sm->input            = sm->pushed_input;
        sm->wildcard         = sm->pushed_wildcard;
        sm->pushed_input     = NULL;
        sm->pushed_wildcard  = NULL;
        (*sm->inc)(&sm->input, 1); 

        if (sm == match_data->left) {
            match_data->active = match_data->right;
        } else {
            match_data->active = match_data->left;
        }
    }                              
}                                  
                                   

static void do_transition(transition, match_data)  // {{{1
    const char   transition;
    MatchData *  match_data;
{
    StateMachine * sm;

    sm = match_data->active;
    switch (transition) {
        case 0:
            push(match_data);
            (*sm->inc)(&sm->wildcard, 2);
            break;
        case 1:
            sm->state = 1;
            break;
        case 2:
            sm->state = 2;
            break;
        case 3:
            sm->state = 4;
            break;
        case 4:
            // does no exist
            break;
        case 5:
            sm->state = SUCCESS_STATE;
            break;
        case 6:
            sm->state = 0;
            (*sm->inc)(&sm->wildcard, 2);
            (*sm->inc)(&sm->input,    1);
            break;
        case 7:
            sm->state = 0;
            pull(match_data);
            break;
        case 8:
            (*sm->inc)(&sm->wildcard, 2);
            break;
        case 9:
            sm->state = 3;
            (*sm->inc)(&sm->wildcard, 2);
            (*sm->inc)(&sm->input,    1);
            break;
        case 10:
            sm->state = 0;
            break;
        case 11:
            (*sm->inc)(&sm->wildcard, 2);
            break;
        case 12:
            sm->state = 0;
            (*sm->inc)(&sm->wildcard, 2);
            (*sm->inc)(&sm->input,    1);
            break;
        default:
            rb_fatal("Wildcard matching state machine failure. This is a bug in Joker!");
    }
}


bool Wildcard_match(wildcard, cstring, len, casefold)  // {{{1
    Wildcard *      wildcard;
    const char *    cstring;
    const long int  len;
    bool casefold;
{
    // the table that maps (match x state x type) -> transition
    const char transition_table[2][5][5] = {
        // fail
        {
        //   kleene, fixed, group, wild, EOW
            {     0,     1,     2,    3,   7}, // basic
            {     7,     7,     7,    7,   7}, // fixed
            {     7,     7,     8,    7,   7}, // group
            {    10,    10,    11,   10,  10}, // group_finish
            {     7,     7,     7,    7,   7}, // wild
        },

        // match
        {
        //   kleene, fixed, group, wild, EOW
            {     0,     1,     2,    3,   5}, // basic
            {     6,     6,     6,    6,   6}, // fixed
            {     7,     7,     9,    7,   7}, // group
            {    10,    10,    11,   10,  10}, // group_finish
            {    12,    12,    12,   12,  12}, // wild
        },
    };

    MatchData *   match_data;
    WildcardType  type;
    char          data;
    char          input;
    int           match;
    char          transition;

    match_data                          = malloc(sizeof(MatchData));
    match_data->left                    = malloc(sizeof(StateMachine));
    match_data->right                   = malloc(sizeof(StateMachine));
    match_data->active                  = match_data->left;

    match_data->left->input             = cstring;
    match_data->left->wildcard          = wildcard->first;
    match_data->left->pushed_input      = NULL;
    match_data->left->pushed_wildcard   = NULL;
    match_data->left->state             = 0;
    match_data->left->inc               = left_inc;

    match_data->right->input            = cstring + len - 1;
    match_data->right->wildcard         = wildcard->last;
    match_data->right->pushed_input     = NULL;
    match_data->right->pushed_wildcard  = NULL;
    match_data->right->state            = 0;
    match_data->right->inc              = right_inc;

    while (true) {
        // get the data and it's type
        if (eow(match_data)) {
            type   = EOW;
            data   = '\0';
        } else {
            type   = (WildcardType) *match_data->active->wildcard;
            data   = *(match_data->active->wildcard + 1);
        }

        // get input, whether it matches the data and the transition to make
        input      = *match_data->active->input;
        match      = matches(type, data, input, eos(match_data), casefold);
        transition = transition_table[match][(int)match_data->active->state][type];
        // and execute the tansition
        do_transition(transition, match_data);

        // if the transition resulted in failure or success:
        // clean up and terminate
        if (match_data->active->state == SUCCESS_STATE) {
            free(match_data->right);
            free(match_data->left);
            free(match_data);
            return true;
        } else if (match_data->active->state == FAILURE_STATE) {
            free(match_data->right);
            free(match_data->left);
            free(match_data);
            return false;
        }
    }
}

