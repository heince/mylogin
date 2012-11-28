package Mylogin::Command::Generate;

use base qw( CLI::Framework::Command );
use v5.14;
use General;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Default length is 8
Default method is char (less readable)

Usage:

mylogin.pl gen
mylogin.pl gen -l 12 -m [char/word]

EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'help'}){
        die $self->usage_text();
    }
    if(defined $cmd_opts->{l}){
    	unless($cmd_opts->{l} =~ /^\d+/){
    		die "Error: length must be numeric\n";
    	}else{
    		if($cmd_opts->{l} > 50){
    			die "Error: max length is 50\n";
    		}
    	}
    }
    if(defined $cmd_opts->{m}){
    	unless($cmd_opts->{m} =~ /\b^(word|char)\b/){
    		die "Error: Supported method is char or word\n";
    	}
    }
    
}

sub option_spec {
    # The option_spec() hook in the Command Class provides the option
    # specification for a particular command.
    [ 'help|h' => 'help' ],
    [ 'l=s'    => 'set length' ],
    [ 'm=s'    => 'set method' ],
}

sub run{
	my ($self, $opts, @args) = @_;
   
   	my $obj;
   
   	#$obj = General->new(
   	#		genlength => $opts->{'l'} if $opts->{'l'},
   	#		genmethod => $opts->{'m'} if $opts->{'m'},
   	#		);
	
	$obj = General->new();
	$obj->genlength($opts->{'l'}) if $opts->{'l'};
	$obj->genmethod($opts->{'m'}) if $opts->{'m'};
	
	$obj->generate_password();

   return;
}

1;