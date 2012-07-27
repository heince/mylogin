package Mylogin::Command::Add;

use base qw( CLI::Framework::Command );
use v5.14;
use General;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
mylogin.pl add [--cmd-opt] [cmd-arg]

available cmd-opt:
-l              => 'set login name'
-s              => 'set site'
-d				=> 'set description'
-w				=> 'set password'      

example:
mylogin.pl add -l root -s office-web1 -w secret -d "this is description"

EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    unless((defined $cmd_opts->{'l'}) and (defined $cmd_opts->{'s'}) and (defined $cmd_opts->{'w'})){
    	die "login name or site or password is required\n";
    }
    
}

sub option_spec {
    # The option_spec() hook in the Command Class provides the option
    # specification for a particular command.
    [ 'help|h' => 'help' ],
    [ 's=s'    => 'set site' ],
    [ 'l=s'	   => 'set login name'],
    [ 'd=s'	   => 'set description'],
    [ 'w=s'	   => 'set password'],
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   $obj = General->new(pwdfile => $self->cache->get('pwdfile'),
   						site => $opts->{'s'},
   						login => $opts->{'l'},
   						password => $opts->{'w'}
   						);
   						
   if(defined $opts->{'d'}){
		$obj->description($opts->{'d'});
   }
   $obj->add();

   return;
}

1;