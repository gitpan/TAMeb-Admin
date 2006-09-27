package TAMeb::Admin;
use TAMeb::Admin::ACL;
use TAMeb::Admin::Action;
use TAMeb::Admin::AuthzRule;
use TAMeb::Admin::Context;
use TAMeb::Admin::Domain;
use TAMeb::Admin::Group;
use TAMeb::Admin::Objectspace;
use TAMeb::Admin::POP;
use TAMeb::Admin::ProtObject;
use TAMeb::Admin::Server;
use TAMeb::Admin::User;        
use TAMeb::Admin::SSO::Web;
use TAMeb::Admin::SSO::Group;
use TAMeb::Admin::SSO::Cred;

$TAMeb::Admin::VERSION = '0.06';
use Inline( C => 'DATA',
	    VERSION => '0.06',
	    NAME => 'TAMeb::Admin' );

my %dispatch = ( 
    acl 	=> 'TAMeb::Admin::ACL',
    action 	=> 'TAMeb::Admin::Action',
    authzrule 	=> 'TAMeb::Admin::AuthzRule',
    context 	=> 'TAMeb::Admin::Context',
    group 	=> 'TAMeb::Admin::Group',
    objectspace	=> 'TAMeb::Admin::Objectspace',
    'pop'	=> 'TAMeb::Admin::POP',
    protobject 	=> 'TAMeb::Admin::ProtObject',
    server	=> 'TAMeb::Admin::Server',
    user 	=> 'TAMeb::Admin::User;       ',
    ssoweb	=> 'TAMeb::Admin::SSO::Web',
    ssocred	=> 'TAMeb::Admin::SSO::Cred',
);


sub new {
    my $class = shift;  # Ignore this.
    my $desired = lc shift;
    if ( defined $dispatch{ $desired } ) {
	return $dispatch{$desired}->new( @_ );
    }
    else {
	return TAMeb::Admin::Context->new( $desired, @_ );
    }
}

1;

=head1 NAME

TAMeb::Admin

=head1 SYNOPSIS

    use TAMeb::Admin

    # Do cool and wicked TAM things

=head1 DESCRIPTION

B<TAMeb::Admin> is a convenience module.  You can simply B<use> it and have
access to:

=over 4

=item L<TAMeb::Admin::Context|TAMeb::Admin::Context>

=item L<TAMeb::Admin::Response|TAMeb::Admin::Response>

=item L<TAMeb::Admin::ACL|TAMeb::Admin::ACL>

=item L<TAMeb::Admin::Action|TAMeb::Admin::Action>

=item L<TAMeb::Admin::Authzrule|TAMeb::Admin::Authzrule>

=item L<TAMeb::Admin::Group|TAMeb::Admin::Group>

=item L<TAMeb::Admin::Objectspace|TAMeb::Admin::Objectspace>

=item L<TAMeb::Admin::POP|TAMeb::Admin::POP>

=item L<TAMeb::Admin::ProtObject|TAMeb::Admin::ProtObject>

=item L<TAMeb::Admin::Server|TAMeb::Admin::Server>

=item L<TAMeb::Admin::User|TAMeb::Admin::User>

=item L<TAMeb::Admin::SSO::Web|TAMeb::Admin::SSO::Web>

=item L<TAMeb::Admin::SSO::Cred|TAMeb::Admin::SSO::Cred>

Each of these objects provide access to the equivalent calls in the TAM API.
See the documentation for each of these modules for more information.

=over 4

=head1 Unimplemented

You may have noticed from the previous list that I have not yet implemented
the full API.  I still need to write:

=over 4

=item B<TAMeb::Admin::Config>

This module will be written, but I just haven't gotten there yet.

=item B<TAMeb::Admin::AccessOutdata>

=item B<TAMeb::Admin::Context::cleardelcred>

=item B<TAMeb::Admin::Context::hasdelcred>

=item B<TAMeb::Admin::ProtObject::access>

=item B<TAMeb::Admin::ProtObject::multiaccess>

The first is a class and the following are methods.  They are not implemented
due to my own ignorance.  I vaguely understand what they are supposed to do,
but I just cannot figure out how to implement them.

=back

=head1 TODO

=over 4

=item *

Implement the missing objects

=item *

Basic clean up.  Most of this code was written as I was learning.  I think you
can see my style evolve from B<TAMeb::Admin::Context> to
B<TAMeb::Admin::User>.  I would like to make it consistent.

=head1 SEE ALSO

L<TAMeb::Admin::Context|TAMeb::Admin::Context>, L<TAMeb::Admin::Response|TAMeb::Admin::Response>, L<TAMeb::Admin::ACL|TAMeb::Admin::ACL>, L<TAMeb::Admin::Action|TAMeb::Admin::Action>, L<TAMeb::Admin::Authzrule|TAMeb::Admin::Authzrule>, L<TAMeb::Admin::Group|TAMeb::Admin::Group>, L<TAMeb::Admin::Objectspace|TAMeb::Admin::Objectspace>, L<TAMeb::Admin::POP|TAMeb::Admin::POP>, L<TAMeb::Admin::ProtObject|TAMeb::Admin::ProtObject>, L<TAMeb::Admin::Server|TAMeb::Admin::Server>, L<TAMeb::Admin::User|TAMeb::Admin::User>, L<TAMeb::Admin::SSO::Web|TAMeb::Admin::SSO::Web>, L<TAMeb::Admin::SSO::Cred|TAMeb::Admin::SSO::Cred>

=head1 ACKNOWLEDGEMENTS

None of this would have been possible if not for Brian Ingerson's B<Inline::C>.

Major thanks to Michael G Schwern's B<Test::More> -- the code would have been
a lot buggier without running everything through Test::More.

An equal share of thanks and curses goes to Paul Johnson for B<Devel::Cover>.
I cannot count the number of bugs this module helped me find or the number of
times I cursed it for keeping me up to 3:00 am saying "I will go to bed after
I get just one more percent branch coverage".  Those who use it know what I mean.

=head1 BUGS

None known yet.

=head1 AUTHOR

Mik Firestone E<lt>mikfire@gmail.comE<gt>

=head1 COPYRIGHT

Copyright (c) 2004-2011 Mik Firestone.  All rights reserved.  This program is
free software; you can redistibute it and/or modify it under the same terms as
Perl itself.

All references to TAM, Tivoli Access Manager, etc are copyrighted, trademarked
and otherwise patented by IBM.

=cut

__DATA__

__C__

int silly() {
    printf("Go away\n");
    return(0);
}

