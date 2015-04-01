#!/usr/bin/env perl

use strict;
use warnings;
use 5.020;

use Mojo::UserAgent;
use JSON::MaybeXS;
my $MY_USER = 'zoffixznet';

my $modules = decode_json(
    Mojo::UserAgent->new->get("http://modules.perl6.org/proto.json")->res->body
);

my @wanted = map +{
    name => $_,
    repo => $modules->{$_}{url},
}, grep $modules->{$_}{badge_panda_nos11}, keys %$modules;

mkdir "working_dir" or die $!;
chdir "working_dir" or die "Failed to chdir to working dir";
for ( sort { $a->{name} cmp $b->{name} } @wanted ) {
    say "Opening palemoon to take a look at $_->{repo}";
    `palemoon $_->{repo}`;
    say "Do we need to make changes? [Y,n]:";
    chomp( my $answer = <> );
    next if $answer =~ /n/i;

    my ( $owner, $repo) = $_->{repo}
    =~ m{https://github.com/([^/]+)/([^/]+)/};
    say "Forking $owner/$repo";
    say `ph fork $owner/$repo`;
    say "Cloning the fork";
    say `git clone https://github.com/$MY_USER/$repo .`;
    say `git checkout -b add_meta_provides`;
    say `find . -iname '*.pm'`;
    say `find . -iname '*.pm6'`;
    say `find . -iname '*.p6'`;
    say "MODIFY META.info. I'm waiting. Press ENTER to proceed";
    <>;
    say `git commit -am "add provides section for latest panda (S11 support)"`;
    say `git push origin add_meta_provides`;
    `palemoon https://github.com/$MY_USER/$repo`;
    say qq#    "provides": { "$_->{name}" : "" },#;
    say "We're done with this repo. When you're ready for the next one"
        . " press ENTER\n\n";
    <>
}

END {
    chdir '..';
    say "Cleaning up";
    say `rm -fr working_dir`;
}


__END__

'Web::Template' => {
                     'last_updated' => '2014-06-15T19:26:04Z',
                     'badge_panda_nos11' => '',
                     'success' => 0,
                     'badge_is_fresh' => '',
                     'badge_panda' => '1',
                     'repo_name' => 'perl6-web-template',
                     'badge_is_popular' => 0,
                     'auth' => 'supernovus',
                     'description' => 'A template engine abstraction layer for web frameworks.',
                     'badge_has_tests' => undef,
                     'url' => 'https://github.com/supernovus/perl6-web-template/',
                     'name' => 'Web::Template',
                     'badge_has_readme' => 'https://github.com/supernovus/perl6-web-template/blob/a4e4f5a67dbbb236f14a4f1d64394056dcbc01b5/README.md',
                     'home' => 'github'
                   },
