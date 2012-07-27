#!/usr/bin/env perl

use v5.14;
use Path::Class;

BEGIN{
	#set /User/heince/Project/mylogin as homedir
	my @dir = ('', $ENV{'HOME'}, 'Project', 'mylogin');
	
	my $homedir = dir(@dir);
	my $lib = dir(@dir, 'lib');
	
	#set lib
	push @INC, "$lib";
	
	#set env
	$ENV{'myloginroot'} = $homedir;
}

use Mylogin;

Mylogin->run();