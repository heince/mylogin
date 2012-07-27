package Mylogin::Command::List;

use base qw( CLI::Framework::Command );
use v5.14;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
mylogin.pl list [--cmd-opt] [cmd-arg]

available cmd-opt:
-a				=> 'list all'     

example:
mylogin.pl ls -a
mylogin.pl ls mycompany

EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    
}

sub option_spec {
    # The option_spec() hook in the Command Class provides the option
    # specification for a particular command.
    [ 'help|h' => 'help' ],
    [ 'a'	   => 'list all'],
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   require General;
   $obj = General->new(pwdfile => $self->cache->get('pwdfile'),
   						);
   						
   if(defined $opts->{'a'}){
		$obj->get_all_pwd();
		exit 0;
   }else{
   		if(@args){
   			$obj->search_site_desc(\@args);
   		}else{
   			die "please include argument to filter or -a to list all\n";
   		}
   }

   return;
}

1;