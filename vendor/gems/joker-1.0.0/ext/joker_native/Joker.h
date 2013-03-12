#ifndef JOKER_H_GUARD
#define JOKER_H_GUARD

#include "ruby.h"


VALUE class_Wildcard;
void Init_joker(void);


/*
 * call-seq:
 *   Wildcard.new(wildcard_string, casefold = false) -> Wildcard
 *
 * Creates a new Wildcard from the given string.
 * If casefold is true, the Wildcard will ignore case.
 *
 * Raisess a SyntaxError if the given string could not
 * be interpreted as a Wildcard.
 *
 * Issues warnings to the console if the given Wildcard
 * was malformed.
 *
 */
VALUE class_method_new(int argc, VALUE * argv, VALUE klass);


/*
 * call-seq:
 *   wildcard =~  'string' -> true or false
 *   'string' =~  wildcard -> true or false
 *   wildcard === 'string' -> true or false
 *
 * Matches the Wildcard against the given string.
 *
 * NOTE: Since a wildcard has to match the whole string,
 * this method only returns true or false, not the position
 * of the match.
 *
 *   Wildcard['*fairy*'] =~  'I love fairycake'    #=> true
 *   'I love fairycake'  =~  Wildcard['*dairy*']   #=> false
 *
 *   case 'I love fairycake'
 *   when Wildcard['*fairy*'] then puts 'fairy!'
 *   else puts 'no fairy...'
 *   end
 *
 */
VALUE instance_operator_match(VALUE self, VALUE string);


#endif

