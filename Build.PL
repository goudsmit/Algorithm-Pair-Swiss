use Module::Build;
my $build = Module::Build->new(
	module_name	=> 'Algorithm::Pair::Swiss',
	license		=> 'perl',
	requires	=> {
				'Tie::IxHash'	=> '1.21',
			   },		
);
$build->create_build_script; 
