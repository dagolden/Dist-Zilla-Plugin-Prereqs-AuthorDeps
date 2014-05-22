use strict;
use warnings FATAL => 'all';

use Test::More;

use Path::Tiny;
use Test::Deep;
use Test::Deep::JSON;
use Test::DZil;

my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            path(qw(source dist.ini)) => simple_ini(
                [ GatherDir             => ],
                [ MetaJSON              => ],
                [ 'Prereqs::AuthorDeps' => { relation => 'recommends' } ],
              )
              . "\n\n; authordep Devel::Foo = 0.123\n",
            path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
        },
    },
);

$tzil->build;
my $json = path( $tzil->tempdir, qw(build META.json) )->slurp_raw;

cmp_deeply(
    $json,
    json(
        superhashof(
            {
                dynamic_config => 0,
                prereqs        => {
                    develop => {
                        recommends => {
                            'Devel::Foo'                               => 0.123,
                            'Dist::Zilla'                              => int( Dist::Zilla->VERSION ),
                            'Dist::Zilla::Plugin::GatherDir'           => 0,
                            'Dist::Zilla::Plugin::MetaJSON'            => 0,
                            'Dist::Zilla::Plugin::Prereqs::AuthorDeps' => 0,
                        },
                    },
                },
            }
        )
    ),
    'authordeps added as develop recommends',
);

done_testing;
# COPYRIGHT
