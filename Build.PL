use Module::Build;
my $build = Module::Build->new(
	module_name	=> 'Algorithm::Pair::Swiss',
	license		=> 'perl',
);

if(exists $build->args->{snapshot}) {
	my ($revision) = `svn info` =~ /^Revision: (\d+)$/gms;
	$build->{properties}->{dist_version} .= '_'.$revision;
}

$build->create_build_script; 
