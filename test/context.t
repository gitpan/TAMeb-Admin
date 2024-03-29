#!/usr/bin/perl
# vim: set filetype=perl:
use strict;
use warnings;
use Term::ReadKey;
use Test::More tests => 79;

BEGIN {
    use_ok('TAMeb::Admin');
}
my ($resp, $oldvalue );
ReadMode 2;
print "sec_master password: ";
my $pswd = <STDIN>;
ReadMode 0;
chomp $pswd;

my $pd = TAMeb::Admin->new( password => $pswd);
isa_ok( $pd, 'TAMeb::Admin::Context', "Created a context");

print "\nTESTING accexpdate\n";
$resp = $pd->accexpdate();
$oldvalue = $resp->value;
ok( ($oldvalue =~/^\d+$/ or $oldvalue eq 'unset' or $oldvalue eq 'unlimited'), "Storing accexpdate:$oldvalue" );

$resp = $pd->accexpdate('unset');
is( $resp->value , 'unset', "Setting expiration date to 'unset'" );

$resp = $pd->accexpdate('unlimited');
is( $resp->value ,'unlimited', "Setting expiration date to 'unlimited'" );

my $secs = time + (86400*2);
$resp = $pd->accexpdate($secs); 
ok( $resp->value == $secs, "Setting expiration date two days from now" );

$resp = $pd->accexpdate( lifetime => $oldvalue );
is( $resp->value ,$oldvalue , "Restoring accexpdate:$oldvalue");

$resp = $pd->accexpdate( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );

print "\nTESTING disabletimeint\n";
$resp = $pd->disabletimeint();
$oldvalue = $resp->value;
ok( ($oldvalue =~ /^\d+$/ or $oldvalue eq 'unset' or $oldvalue eq 'disabled'), 
    "Storing disabletimeint:$oldvalue" );

$resp = $pd->disabletimeint( 'unset' );
is( $resp->value , 'unset', "Setting disable time interval to 'unset'" );

$resp = $pd->disabletimeint( 'disable' );
is( $resp->value ,'disabled', "Setting disable time interval to 'disable'" );

$secs = 3600;
$resp = $pd->disabletimeint( $secs ); 
ok( $resp->value == $secs, "Setting disable time interval to 3600 seconds" );

$resp = $pd->disabletimeint( seconds => $oldvalue );
is( $resp->value ,$oldvalue, "Restoring disabletimeint: $oldvalue" );

$resp = $pd->disabletimeint( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );

print "\nTESTING maxlgnfails\n";
$resp = $pd->maxlgnfails();
$oldvalue = $resp->value;
ok( ($oldvalue =~ /^\d+$/ or $oldvalue eq 'unset'), "Storing maxlgnfails: $oldvalue" );

$resp = $pd->maxlgnfails( 'unset' );
is( $resp->value , 'unset', "Setting max login failures to 'unset'" );

$resp = $pd->maxlgnfails( 5 );
ok( $resp->value == 5, "Setting max login failures to 5" );

$resp = $pd->maxlgnfails( failures => $oldvalue );
is( $resp->value ,$oldvalue, "Restoring maxlgnfails: $oldvalue" );

$resp = $pd->maxlgnfails( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );

print "\nTESTING maxpwdage\n";
$resp = $pd->maxpwdage();
$oldvalue = $resp->value;
ok( ($oldvalue =~ /^\d+$/ or $oldvalue eq 'unset'), "Storing maxpwdage: $oldvalue" );

$resp = $pd->maxpwdage( 'unset' );
is( $resp->value , 'unset', "Setting max password age to 'unset'" );

$secs = 86400*30;
$resp = $pd->maxpwdage( $secs );
ok( $resp->value == $secs, "Setting max password age to 30 days" );

$resp = $pd->maxpwdage( seconds => $oldvalue );
is( $resp->value ,$oldvalue, "Restoring maxpwdage: $oldvalue" );

$resp = $pd->maxpwdage( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );

print "\nTESTING maxpwdrepchars\n";
$resp = $pd->maxpwdrepchars();
ok( ($oldvalue =~ /^\d+$/ or $oldvalue eq 'unset'), "Storing maxpwdrepchars: $oldvalue" );

$resp = $pd->maxpwdrepchars( 'unset' );
is( $resp->value , 'unset', "Setting max password repeat chars to 'unset'" );

$resp = $pd->maxpwdrepchars( 5 );
ok( $resp->value == 5, "Setting max password repeat chars to 5" );

