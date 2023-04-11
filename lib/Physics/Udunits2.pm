package Physics::Udunits2;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [qw(encodeTime
                              encodeClock
                              encodeDate
                              decodeTime)] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.04';

require XSLoader;
XSLoader::load('Physics::Udunits2', $VERSION);
# croak on udunits-2 internal error
installCroakHandler();

# Preloaded methods go here.
sub new {
	my ($package, $path) = @_;
	if ($path) {
		return new_system_from_path($path);
	} else {
		return new_system();
	}
}

sub decodeTime {
	my ($time) = @_;
	my ($year, $month, $day, $hour, $minute, $second, $resolution) = (0,0,0,0,0,0.,0.);
	decodeTime_($time, $year, $month, $day, $hour, $minute, $second, $resolution);
	# ignore resolution
	return ($year, $month, $day, $hour, $minute, $second); 
}


# CPAN indexer does not index xs files
# so cover packages generated by xs also here
package Physics::Udunits2::System;

package Physics::Udunits2::Unit;

package Physics::Udunits2::Converter;


1;
__END__

=head1 NAME

Physics::Udunits2 - Perl extension to Udunits2 unit system

=head1 SYNOPSIS

  use Physics::Udunits2;
  my $system = new Physics::Udunits2();
  my $mUnit = $system->getUnit("m");
  my $kmUnit = $system->getUnit("km");
  if ($mUnit->isConvertibleTo($kmUnit)) {
     my $converter = $mUnit->getConverterTo($kmUnit);
     foreach my $num (1..1000) {
  	   printf("%fm = %fkm\n", $num, $converter->convert($num));
     }
  }


=head1 DESCRIPTION

This is a perl interface to the udunits-2 package from unidata. The c-level api has been change to
a perl OO-api, i.e.
 
  ut_unit ut_get_unit_by_name(ut_system, name)

changes in perl to

  $unit = $system->getUnitByName(name)
  
Lots of information can thus be retrieved from the extensive C-Api documentation of udunits2. The following gives
only and excerpt:

=head2 Physics::Udunits Time handling

Times are stored in double, in the unit with the name 'second'. With the following functions, times can be converted
from a calendar to that double. These function can be imported with the ':all' tag.

=over 4

=item encodeTime($year, $month, $day, $hour, $minute, $second)

All values are integer, except second. Year are (usually) 4 numbers, $month is between 1 and 12, day between 1 and 31,
hour between 0 and 23, minute between 0 and 59 and seconds between 0 and 59.999999

=item encodeDate($year, $month, $day)

=item encodeClock($hour, $minute, $second)

encodeClock + encodeDate = encodeTime

=item decodeTime($timeDouble)

return ($year, $month, $day, $hour, $minute, $second)

=back

=head3 Time Conversion Example

  use Physics::Udunits2 qw(:all);
  my $system = new Physics::Udunits2();
  my @time = (1973, 6, 26, 9, 51, 0);
  my $baseTime = encodeTime(@time);
  my $tUnit = $system->getUnit("minutes since 1973-06-26 00:00:00");
  my $baseTimeUnit = $system->getUnitByName("second"); 
  print $baseTimeUnit->getConverterTo($tUnit)->convert($baseTime); # writes 591.000000xxx = 9*60 + 51 + (fractalSeconds)

=head2 L<Physics::Udunits2::System>

Methods of Physics::Udunits2::System:

=over 4

=item new Physics::Udunits2([$path])

retrieve a Physics::Udunits2::System ($system) from the file-system, if path is left empty, retrieve the default.

=item getUnit($unitString)

Parse the unitString and return Physics::Udunits2::Unit, in 99% of all cases, you want to use this function.
This is the ut_parse(ut_trim(unitString)) function in the C-API documentation.

=item getUnitByName($unitName)

retrieve a unit by the exact unitName

=item getUnitBySymbol($symbolName)

retrieve a unit by the exact base-symbol (km will not work)

=item newBaseUnit

retrieve a new unit

=item newDimensionlessUnit


=back

=head2 L<Physics::Udunits2::Unit>

After retrieving a unit from a system, you call the following methods:

=head3 Converter

=over 4

=item isConvertibleTo($otherUnit)

Check if units are convertible, return true on success.
Throws if units are from different systems.

=item getConverterTo($otherUnit)

Retrieve a L<Physics::Udunits2::Converter>, to convert from one unit to another.
Throws if units are not convertible, or from different systems.

=back

=head3 Unit Operations

The following unit operation methods all return a new unit

=over 4

=item scale($numberScale)

=item offset($numberOffset)

=item offset_by_time($numberTime)

=item invert()

=item raise($intPower)

=item root($intRoot)

=item log($numberBase)

=item multiply($unit2)

=item divide($unitDenominator)

=item clone()

=back

=head3 Unit Information

=over 4

=item getName()

return the name or undef

=item getSymbol()

return the symbol or undef

=item sameSystem($otherUnit)

check if units are from the same system.

=item isDimensionless()

=item getSystem()

=item compare($otherUnit)

return a value < 0, 0 or > 0, if the unit is <, = or > the otherUnit. The units need to be convertible.


=back


=head2 L<Physics::Udunist2::Converter>

A converter should be fetched from a L<Physics::Udunits2::Unit> 

=over 4

=item convert($number)

returns the number in the other unit of the converter

=back

=head2 EXPORT

None by default. Tag ':all' gives:

=over 4

=item encodeTime

=item encodeDate

=item encodeClock

=item decodeTime

=back

=head2 EXCEPTIONS

All errors internal to udunits are thrown with croak. Those are usually either programming errors, or system errors.
When retrieving units from a system, 

=head1 SEE ALSO

L<http://www.unidata.ucar.edu/software/udunits/>

=head1 AUTHOR

Heiko Klein, E<lt>Heiko.Klein@met.noE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Heiko Klein

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
