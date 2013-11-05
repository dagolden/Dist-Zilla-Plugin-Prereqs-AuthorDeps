use 5.006;
use strict;
use warnings;
use Test::More 0.96;

use Dist::Zilla::Tester;
use Path::Tiny;
use CPAN::Meta;

require Dist::Zilla; # for VERSION

my $root       = 'corpus/DZ';
my $dz_version = Dist::Zilla->VERSION;

{
    my $tzil = Dist::Zilla::Tester->from_config( { dist_root => $root }, );
    ok( $tzil, "created test dist" );

    $tzil->build_in;
    my $build_dir = path( $tzil->tempdir->subdir('build') );

    my $meta    = CPAN::Meta->load_file( $build_dir->child("META.json") );
    my $prereqs = $meta->effective_prereqs;

    my $expected = {
        'Dist::Zilla'                              => $dz_version,
        'Dist::Zilla::PluginBundle::Basic'         => 5,
        'Dist::Zilla::Plugin::AutoPrereqs'         => 0,
        'Dist::Zilla::Plugin::MetaJSON'            => 0,
        'Dist::Zilla::Plugin::Prereqs::AuthorDeps' => 0,
    };

    is_deeply( $prereqs->requirements_for(qw/develop requires/)->as_string_hash,
        $expected, "develop requires" );
}

done_testing;
# COPYRIGHT
