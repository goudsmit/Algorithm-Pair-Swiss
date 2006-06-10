use Module::Build;
my $build = Module::Build->new(
	module_name	=> 'Algorithm::Pair::Swiss',
	license		=> 'perl',
);
$build->create_build_script; 
