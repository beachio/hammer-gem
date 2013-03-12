#include <malloc.h>
#include <stddef.h>
#include <Wildcard.h>



void Wildcard_free(wildcard) // {{{1
    Wildcard *  wildcard;
{
    free(wildcard->first);
    free(wildcard);
}


void Wildcard_enlarge(wildcard) // {{{1
    Wildcard *  wildcard;
{
    wildcard->length += 2;
    wildcard->first   = realloc(wildcard->first, wildcard->length * sizeof(char));
    wildcard->last    = wildcard->first + wildcard->length - 2;
}

