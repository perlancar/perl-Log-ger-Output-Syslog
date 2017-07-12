package Log::ger::Output::Syslog;

# DATE
# VERSION

use strict 'subs', 'vars';
use warnings;

our %level_map = (
    # Log::ger default level => syslog level
    # => emerg
    # => alert
    fatal => 'crit',
    error => 'err',
    warn  => 'warning',
    # => notice
    info  => 'info',
    debug => 'debug',
    trace => 'debug',
);

sub get_hooks {
    my %conf = @_;

    my $ident = delete($conf{ident});
    defined($ident) or die "Please specify ident";

    my $facility = $conf{facility} || 'user';
    $facility =~ /\A(auth|daemon|ftp|mail|user)\z/
        or die "Invalid value for facility, please choose ".
        "auth|daemon|ftp|mail|user";

    my $logopt = delete($conf{logopt});
    $logopt = "pid" unless defined $logopt;

    require Sys::Syslog;
    Sys::Syslog::openlog($ident, $logopt, $facility) or die;

    return {
        create_log_routine => [
            __PACKAGE__, 50,
            sub {
                my %args = @_;

                my $str_level = $args{str_level};
                $level_map{$str_level} or die "Don't know how to map ".
                    "Log::ger level '$str_level' to syslog level";

                my $logger = sub {
                    Sys::Syslog::syslog(
                        &{"Sys::Syslog::LOG_".uc($level_map{$str_level})},
                        $_[1],
                    );
                };
                [$logger];
            }],
    };
}

1;
# ABSTRACT: Send logs to syslog

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::ger::Output 'Syslog' => (
     ident    => 'myprog', # required
     facility => 'daemon', # optional, default 'user'
 );
 use Log::ger;

 log_warn "blah ...";


=head1 DESCRIPTION

This output plugin sends logs to syslog using L<Sys::Syslog>.


=head1 CONFIGURATION

=head2 ident

=head2 facility

=head2 logopt


=head1 SEE ALSO

L<Log::ger>

L<Sys::Syslog>