$resp = $pd->maxpwdrepchars( chars => $oldvalue );
is( $resp->value ,$oldvalue, "Restoring maxpwdrepchars: $oldvalue" );

$resp = $pd->maxpwdrepchars( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );

print "\nTESTING minpwdalphas\n";
$resp = $pd->minpwdalphas();
$oldvalue = $resp->value;
ok( ($oldvalue =~ /^\d+$/ or $oldvalue eq 'unset'),"Storing minpwdalphas: $oldvalue" );

$resp = $pd->minpwdalphas( 'unset' );
is( $resp->value , 'unset' , "Setting min password alphas to 'unset'" );

$resp = $pd->minpwdalphas( 5 );
ok( $resp->value == 5 , "Setting min password alphas to 5" );

$resp = $pd->minpwdalphas( chars => $oldvalue );
is( $resp->value ,$oldvalue,"Restoring minpwdalphas: $oldvalue"  );

$resp = $pd->minpwdalphas( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );


print "\nTESTING minpwdnonalphas\n";
$resp = $pd->minpwdnonalphas();
$oldvalue = $resp->value;
ok( ($oldvalue =~ /^\d+$/ or $oldvalue eq 'unset'), 
    "Storing minpwdnonalphas: $oldvalue");

$resp = $pd->minpwdnonalphas( 'unset' );
is( $resp->value , 'unset', "Setting min password nonalphas to 'unset'" );

$resp = $pd->minpwdnonalphas( 5 );
ok( $resp->value == 5, "Setting min password nonalphas to 5" );

$resp = $pd->minpwdnonalphas( chars => $oldvalue );
is( $resp->value ,$oldvalue, "Restoring minpwdnonalphas: $oldvalue" );

$resp = $pd->minpwdnonalphas( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );


print "\nTESTING minpwdlen\n";
$resp = $pd->minpwdlen();
$oldvalue = $resp->value;
ok( ($oldvalue =~ /^\d+$/ or $oldvalue eq 'unset'), 
    "Storing minpwdlen: $oldvalue" );

$resp = $pd->minpwdlen( 'unset' );
is( $resp->value , 'unset' , "Setting min password length to 'unset'" );

$resp = $pd->minpwdlen( 5 );
ok( $resp->value == 5 , "Setting min password length to 5" );

$resp = $pd->minpwdlen( chars => $oldvalue );
is( $resp->value ,$oldvalue, "Restoring minpwdlen: $oldvalue" );

$resp = $pd->minpwdlen( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );

print "\nTESTING pwdspaces\n";
$resp = $pd->pwdspaces();
$oldvalue = $resp->value;
ok( ($oldvalue =~ /^\d+$/ or $oldvalue eq 'unset'),
    "Storing pwdspaces: $oldvalue");

$resp = $pd->pwdspaces( 'unset' );
is( $resp->value , 'unset' , "Setting password spaces to 'unset'" );

$resp = $pd->pwdspaces( 1 );
ok( $resp->value  == 1, "Setting password spaces to 'allowed'" );

$resp = $pd->pwdspaces( allowed => $oldvalue );
is( $resp->value ,$oldvalue, "Restoring pwdspaces: $oldvalue" );

$resp = $pd->pwdspaces( sillybastard => $oldvalue );
is( $resp->value ,$oldvalue , "Hash call gone bad ... worked?" );

print "\nTESTING tod\n";
$resp = $pd->tod();
$oldvalue = $resp->value;
ok( ref $oldvalue, "Storing tod" );

my $stuff = { days => [qw/mon/], start => 900, end => 1720, reference => 'local' };
$resp = $pd->tod( %$stuff );
my $ref = $resp->value;
is_deeply( $ref, $stuff , 
        "Setting time of day access to monday between 0900 and 1720" );

$resp = $pd->tod( days => 'unset' );
$ref = $resp->value;
ok( $ref->{unset} , "Setting time of day access to 'unset'" );

$stuff->{days} = ['any'];
$resp = $pd->tod( %$stuff );
is_deeply( scalar($resp->value), $stuff, "Setting time of day access to any" );

$stuff->{days} = ['mon'];
$resp = $pd->tod( days => 2, start => 900, end => 1720 );
is_deeply( scalar($resp->value), $stuff, "Setting time of day access to an valid bitmask") or diag( $resp->messages );

$stuff->{days} = ['mon'];
$stuff->{start} = 0;
$resp = $pd->tod( days => 2, end => 1720 );
is_deeply( scalar($resp->value), $stuff, "Setting time of day access from 0 hundred monday to 1720") or diag( $resp->messages );

