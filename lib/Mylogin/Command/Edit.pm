package Mylogin::Command::Edit;

use base qw( CLI::Framework::Command );
use v5.14;
use General;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
mylogin.pl edit [--cmd-opt] [cmd-arg]

available cmd-opt:
-i              => 'set id to remove'
-l              => 'set login name'
-s              => 'set site'
-d				=> 'set description'
-w				=> 'set password'    

example:
mylogin.pl edit -i 2 -d "change new password on 2nd july" -w secret2

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
    [ 's=s'    => 'set site' ],
    [ 'l=s'	   => 'set login name'],
    [ 'd=s'	   => 'set description'],
    [ 'w=s'	   => 'set password'],
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   $obj = General->new(pwdfile => $self->cache->get('pwdfile'),
   						id => $opts->{'i'},
   						);
	if($opts->{'s'}){
		$obj->site($opts->{'s'});
	}
	if($opts->{'l'}){
		$obj->login($opts->{'l'});
	}
	if($opts->{'d'}){
		$obj->description($opts->{'d'});
	}
	if($opts->{'w'}){
		$obj->password($opts->{'w'});
	}

   $obj->edit();

   return;
}

1;