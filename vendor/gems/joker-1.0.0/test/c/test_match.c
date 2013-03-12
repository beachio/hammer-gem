#include <stdarg.h>
#include <stddef.h>
#include <stdbool.h>
#include <setjmp.h>
#include <cmockery.h>
#include <stdio.h>
#include <string.h>
#include <ruby.h>
#include "compile.h"
#include "Wildcard.h"

//
// Possible scenarios:
// *    empty
//      not empty
// *    contains group
//      contains fixed
//      contains wildcard
//      contains kleene
// *    casefold
//      not casefold
//


static void generic_test(wildcard_string, cstring, casefold, should_match) // {{{1
    const char *  wildcard_string;
    const char *  cstring;
    bool          casefold;
    bool          should_match;
{
    Wildcard *    wildcard;
    bool          matches;

    wildcard = Wildcard_compile(wildcard_string, strlen(wildcard_string));
    matches  = Wildcard_match(wildcard, cstring, strlen(cstring), casefold);
    assert_int_equal((int)should_match, (int)matches);

    Wildcard_free(wildcard);
}


static void test_empty(state) // {{{1
    void ** state;
{
    generic_test("", "",  false, true);
    generic_test("", "",  true,  true);
    generic_test("", "a", false, false);
    generic_test("", "a", true,  false);
}


static void test_fixed(state) // {{{1
    void ** state;
{
    generic_test("uiae", "uiae",  false, true);
    generic_test("uiae", "UIAE",  true,  true);
    generic_test("uiae", "UIAE",  false, false); // bad case
    generic_test("uiae", "",      false, false); // empty
    generic_test("uiae", "u",     false, false); // too short
    generic_test("uiae", "uiaeo", false, false); // too long
}


static void test_group(state) // {{{1
    void ** state;
{
    generic_test("[uiae]", "u",  false, true);
    generic_test("[uiae]", "U",  true,  true);
    generic_test("[uiae]", "U",  false, false); // bad case
    generic_test("[uiae]", "",   false, false); // empty
    generic_test("[uiae]", "o",  false, false); // wrong character
    generic_test("[uiae]", "ui", false, false); // too long
}


static void test_wild(state) // {{{1
    void ** state;
{
    generic_test("?",  "u",  false, true);
    generic_test("?",  "U",  true,  true);
    generic_test("?",  "",   false, false); // empty
    generic_test("?",  "ui", false, false); // too long
    generic_test("u?", "u",  false, false); // too short
    generic_test("??", "u",  false, false); // too short
}


static void test_kleene(state) // {{{1
    void ** state;
{
    generic_test("*",   "uiae",  false, true);
    generic_test("*",   "UIAE",  true,  true);
    generic_test("*",   "",      false, true);  // empty
    generic_test("*u",  "uiae",  false, false); // too short
    generic_test("*?*", "",      false, false); // too short
}


static void test_mixed(state) //{{{1
    void ** state;
{
    generic_test("_*_",   "__",      false, true);
    generic_test("_*_",   "_uiae_",  false, true);
    generic_test("_*_",   "_uiae_",  false, true);
    generic_test("_*_",   "u_ia_e",  false, false);
    generic_test("_*_",   "uiae_",   false, false);
    generic_test("_*_",   "_uiae",   false, false);
    generic_test("_*_",   "",        false, false);

    generic_test("*_*",   "_",       false, true);
    generic_test("*_*",   "uiae_",   false, true);
    generic_test("*_*",   "_uiae",   false, true);
    generic_test("*_*",   "ui_ae",   false, true);
    generic_test("*_*",   "_____",   false, true);
    generic_test("*_*",   "uiae",    false, false);
    generic_test("*_*",   "",        false, false);
}


int main() { // {{{1
    const UnitTest tests[] = {
        unit_test(test_empty),
        unit_test(test_fixed),
        unit_test(test_group),
        unit_test(test_wild),
        unit_test(test_kleene),
        unit_test(test_mixed),
    };
    return run_tests(tests);
}

