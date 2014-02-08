
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "An implementation of Promises in Perl",
  "AUTHOR" => "Stevan Little <stevan.little\@iinteractive.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Promises",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Promises",
  "PREREQ_PM" => {
    "AE" => 0,
    "AnyEvent" => 0,
    "Carp" => 0,
    "EV" => 0,
    "Module::Runtime" => 0,
    "Mojo::IOLoop" => 0,
    "Scalar::Util" => 0,
    "Sub::Exporter" => 0,
    "constant" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "AnyEvent" => 0,
    "Test::Fatal" => 0,
    "Test::More" => "0.89",
    "lib" => 0
  },
  "VERSION" => "0.90",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "AE" => 0,
  "AnyEvent" => 0,
  "Carp" => 0,
  "EV" => 0,
  "Module::Runtime" => 0,
  "Mojo::IOLoop" => 0,
  "Scalar::Util" => 0,
  "Sub::Exporter" => 0,
  "Test::Fatal" => 0,
  "Test::More" => "0.89",
  "constant" => 0,
  "lib" => 0,
  "parent" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



