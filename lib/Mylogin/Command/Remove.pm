package Mylogin::Command::Remove;

use base qw( CLI::Framework::Command );
use v5.14;
use General;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
mylogin.pl rm [--cmd-opt] [cmd-arg]

available cmd-opt:
-i              => 'set id to remove'    

example:
mylogin.pl rm -i 2

EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    unless((defined $cmd_opts->{'i'})){
    	die "id required\n";
    }
    
}

sub option_spec {
    # The option_spec() hook in the Command Class provides the option
    # specification for a particular command.
    [ 'help|h' => 'help' ],
    [ 'i=s'    => 'set id' ],
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   $obj = General->new(pwdfile => $self->cache->get('pwdfile'),
   						id => $opts->{'i'},
   						);

   $obj->remove();

   return;
}

1;