#ifndef COMPILE_H_GUARD
#define COMPILE_H_GUARD

#include "Wildcard.h"


/*
 * Compiles an input string to the internal Wildcard
 * represenation.
 *
 */
Wildcard * Wildcard_compile(const char * cstring, const long int len);


#endif

