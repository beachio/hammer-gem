#
# Joker is a simple Wildcard implementation that works much like Regexps.
#

require File.join( File.dirname( File.expand_path(__FILE__)), 'joker_native')

#
# Implements wildcards for Ruby. Modeled after the Regexp class.
#
# This implementation supports the following special characters:
#
# - ?      matches a single character
# - *      matches any number of characters, including 0
# - \\*    matches a literal '*'
# - \\?    matches a literal '?'
# - \\\\   matches a literal '\\'
# - [xyz]  matches either 'x', 'y' or 'z'. NOTE that you have
#          to escape ']' in these groups: \\] 
#
# NOTE that '\\a' will match the literal string '\\a', not 'a' as
# one might expect.
#
#   wild = Wildcard['Fairy?ake*']
#   wild =~ 'Fairycake'                     #=> true
#   wild =~ 'Fairyfakes are mean'           #=> true
#   wild =~ 'Fairysteakes are delicious'    #=> false
#
# Also there is a case sensitivity flag. By default it is set to true,
# but it can be turned off at construction time:
#
#   wild = Wildcard['Fairy?ake*', true]
#   wild =~ 'Fairycake'
#   wild =~ 'fairyCAKE'
#   wild =~ 'FaIrYfAkEs, the Movie'
#
# Furthermore, any given Wildcard expression must match the whole string:
#
#   wild = Wildcard['Fairy?ake']
#   wild =~ 'some Fairycake'                #=> false
#   wild =~ 'Fairycake is good for you'     #=> false
#
class Wildcard

    #
    # Boolean. Determines case sensitivity of the Wildcard.
    #
    # If this is true, the Wildcard will ignore case.
    #
    attr_reader :casefold

    #
    # The string from which the Wildcard was constructed.
    #
    attr_reader :source

    #
    # Creates a new Wildcard from the given string.
    # If casefold is true, the Wildcard will ignore case.
    # TODO
    #
    def initialize( wildcard_string, casefold = false )
        @source   = wildcard_string
        @casefold = casefold
        @regexp   =
            if casefold then Regexp.new(compile, Regexp::IGNORECASE)
            else             Regexp.new(compile)
            end
    end

    class << self

        #
        # Returns a new string with any characters escaped that would have
        # special meaning in a Wildcard.
        #
        def quote( string )
            string.gsub(%r{[\\?*\[\]]}) { |char| "\\#{char}" }
        end

        alias_method :[], :new
        alias_method :compile, :new
        alias_method :escape, :quote

    end

    def inspect
        %{Wildcard[#{self.source.inspect}]#{self.casefold ? 'i' : ''}}
    end

    #
    # Matches the wildcard against $_:
    #
    #   $_ = 'I love fairycakes'
    #   ~Wildcard['*fairy*']        #=> true
    #
    def ~
        self =~ $_
    end

    #
    # Compares to Wildcards for equality.
    #
    # Two wildcards are equal, if they were constructed from the
    # same string and have the same #casefold?().
    #
    def eql?( that )
        return false unless that.is_a?(Wildcard)
        self.source == that.source && self.casefold == that.casefold
    end

    alias_method :==, :eql?
    alias_method :casefold?, :casefold

end

