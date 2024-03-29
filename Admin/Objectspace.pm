package TAMeb::Admin::Objectspace;
use Carp;
use strict;
use warnings;

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# $Id: Objectspace.pm 296 2006-09-27 15:22:32Z mik $
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$TAMeb::Admin::Objectspace::VERSION = '0.06';
use Inline(C => 'DATA',
		INC  => '-I/opt/PolicyDirector/include',
                LIBS => ' -lpthread  -lpdadminapi -lstdc++',
		CCFLAGS => '-Wall',
		VERSION => '0.06',
		NAME => 'TAMeb::Admin::Objectspace',
	  );
use TAMeb::Admin::Response;
use TAMeb::Admin::ProtObject;

my %obj_types = ( unknown       => 0,
		  domain        => 1,
		  file          => 2,
		  program       => 3,
		  dir           => 4,
		  junction      => 5,
		  webseal       => 6,
		  nonexist      => 10,
		  container     => 11,
		  leaf          => 12,
		  port	        => 13,
		  app_container => 14,
		  app_leaf      => 15,
		  mgmt_object   => 16,
	  );

my %rev_obj_types = map { $obj_types{$_} => $_ } keys %obj_types;

sub new {
    my $class = shift;
    my $cont  = shift;
    unless ( defined($cont) and UNIVERSAL::isa($cont,'TAMeb::Admin::Context' ) ) {
	warn "Incorrect syntax -- did you forget the context?\n";
	return undef;
    }

    my $self  = bless {}, $class;
    if ( @_ % 2 ) {
	warn "Invalid syntax\n";
	return undef;
    }
    my %opts  = @_;

    $self->{name}    = $opts{name} || '';
    $self->{desc}    = $opts{description} || '';
    $self->{exist}   = 0;
    $self->{context} = $cont;

    if ( defined $opts{type} ) {
	if ( $opts{type} =~ /^\d+$/ ) {
	    if ( defined $rev_obj_types{$opts{type}} ) {
		$self->{type} = $rev_obj_types{$opts{type}};
	    }
	    else {
		carp( "Unknown object type $opts{type}" );
		$self->{type} = 'unknown';
	    }
	}
	else {
	    if ( defined $obj_types{$opts{type}} ) {
		$self->{type} = $obj_types{$opts{type}};
	    }
	    else {
		carp( "Unknown object type $opts{type}" );
		$self->{type} = 'unknown';
	    }
	}
    }


    # If we were givin a name, lets see if the protected object exists and
    # preload the info.  I don't think this works.  Oh, I wish somebody could
    # explain to me why an objectspace is useful.
#    if ( $self->{name} ) {
#	my $pobj = TAMeb::Admin::ProtObject->new( $self->{context},
#					        name => $self->{name} );
#	if ( $pobj->exist ) {
#	    my $resp;
#	    $resp = $pobj->type;
#	    $self->{type} = $resp->value if $resp->isok;
#	    $resp = $pobj->description;
#	    $self->{desc} = $resp->value if $resp->isok;
#	    $self->{exist} = 1;
#	}
#    }
    return $self;
}

sub create {
    my $self = shift;
    my $resp = TAMeb::Admin::Response->new;

    unless ( ref $self ) {
	my $pd = shift;
	$self = new( $self, $pd, @_ );
    }

    if ( @_ % 2 ) {
	$resp->set_message("Invalid syntax");
	$resp->set_isok(0);
	return $resp;
    }
    my %opts = @_;

    if ( $self->exist ) {
	$resp->set_message( $self->{name} . " already exists" );
	$resp->set_iswarning(1);

	return $resp;
    }
	
    unless ( $self->{name} ) {
	$self->{name} = $opts{name} || '';
    }

    unless ( $self->{type} ) {
	$self->{type} = 'unknown';
    }

    if ( $self->{name} ) {
	my $rc = $self->objectspace_create( $resp, $obj_types{$self->{type}} );
	$resp->isok and $resp->set_value($rc);
	$self->{exist} = $resp->isok;
    }
    else {
	$resp->set_message("create syntax error");
	$resp->set_isok(0);
    }
    return $resp;
}

sub delete {
    my $self = shift;
    my $resp = TAMeb::Admin::Response->new;
    my $rc;

    unless ( $self->{name} ) {
	$resp->set_message("delete syntax error");
	$resp->set_isok(0);
	return $resp;
    }

    $rc = $self->objectspace_delete( $resp );
    $resp->isok and $resp->set_value($rc);

    return $resp;
}

sub list {
    my $self = shift;
    my $pd;
    my $resp = TAMeb::Admin::Response->new;
    my @rc;


    if ( ref($self) ) {
	$pd = $self->{context};
    }
    else {
	$pd = shift;
    }

    @rc = objectspace_list($pd, $resp);
    $resp->isok and $resp->set_value(\@rc);

    return $resp;
}

sub exist { return $_[0]->{exist}; }
1;

=head1 NAME

TAMeb::Admin::Objectspace

=head1 SYNOPSIS
   use TAMeb::Admin

   my $resp;
   my $pd = TAMeb::Admin->new( password => 'N3ew0nk!' );
   my $ospace = TAMeb::Admin::Objectspace->new( $pd, name => '/test',
					      type => 'container',
					      desc => 'Test objectspace',
					    );
   # Create the objectspace if it doesn't exist
   unless ( $ospace->exist ) {
       $resp = $ospace->create()
   }

   # Delete the objectspace
   $ospace->delete;

   # List all the objectspaces
   $resp = $ospace->list;
   print @{$resp->value}, "\n";

=head1 DESCRIPTION

B<TAMeb::Admin::Objectspace> provides the interface to the objectspace portion
of the TAM APIs.

=head1 CONSTRUCTOR