$resp = $pd->tod( days => 128, start => 900, end => 1720 );
is( $resp->isok, 0, "Setting time of day access to an invalid bitmask failed");

if  ( $oldvalue->{unset} ) {
    $resp = $pd->tod( days => 'unset' );
}
else {
    $resp = $pd->tod( %{$oldvalue} );
}
is_deeply( $oldvalue, scalar($resp->value), "Restoring tod" );

print "\nTESTING read-only functions\n";
$resp = $pd->userreg;
is ( $resp->isok, 1, "User registry is: " . $resp->value );

$resp = $pd->codeset;
ok( ( $resp->value eq "UTF8" or $resp->value eq "LOCAL" ), $resp->value . " codepage in use" );

print "\nTESTING invalid logins\n";
my $mikfire = TAMeb::Admin::Context->new( userid   => 'mik', 
					password => 'foobard',
					domain   => 'Default' );

isa_ok( $mikfire, 'TAMeb::Admin::Context', "Created a context") 
    or diag($mikfire);
$mikfire = undef;  # Destroy the context

$mikfire = TAMeb::Admin::Context->new( userid   => 'mik', 
			  	     domain   => 'Default' );
is( $mikfire, undef, "Sending no password failed" );
$mikfire = undef;  # Destroy the context

$mikfire = TAMeb::Admin::Context->new( userid   => 'mikfire', 
				     password => "",
				     domain   => 'Default' );
is( $mikfire, undef, "Sending null password failed" );
$mikfire = undef;  # Destroy the context

print "\nTESTING the hard way\n";
$mikfire = TAMeb::Admin::Context->new( userid   => 'sec_master', 
				     password => 'foobard',
				     domain   => 'Default',
				     codeset  => 'local',
				     server   => 'gir',
				     port     => 7135,
				     keyringfile  => "/var/PolicyDirector/keytab/pd.kdb",
				     keystashfile => "/var/PolicyDirector/keytab/pd.sth",
				     configfile   => '/opt/PolicyDirector/etc/pd.conf' );
isa_ok( $mikfire, 'TAMeb::Admin::Context', "Created a context the hard way");
$resp = $pd->pwdspaces();
ok( ($resp->value =~ /^\d+$/ or $resp->value eq 'unset'), "Context is valid") or diag( $resp->messages );


$mikfire = TAMeb::Admin::Context->new( userid   => 'mikfire', 
				     password => 'foobard',
				     domain   => 'Default',
				     codeset  => 'local',
				     server   => 'gir',
				     port     => 7135,
				     configfile   => '/opt/PolicyDirector/etc/pd.conf' );

is( $mikfire, undef, "Not enough parameters for the hardway failed" );
$mikfire = undef;  # Destroy the context

print "\nTESTING local context\n";

my $loc = TAMeb::Admin::Context->new( local => 1 );
isa_ok( $loc, 'TAMeb::Admin::Context', "Created local context" );

$loc = TAMeb::Admin::Context->new( local => 1, codeset => 'UTF8' );
isa_ok( $loc, 'TAMeb::Admin::Context', "Created local context with UTF8 codeset" );

print "\nTESTING breakage\n";
$mikfire = TAMeb::Admin::Context->new( userid   => 'mik', 
				     password => 'foobard',
				   );

$resp = $mikfire->accexpdate( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to accexpdate failed");

$resp = $mikfire->disabletimeint( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to disabletimeint failed");

$resp = $mikfire->maxlgnfails( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to maxlgnfails failed");

$resp = $mikfire->maxpwdage( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to maxpwdage failed");

$resp = $mikfire->maxpwdrepchars( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to maxpwdrepchars failed");

$resp = $mikfire->minpwdalphas( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to minpwdalphas failed");

$resp = $mikfire->minpwdnonalphas( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to minpwdnonalphas failed");

$resp = $mikfire->minpwdlen( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to minpwdlen failed");

$resp = $mikfire->pwdspaces( 1000, 1000, 1000 );
is($resp->isok, 0, "Odd number of elements in the call to pwdspaces failed");

$resp = $mikfire->tod(1000);
is($resp->isok, 0, "Odd number of elements in the call to tod failed");

$mikfire = TAMeb::Admin::Context->new( 'foo' );
is($mikfire, undef, "Odd number of elements in call to new failed");

$mikfire = '';
$mikfire = TAMeb::Admin::Context->new( name => 'mik', password => 'b1t3me' );
is($mikfire, undef, "Bad password failed");


END {
    ReadMode 0;
}
