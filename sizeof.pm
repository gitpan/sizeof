#!/usr/bin/perl

package sizeof;

use Carp;

require Exporter;
my ($VERSION);

@ISA = qw(Exporter);
@EXPORT = qw(sizeof_pack_string sizeof);
$VERSION = '1.00';

sub sizeof_pack_string ($) {
    my ($pkstr) = shift;
    my ($a, @last, $idx, $total);
    #-- aggregate multiple bit identifiers
    while ($pkstr =~ m/(([Bb])([0-9]+))/) {
        $string =  $2 x $3;
        #print "s/ $1 / $string /\n";
        $pkstr =~ s/$1/$string/;
    }
    while ($pkstr =~ m/([Bb][Bb]+)/) {
            my ($num)  = length($1);
            #print "Bits($num) : $1\n";
            $pkstr =~ s/$1/b$num/;
    }
    my @fields = split(//,$pkstr);
    foreach $a (@fields) {
        if ($a =~ m/[0-9]/) {
            $last[--$idx] .= "$a";
        } else {
            $last[$idx] = "$a";
        }
        ++$idx;
    }
    foreach my $fname (@last) {
        if ($fname =~ m/(\w)(\d+)/) {
            ($fname, $cnt) = ($1, $2);
        } else {
            $cnt = 1;
        }
        if ($fname =~ m/b/i) {
            #-- handle bit stings
            $total += &_round_up($cnt/8);
            #printf "rounded $cnt/8 to %d\n", (&_round_up($cnt/8));
            next;
        }
        my $t = size_of($fname);
        if (defined $t) {
            #print "Get size for : $fname $cnt ...";
            $total += ($t * $cnt);
            #printf "%d\n", ($t * $cnt);
        } else {
            return undef;
        }
    }
    return $total;
}

#-- internal function for rounding bit sting multiples into the next byte size (multiple of 8).
sub _round_up ($) {
    my ($inval) = shift;
    (int($inval) == $inval) ? (return $inval) : (return (int($inval) + 1));
    #return $inval if (int($inval) == $inval); ##-- whole number
    #return (int($inval) + 1);
}

#-- internal function for getting size of pack string elements.
sub size_of ($) {
    my ($out);
    eval {
        $out = ((length(unpack("b*",pack("$_[0]","1"))))/8);
    };
    if ($@) {
        croak "Unable to get size for $_[0], invalid pack identifier.";
    } else {
        #print STDERR "$_[0] : $out\n";
        return $out;
    }
}

1;
__END__