=head2 new( PDADMIN[, name =E<gt> NAME, type =E<gt> TYPE, desc => STRING] )

Creates a blessed B<TAMeb::Admin::Objectspace> object and returns it.

=head3 Parameters

=over 4

=item PDADMIN

An initialized L<TAMeb::Admin::Context> object.  Please note that, after the
L<TAMeb::Admin::Objectspace> object is created, you cannot change the context
w/o destroying the object and recreating it.

=item name =E<gt> NAME

The name of the objectspace to be created.  I believe it needs to start with a
/, but I don't know for certain.

=item type =E<gt> TYPE

The type of the objectspace.  This can either be a numeric value as defined in
the TAM Admin guide, or it may be a word.  I have not defined the unused
object types.  The mapping between names and values looks like this:
    unknown       => 0
    domain        => 1
    file          => 2
    program       => 3
    dir           => 4
    junction      => 5
    webseal       => 6
    nonexist      => 10
    container     => 11
    leaf          => 12
    port	  => 13
    app_container => 14
    app_leaf      => 15
    mgmt_object   => 16

=item desc =E<gt>  STRING

A description.

=back

=head3 Returns

A fully blessed L<TAMeb::Admin::Objectspace> object.

=head1 METHODS

You should know this by now, but all of the methods return a
L<TAMeb::Admin::Response> object.  See the documentation for that module to
learn how to coax the values out.

=head2 create([ PDADMIN, name =E<gt> NAME, desc =E<gt> STRING, type =E<gt> TYPE ])

B<create> creates a new objectspace.  It can be used as a constructor.  The
parameters are only required in that instance.

=head3 Parameters

See L<TAMeb::Admin::Objectspace::new> for the discussion and description.

=head3 Returns

If used as a contructor, a fully blessed L<TAMeb::Admin::Objectspace> object.
Otherwise, the success or failure of the create operation.

=head2 delete

Deletes an objectspace.

=head3 Parameters

None

=head3 Returns

The success or failure of the operation.

=head2 list([PDADMIN])

Lists all of the objectspaces in the domain.  This can be used as either an
instance method ( $self=E<gt>list ) or a class method (
TAMeb::Admin::Objectspace=E<gt>list ).

=head3 Parameters

=over 4

=item PDADMIN

A fully blessed L<TAMeb::Admin::Context> object.  This is required only when B<list>
is being used as a class method.

=back

=head3 Returns

A list of all the objectspaces defined in the domain.

=head1 ACKNOWLEDGEMENTS

See L<TAMeb::Admin> for the complete list of credits.

=head1 BUGS

None known 

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

#include "ivadminapi.h"

ivadmin_response* _getresponse( SV* self ) {
    HV* self_hash = (HV*) SvRV(self);
    SV** fetched = hv_fetch(self_hash,"response",8,0);
    ivadmin_response* rsp;

    if ( fetched == NULL ) {
	croak("Couldn't fetch the _response in $self");
    }
    rsp = (ivadmin_response*) SvIV(*fetched);

    fetched = hv_fetch( self_hash, "used",4,0);
    if ( fetched ) {
	sv_setiv( *fetched, 1 );
    }
    return( rsp );
}

static ivadmin_context* _getcontext( SV* self ) {
    HV* self_hash = (HV*) SvRV(self);
    SV** fetched = hv_fetch(self_hash,"context", 7, 0 );

    if ( fetched == NULL ) {
	croak("Couldn't get context");
    }
    return( (ivadmin_context*)SvIV(SvRV(*fetched)) );
}

static char* _getname( SV* self ) {
    HV* self_hash = (HV*) SvRV(self);
    SV** fetched  = hv_fetch(self_hash, "name", 4, 0 );

    return( fetched ? SvPV_nolen(*fetched) : NULL );
}

char* _fetch( SV* self, char* key ) {
    HV* self_hash = (HV*)SvRV(self);
    SV** fetched  = hv_fetch( self_hash, key, strlen(key), 0 );

    return( fetched ? SvPV_nolen( *fetched ) : NULL );
}

int objectspace_create( SV* self, SV* resp, int code ) {
    ivadmin_context* ctx  = _getcontext( self );
    ivadmin_response* rsp = _getresponse( resp );
    char *name = _getname(self);
    char *descr = _fetch( self, "description" );

    unsigned long rc;

    if ( name == NULL )
	croak("objectspace_create: could not retrieve objectspace name");

    if ( descr == NULL )
	descr = "";

    rc = ivadmin_objectspace_create( *ctx, name, code, descr, rsp );
    return( rc == IVADMIN_TRUE );
}

int objectspace_delete( SV* self, SV* resp ) {
    ivadmin_context* ctx  = _getcontext( self );
    ivadmin_response* rsp = _getresponse( resp );
    char *name = _getname(self);

    unsigned long rc;

    if ( name == NULL )
	croak("objectspace_delete: could not retrieve objectspace name");

    rc = ivadmin_objectspace_delete( *ctx, name, rsp );
    return( rc == IVADMIN_TRUE );
}

void objectspace_list( SV* pd, SV* resp ) {
    ivadmin_context* ctx  = (ivadmin_context*) SvIV(SvRV(pd));
    ivadmin_response* rsp = _getresponse( resp );

    unsigned long count;
    unsigned long rc;
    unsigned long i;

    char **objspace;

    Inline_Stack_Vars;
    Inline_Stack_Reset;

    rc = ivadmin_objectspace_list( *ctx,
				   &count,
				   &objspace,
				   rsp );

    if ( rc == IVADMIN_TRUE ) {
	for ( i=0; i < count; i++ ) {
	    Inline_Stack_Push(sv_2mortal(newSVpv(objspace[i],0)));
	    ivadmin_free( objspace[i] );
	}
    }
    Inline_Stack_Done;
}
