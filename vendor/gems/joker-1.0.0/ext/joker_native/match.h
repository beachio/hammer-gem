#ifndef MATCH_H_GUARD
#define MATCH_H_GUARD

#include "Wildcard.h"
#include "stdbool.h"


/*
 * Matches a given Wildcard against a given string and returns
 * true on success and false otherwise.
 *
 */
bool Wildcard_match(
        Wildcard *     wildcard,  // The wildcard to match
        const char *   cstring,   // The string to match against
        const long int len,       // The length of the string
        bool casefold);           // Whether to ignore character case  


#endif

