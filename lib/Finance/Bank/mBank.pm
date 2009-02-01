package Finance::Bank::mBank;

use warnings;
use strict;

use base 'Class::Accessor';

use Carp;
use Crypt::SSLeay;
use English '-no_match_vars';
use HTML::TableExtract;
use WWW::Mechanize;

__PACKAGE__->mk_accessors(
qw/
    userid
    password
    _mech
    _is_logged_on
    _main_content
/);

=head1 NAME

Finance::Bank::mBank - Check mBank account balance

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS


    use Finance::Bank::mBank;

    my $mbank = Finance::Bank::mBank->new(
        userid   => 555123,
        password => 'loremipsum'
    );
    for my $account ($mbank->accounts) {
        print "$account->{account_name}: $account->{balance}\n";
    }

=cut

sub new {#{{{
    my $class = shift;
    my %params = (ref $_[0] eq 'HASH' ? %{ $_[0] } : @_);

    my $self = $class->SUPER::new(\%params);

    $self->_mech( WWW::Mechanize->new() );

    return $self;
}#}}}
sub _login {#{{{
    my $self = shift;

    return if $self->_is_logged_on;
    
    if (!$self->userid or !$self->password) {
        croak "No userid or password specified";
    }

    my $mech = $self->_mech;

    $mech->get('https://www.mbank.com.pl/');
    
    # Login form
    $mech->form_number(1);
    $mech->field( customer => $self->userid );
    $mech->field( password => $self->password );
    $mech->submit;
    
    
    # Choose frame
    $mech->follow_link( name => "FunctionFrame" );
    
    croak "Login failed!"
        if $mech->content !~ /Dost.pne rachunki/;

    $self->_main_content( $mech->content );

}#}}}
sub accounts {#{{{
    my $self = shift;

    $self->_login;

    return __extract_accounts( $self->_main_content );
}#}}}
sub __extract_accounts {#{{{
    my $content = shift;

    my $te = new HTML::TableExtract( depth => 1, count => 0 );
    $te->parse($content);

    my $ts = $te->first_table_state_found();

    my @accounts;
    for my $row ($ts->rows) {
        next if $row->[5] !~ /\d+/;
        $row->[1] =~ s/\n/ /g;
        push @accounts, {account_name => $row->[1], balance => $row->[5], available => $row->[7]};
    }
    return @accounts;
}#}}}

=head1 AUTHOR

Bartek Jakubski, C<< <b.jakubski at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-finance-bank-mbank at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Finance-Bank-mBank>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Finance::Bank::mBank

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Finance-Bank-mBank>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Finance-Bank-mBank>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Finance-Bank-mBank>

=item * Search CPAN

L<http://search.cpan.org/dist/Finance-Bank-mBank>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Bartek Jakubski, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Finance::Bank::mBank
