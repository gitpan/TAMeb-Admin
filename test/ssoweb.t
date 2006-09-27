#!/usr/bin/perl
# vim: set filetype=perl:
use strict;
use warnings;
use Term::ReadKey;
use Data::Dumper;

use Test::More qw/no_plan/;

BEGIN {
    use_ok( 'TAMeb::Admin' );
    use_ok( 'TAMeb::Admin::SSO::Web' );
}

ReadMode 2;
print "sec_master password: ";
my $pswd = <STDIN>;
ReadMode 0;
chomp $pswd;
print "\n";

print "\nTESTING new\n";
my $pd = TAMeb::Admin->new( password => $pswd);
my $sso = TAMeb::Admin::SSO::Web->new( $pd, name => 'twiki' );
my $resp;

isa_ok($sso, "TAMeb::Admin::SSO::Web");
is($sso->name, 'twiki', "Retrieved the name");

$sso = TAMeb::Admin::SSO::Web->new($pd,name => 'twiki',description => 'test');
isa_ok($sso, "TAMeb::Admin::SSO::Web");
is($sso->name, 'twiki', "Retrieved the name");
is($sso->description, 'test', "Retrieved the description");

$sso = TAMeb::Admin::SSO::Web->new($pd,'twiki');
isa_ok($sso, "TAMeb::Admin::SSO::Web");
is($sso->name, 'twiki', "Retrieved the name w/o using a hash");

print "\nTESTING create and delete\n";
$resp = $sso->create();
is($resp->isok,1,'Created a resource with name and desc embedded');

$resp = $sso->create();
is($resp->iswarning,1,'Was warned about creating an existing resource');

$resp = $sso->delete();
is($resp->isok,1, 'Deleted the resource') or diag(Dumper($resp));

$resp = $sso->delete();
is($resp->isok,0, 'Could not delete a resource that does not exist');

$sso = TAMeb::Admin::SSO::Web->new( $pd, name => 'twiki' );
$resp = $sso->create;
is($resp->isok,1,'Created a resource with name only');
is($sso->name,'twiki','Got the name back');
is($sso->description, '', 'And no description');
$resp = $sso->delete();

$sso = TAMeb::Admin::SSO::Web->new($pd);
$resp = $sso->create('twiki');
is($resp->isok,1,'Created a resource with name only and no hash');
is($sso->name,'twiki','Got the name back');
is($sso->description, '', 'And no description');
$resp = $sso->delete();

$sso = TAMeb::Admin::SSO::Web->new($pd);
$resp = $sso->create(name => 'twiki', description => 'test');
is($resp->isok,1,'Created a resource with name and description');
is($sso->name,'twiki','Got the name back');
is($sso->description, 'test', 'And the description');
$resp = $sso->delete();

$resp = TAMeb::Admin::SSO::Web->create($pd, name => 'twiki');
is($resp->isok,1,'Finally, created as a class method');
isa_ok($resp->value,'TAMeb::Admin::SSO::Web');
$sso = $resp->value;
is($sso->name,'twiki','Got the name back');
$resp = $sso->delete;

print "\nTESTING list\n";

$resp = TAMeb::Admin::SSO::Web->create($pd, name => 'twiki');
$sso = $resp->value;

$resp = TAMeb::Admin::SSO::Web->list($pd, name => 'twiki');
is($resp->isok,1,'Called list as a class method');
is(scalar($resp->value), 'twiki', "And found twiki");

$resp = $sso->list;
is($resp->isok,1,'Called list as an instance method');
is(scalar($resp->value), 'twiki', "And found twiki");

$resp = $sso->delete;
print "\nTESTING breakage\n";

$sso = TAMeb::Admin::SSO::Web->new();
is($sso,undef,"Couldn't create a resource w/o a context");
$sso = TAMeb::Admin::SSO::Web->new('wiki');
is($sso,undef,"Couldn't create a resource with something that isn't a context");
$sso = TAMeb::Admin::SSO::Web->new($pd, qw/one two three/);
is($sso,undef,"Couldn't send an odd number of parameters");

$resp = TAMeb::Admin::SSO::Web->create();
is($resp->isok,0,"create() fails when new() fails");
$resp = TAMeb::Admin::SSO::Web->create($pd, qw/one two three/);
is($resp->isok,0,"Couldn't send an odd number of parameters");
$resp = TAMeb::Admin::SSO::Web->create($pd);
is($resp->isok,0,"Couldn't create an unnamed resource");

$sso = TAMeb::Admin::SSO::Web->new($pd);
$resp = $sso->create(qw/one two three/);
is($resp->isok,0,"Couldn't send an odd number of parameters");

my $name = $sso->name;
is($name,'', 'Got no name from an nonexistant resource');
