#ifndef WILDCARD_H_GUARD
#define WILDCARD_H_GUARD


/*
 * The different kinds of Wildcard components.
 *
 */
typedef enum {
    Kleene  = 0,
    Fixed   = 1,
    Group   = 2,
    Wild    = 3,
    EOW     = 4,   // only used in matching
} WildcardType;

/*
 * Represents a Wildcard internally.
 *
 */
typedef struct {
    char *   first;     // The first Wildcard part (points to the first of the 2 chars)
    char *   last;      // The last Wildcard part (points to the first of the 2 chars)
    long int length;    // How many chars there are (not parts!)
} Wildcard;


void Wildcard_free(Wildcard * wildcard);


/*
 * Adds two additional characters at the end
 * and adjusts all the pointers.
 *
 */
void Wildcard_enlarge(Wildcard * wildcard);


#endif

