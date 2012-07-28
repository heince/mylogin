package General;

use Mouse;
use v5.14;
use Crypt::CBC;
use Storable;

has [ qw \id site login password description cipher\ ] => ( is => "rw" );
has 'pwdfile' => ( is => 'ro' );
has 'SIG' => ( is => "rw", default => 'SUCCESS');
has 'tmppwd' => ( is => "rw", default => '/tmp/mypasswd');

sub DEMOLISH(){
	my $self = shift;
	
	$self->clean_tempfile();
}

sub edit{
	my $self = shift;
	
	my $hashpwd = $self->get_pwdfile;
	
	unless($self->check_id($hashpwd)){
		say "Error: id " . $self->id . " didn't exist";
		exit 1;
	}

	$$hashpwd{$self->id}{'site'} = $self->site if $self->site;
	$$hashpwd{$self->id}{'login'} = $self->login if $self->login;
	$$hashpwd{$self->id}{'password'} = $self->password if $self->password;
	$$hashpwd{$self->id}{'description'} = $self->description if $self->description;
	
	store \%$hashpwd, $self->tmppwd;
	$self->write_cipher(1);
	$self->print_byid($hashpwd, $self->id);
}

sub add{
	my $self = shift;
	
	my $hashpwd = $self->get_pwdfile;
	
	if(%$hashpwd){
		my $last = $self->get_last_id($hashpwd);
		my $nextid = $last + 1;
		
		$self->store_result($hashpwd, $nextid);
		$self->print_byid($hashpwd, $nextid);
	}else{
		$self->store_result($hashpwd, 1);
		$self->print_byid($hashpwd, 1);
	}
}

sub remove{
	my $self = shift;
	
	my $hashpwd = $self->get_pwdfile;
	
	unless($self->check_id($hashpwd)){
		say "Error: id " . $self->id . " didn't exist";
		exit 1;
	}
	
	my $cmd = delete($$hashpwd{$self->id});
	if($cmd){
		store \%$hashpwd, $self->tmppwd;
		$self->write_cipher(1);
		say "Done";
	}else{
		die "$!\n";
	}
}

#return true if exist
sub check_id{
	my $self = shift;
	
	my $hashpwd = shift;
	
	unless($$hashpwd{$self->id}){
		return 0;
	}else{
		return 1;
	}
}

sub print_byid{
	my $self = shift;
	
	my ($hashpwd, $id) = @_;
	
	say "ID: $id";
	say "site : " . $$hashpwd{$id}{'site'};
	say "login : " . $$hashpwd{$id}{'login'};
	say "password : " . $$hashpwd{$id}{'password'};
	say "description : " . $$hashpwd{$id}{'description'};
	say "";
}

sub store_result{
	my $self = shift;
	
	my ($hashpwd, $id) = @_;
	
	$$hashpwd{$id} = {
			site => $self->site,
			login => $self->login,
			password => $self->password,
			description => $self->description || "",
		};
	store \%$hashpwd, $self->tmppwd;
	$self->write_cipher(1);
}

#search by site & description
sub search_site_desc{
	my $self = shift;
	
	my ($args) = @_;
	
	my $hashpwd = $self->get_pwdfile();
	
	for my $value(keys %$hashpwd){
		for my $filter(@$args){
			if(($$hashpwd{$value}{'site'} =~ /$filter/i) or ($$hashpwd{$value}{'description'} =~ /$filter/i)){
				$self->print_byid($hashpwd, $value);
			}
		}
	}
}

sub get_last_id{
	my $self = shift;
	
	my $hashpwd = shift;
	my $last = (sort keys %$hashpwd)[-1];
	return $last;
}

sub get_all_pwd{
	my $self = shift;
	
	my $hashpwd = $self->get_pwdfile();
	
	for(sort keys %$hashpwd){
		say "ID: " . $_;
		say "site : " . $$hashpwd{$_}{'site'};
		say "login : " . $$hashpwd{$_}{'login'};
		say "password : " . $$hashpwd{$_}{'password'};
		say "description : " . $$hashpwd{$_}{'description'};
		say "";
	}
}

sub get_password{
	my $self = shift;
	
	my $description = shift;
	print($description);
	system('stty','-echo') if $^O =~ /(linux|darwin)/;
	chop(my $passphrase = <STDIN>);
	system('stty','echo') if $^O =~ /(linux|darwin)/;
	print "\n";
	return $passphrase;
}

sub clean_tempfile{
	my $self = shift;
	
	if(-f $self->tmppwd){
		unlink $self->tmppwd;
	}
}

sub get_pwdfile{
	my $self = shift;

	my $cipher = $self->init_crypt();
	unless(-f $self->pwdfile){
		say "setting up initial config";
		$self->init_pwdfile($self->cipher);
	}
	
	my $data = $self->read_file($self->cipher, $self->pwdfile);
	$self->clean_tempfile();
	open (my $fh, '>', $self->tmppwd)  or die "$!\n";
	print $fh $data;
	close $fh;
	my $pwdhash = retrieve($self->tmppwd);
	return $pwdhash;
}

sub init_crypt{
	my $self = shift;
	
	my $passphrase = $self->get_password("Enter Passphrase: ");
	my $cipher = Crypt::CBC->new(
	    -cipher => 'Blowfish',
	    -key    => $passphrase,
	);
	$self->cipher($cipher);
}

sub write_cipher{
	my $self = shift;
	
	my $args = shift;
	my $fh;
	
	if($args){
		open ($fh, "<", $self->tmppwd) or die "can't open tmppwd\n";
	}else{
		open ($fh, "<", $self->pwdfile) or die "can't open pwdfile\n";
	}
	
	my $data;
	while(<$fh>){
		$data .= $_;
	}
	$self->write_file($self->cipher, $self->pwdfile, $data);
	close $fh;
}

sub init_pwdfile{
	my $self = shift;
	
	my %init;

	store \%init, $self->pwdfile;
	$self->write_cipher(0);
}

sub read_file {
	my $self = shift;
	
    my ($cipher, $qfn) = @_;
    open(my $fh, '<:bytes', $qfn) or die("Cannot open $qfn: $!\n");
    my $file; { local $/; $file = <$fh>; }
    return if $file eq "";
    $file = $cipher->decrypt($file);
    die("Wrong password\n") if substr($file, 0, length($self->SIG), '') ne $self->SIG;
    return $file;
}

sub write_file {
	my $self = shift;
	
    my ($cipher, $qfn, $file) = @_;
    open(my $fh, '>:bytes', $qfn) or die("Cannot create file $qfn: $!\n");
    print($fh $cipher->encrypt($self->SIG . $file));
}

1;