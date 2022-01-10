use ExtUtils::MakeMaker;
use File::Copy;

copy('defaultSettings.yaml', 'LatexIndent/defaultSettings.yaml');

WriteMakefile(
    NAME         => "LatexIndent",
    VERSION_FROM => "LatexIndent/Version.pm",
    (
        $] >= 5.005
        ? (
            ABSTRACT => 'Indent LaTeX code',
            LICENSE  => 'gpl_3',
            AUTHOR   => 'Chris Hughes'
          )
        : ()
    ),
    PREREQ_PM => {
        'YAML::Tiny'        => 0,
        'File::HomeDir'     => 0,
        'Unicode::GCString' => 0,
    },

    EXE_FILES  => ['latexindent.pl'],
    dist       => { COMPRESS => 'gzip', SUFFIX => 'gz' },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/cmhughes/latexindent.pl.git',
                web  => 'https://github.com/cmhughes/latexindent.pl',
            },
        },
    },
);
