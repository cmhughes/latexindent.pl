package LatexIndent::GetYamlSettings;

#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	See http://www.gnu.org/licenses/.
#
#	Chris Hughes, 2017-2025
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use Data::Dumper;
use LatexIndent::Switches qw/%switch $is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use YAML::Tiny;        # interpret defaultSettings.yaml and other potential settings files
use File::Basename;    # to get the filename and directory path
use File::HomeDir;
use Cwd;
use Exporter             qw/import/;
use LatexIndent::LogFile qw/$logger/;
our @EXPORT_OK
    = qw/yaml_obsolete_checks yaml_get_alignment_at_ampersand_from_parent yaml_read_settings yaml_modify_line_breaks_settings yaml_get_indentation_settings_for_this_object yaml_poly_switch_get_every_or_custom_value yaml_get_indentation_information yaml_get_object_attribute_for_indentation_settings yaml_alignment_at_ampersand_settings %mainSetting %previouslyFoundSetting $argumentsBetweenCommands $commaPolySwitchExists $equalsPolySwitchExists %polySwitchNames/;

# Read in defaultSettings.YAML file
our $defaultSettings;

# master yaml settings is a hash, global to this module
our %mainSetting;

use LatexIndent::UTF8CmdLineArgsFileOperation
    qw/copy_with_encode exist_with_encode open_with_encode  zero_with_encode read_yaml_with_encode/;
use utf8;

# previously found settings is a hash, global to this module
our %previouslyFoundSetting;

# default values for align at ampersand routine
our @alignAtAmpersandInformation;

our $argumentsBetweenCommands;
our $commaPolySwitchExists  = 0;
our $equalsPolySwitchExists = 0;

our %polySwitchNames;

sub yaml_read_settings {
    my $self = shift;

    # read the default settings
    $defaultSettings = YAML::Tiny->read("$FindBin::RealBin/defaultSettings.yaml")
        if ( -e "$FindBin::RealBin/defaultSettings.yaml" );

    # grab the logger object
    $logger->info("*YAML settings read: defaultSettings.yaml");
    $logger->info("Reading defaultSettings.yaml from $FindBin::RealBin/defaultSettings.yaml");
    my $myLibDir = dirname(__FILE__);

    my ( $name, $dir, $ext ) = fileparse( $INC{"LatexIndent/GetYamlSettings.pm"}, "pm" );
    $dir =~ s/\/$//;

    # if latexindent.exe is invoked from TeXLive, then defaultSettings.yaml won't be in
    # the same directory as it; we need to navigate to it
    if ( !$defaultSettings ) {
        $logger->info(
            "Reading defaultSettings.yaml (2nd attempt) from $FindBin::RealBin/../../texmf-dist/scripts/latexindent/defaultSettings.yaml"
        );
        $logger->info("and then, if necessary, $FindBin::RealBin/LatexIndent/defaultSettings.yaml");
        if ( -e "$FindBin::RealBin/../../texmf-dist/scripts/latexindent/defaultSettings.yaml" ) {
            $defaultSettings
                = YAML::Tiny->read("$FindBin::RealBin/../../texmf-dist/scripts/latexindent/defaultSettings.yaml");
        }
        elsif ( -e "$FindBin::RealBin/LatexIndent/defaultSettings.yaml" ) {
            $defaultSettings = YAML::Tiny->read("$FindBin::RealBin/LatexIndent/defaultSettings.yaml");
        }
        elsif ( -e "$dir/defaultSettings.yaml" ) {
            $defaultSettings = YAML::Tiny->read("$dir/defaultSettings.yaml");
        }
        elsif ( -e "$myLibDir/defaultSettings.yaml" ) {
            +$defaultSettings = YAML::Tiny->read("$myLibDir/defaultSettings.yaml");
        }
        else {
            $logger->fatal("*Could not open defaultSettings.yaml");
            $self->output_logfile();
            exit(2);
        }
    }

    # need to exit if we can't get defaultSettings.yaml
    if ( !$defaultSettings ) {
        $logger->fatal("*Could not open defaultSettings.yaml");
        $self->output_logfile();
        exit(2);
    }

    # master yaml settings is a hash, global to this module
    our %mainSetting = %{ $defaultSettings->[0] };

    &yaml_update_dumper_settings();

    # scalar to read user settings
    my $userSettings;

    # array to store the paths to user settings
    my @absPaths;

    # we'll need the home directory a lot in what follows
    my $homeDir = File::HomeDir->my_home;
    $logger->info("*YAML reading settings") unless $switch{onlyDefault};

    my $indentconfig = undef;
    if ( defined $ENV{LATEXINDENT_CONFIG} && !$switch{onlyDefault} ) {
        if ( -f $ENV{LATEXINDENT_CONFIG} ) {
            $indentconfig = $ENV{LATEXINDENT_CONFIG};
            $logger->info('The $LATEXINDENT_CONFIG variable was detected.');
            $logger->info( 'The value of $LATEXINDENT_CONFIG is: "' . $ENV{LATEXINDENT_CONFIG} . '"' );
        }
        else {
            $logger->warn('*The $LATEXINDENT_CONFIG variable is assigned, but does not point to a file!');
            $logger->warn( 'The value of $LATEXINDENT_CONFIG is: "' . $ENV{LATEXINDENT_CONFIG} . '"' );
        }
    }
    if ( !defined $indentconfig && !$switch{onlyDefault} ) {

# see all possible values of $^O here: https://perldoc.perl.org/perlport#Unix and https://perldoc.perl.org/perlport#DOS-and-Derivatives
        if ( $^O eq "linux" ) {
            if ( defined $ENV{XDG_CONFIG_HOME} && -f "$ENV{XDG_CONFIG_HOME}/latexindent/indentconfig.yaml" ) {
                $indentconfig = "$ENV{XDG_CONFIG_HOME}/latexindent/indentconfig.yaml";
                $logger->info( 'The $XDG_CONFIG_HOME variable and the config file in "'
                        . "$ENV{XDG_CONFIG_HOME}/latexindent/indentconfig.yaml"
                        . '" were recognized' );
                $logger->info( 'The value of $XDG_CONFIG_HOME is: "' . $ENV{XDG_CONFIG_HOME} . '"' );
            }
            elsif ( -f "$homeDir/.config/latexindent/indentconfig.yaml" ) {
                $indentconfig = "$homeDir/.config/latexindent/indentconfig.yaml";
                $logger->info(
                    'The config file in "' . "$homeDir/.config/latexindent/indentconfig.yaml" . '" will be read' );
            }
        }
        elsif ( $^O eq "darwin" ) {
            if ( -f "$homeDir/Library/Preferences/latexindent/indentconfig.yaml" ) {
                $indentconfig = "$homeDir/Library/Preferences/latexindent/indentconfig.yaml";
                $logger->info( 'The config file in "'
                        . "$homeDir/Library/Preferences/latexindent/indentconfig.yaml"
                        . '" will be read' );
            }
        }
        elsif ( $^O eq "MSWin32" || $^O eq "cygwin" ) {
            if ( defined $ENV{LOCALAPPDATA} && -f "$ENV{LOCALAPPDATA}/latexindent/indentconfig.yaml" ) {
                $indentconfig = "$ENV{LOCALAPPDATA}/latexindent/indentconfig.yaml";
                $logger->info( 'The $LOCALAPPDATA variable and the config file in "'
                        . "$ENV{LOCALAPPDATA}"
                        . '\latexindent\indentconfig.yaml" were recognized' );
                $logger->info( 'The value of $LOCALAPPDATA is: "' . $ENV{LOCALAPPDATA} . '"' );
            }
            elsif ( -f "$homeDir/AppData/Local/latexindent/indentconfig.yaml" ) {
                $indentconfig = "$homeDir/AppData/Local/latexindent/indentconfig.yaml";
                $logger->info( 'The config file in "'
                        . "$homeDir"
                        . '\AppData\Local\latexindent\indentconfig.yaml" will be read' );
            }
        }

        # if $indentconfig is still not defined, fallback to the location in $homeDir
        if ( !defined $indentconfig ) {

            # if all of these don't exist check home directly, with the non hidden file
            $indentconfig = ( -f "$homeDir/indentconfig.yaml" ) ? "$homeDir/indentconfig.yaml" : undef;

            # if indentconfig.yaml doesn't exist, check for the hidden file, .indentconfig.yaml
            if ( !defined $indentconfig ) {
                $indentconfig = ( -f "$homeDir/.indentconfig.yaml" ) ? "$homeDir/.indentconfig.yaml" : undef;
            }
            $logger->info( 'The config file in "' . "$indentconfig" . '" will be read' ) if defined $indentconfig;
        }
    }

    # messages for indentconfig.yaml and/or .indentconfig.yaml
    if ( defined $indentconfig and -f $indentconfig and !$switch{onlyDefault} ) {

        # read the absolute paths from indentconfig.yaml
        $userSettings = YAML::Tiny->read("$indentconfig");

        # update the absolute paths
        if ( $userSettings and ( ref( $userSettings->[0] ) eq 'HASH' ) and $userSettings->[0]->{paths} ) {
            $logger->info("Reading path information from $indentconfig");

            # output the contents of indentconfig to the log file
            $logger->info( Dump \%{ $userSettings->[0] } );

            # change the encoding of the paths according to the field `encoding`
            if ( $userSettings and ( ref( $userSettings->[0] ) eq 'HASH' ) and $userSettings->[0]->{encoding} ) {
                use Encode;
                my $encoding       = $userSettings->[0]->{encoding};
                my $encodingObject = find_encoding($encoding);

                # Check if the encoding is valid.
                if ( ref($encodingObject) ) {
                    $logger->info("*Encoding of the paths is $encoding");
                    foreach ( @{ $userSettings->[0]->{paths} } ) {
                        my $temp = $encodingObject->encode("$_");
                        $logger->info("Transform file encoding: $_ -> $temp");
                        push( @absPaths, $temp );
                    }
                }
                else {
                    $logger->warn("*encoding \"$encoding\" not found");
                    $logger->warn("Ignore this setting and will take the default encoding.");
                    @absPaths = @{ $userSettings->[0]->{paths} };
                }
            }
            else    # No such setting, and will take the default
            {
                # $logger->info("*Encoding of the paths takes the default.");
                @absPaths = @{ $userSettings->[0]->{paths} };
            }
        }
        else {
            $logger->warn(
                "*The paths field cannot be read from $indentconfig; this means it is either empty or contains invalid YAML"
            );
            $logger->warn(
                "See https://latexindentpl.readthedocs.io/en/latest/sec-indent-config-and-settings.html for an example"
            );
        }
    }
    else {
        if ( $switch{onlyDefault} ) {
            $logger->info("*-d switch active: only default settings requested");
            $logger->info("not reading USER settings from $indentconfig")
                if ( defined $indentconfig && -e $indentconfig );
            $logger->info("Ignoring the -l switch: $switch{readLocalSettings} (you used the -d switch)")
                if ( $switch{readLocalSettings} );
            $logger->info("Ignoring the -y switch: $switch{yaml} (you used the -d switch)") if ( $switch{yaml} );
            $switch{readLocalSettings} = 0;
            $switch{yaml}              = 0;
        }
        else {
            # give the user instructions on where to put the config file
            $logger->info("Home directory is $homeDir");
            $logger->info("latexindent.pl didn't find indentconfig.yaml or .indentconfig.yaml");
            $logger->info(
                "see all possible locations: https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#indentconfig-options"
            );
        }
    }

    # default value of readLocalSettings
    #
    #       latexindent -l myfile.tex
    #
    # means that we wish to use localSettings.yaml
    if ( defined( $switch{readLocalSettings} ) and ( $switch{readLocalSettings} eq '' ) ) {
        $logger->info('*-l switch used without filename, will search for the following files in turn:');
        $logger->info('localSettings.yaml,latexindent.yaml,.localSettings.yaml,.latexindent.yaml');
        $switch{readLocalSettings} = 'localSettings.yaml,latexindent.yaml,.localSettings.yaml,.latexindent.yaml';
    }

    # local settings can be called with a + symbol, for example
    #     -l=+myfile.yaml
    #     -l "+ myfile.yaml"
    #     -l=myfile.yaml+
    # which translates to, respectively
    #     -l=localSettings.yaml,myfile.yaml
    #     -l=myfile.yaml,localSettings.yaml
    # Note: the following is *not allowed*:
    #     -l+myfile.yaml
    # and
    #     -l + myfile.yaml
    # will *only* load localSettings.yaml, and myfile.yaml will be ignored
    my @localSettings;

    $logger->info("*YAML settings read: -l switch") if $switch{readLocalSettings};

    # remove leading, trailing, and intermediate space
    $switch{readLocalSettings} =~ s/^\h*//g;
    $switch{readLocalSettings} =~ s/\h*$//g;
    $switch{readLocalSettings} =~ s/\h*,\h*/,/g;
    if ( $switch{readLocalSettings} =~ m/\+/ ) {
        $logger->info(
            "+ found in call for -l switch: will add localSettings.yaml,latexindent.yaml,.localSettings.yaml,.latexindent.yaml"
        );

        # + can be either at the beginning or the end, which determines if where the comma should go
        my $commaAtBeginning = ( $switch{readLocalSettings} =~ m/^\h*\+/ ? q() : "," );
        my $commaAtEnd       = ( $switch{readLocalSettings} =~ m/^\h*\+/ ? "," : q() );
        $switch{readLocalSettings} =~ s/\h*\+\h*/$commaAtBeginning
                    ."localSettings.yaml,latexindent.yaml,.localSettings.yaml,.latexindent.yaml"
                    .$commaAtEnd/ex;
        $logger->info("New value of -l switch: $switch{readLocalSettings}");
    }

    # local settings can be separated by ,
    # e.g
    #     -l = myyaml1.yaml,myyaml2.yaml
    # and in which case, we need to read them all
    if ( $switch{readLocalSettings} =~ m/,/ ) {
        $logger->info("Multiple localSettings found, separated by commas:");
        @localSettings = split( /,/, $switch{readLocalSettings} );
        $logger->info( join( ', ', @localSettings ) );
    }
    else {
        push( @localSettings, $switch{readLocalSettings} ) if ( $switch{readLocalSettings} );
    }

    my $workingFileLocation = dirname( ${$self}{fileName} );

    # add local settings to the paths, if appropriate
    foreach (@localSettings) {

        # check for an extension (.yaml)
        my ( $name, $dir, $ext ) = fileparse( $_, "yaml" );

        # if no extension is found, append the current localSetting with .yaml
        $_ = $_ . ( $_ =~ m/\.\z/ ? q() : "." ) . "yaml" if ( !$ext );

        # if the -l switch is called on its own, or else with +
        # and latexindent.pl is called from a different directory, then
        # we need to account for this
        if ( $_ =~ m/^[.]?(localSettings|latexindent)\.yaml$/ ) {

            # check for existence in the directory of the file.
            if ( ( -e $workingFileLocation . "/" . $_ ) ) {
                $_ = $workingFileLocation . "/" . $_;

                # otherwise we fallback to the current directory
            }
            elsif ( ( -e cwd() . "/" . $_ ) ) {
                $_ = cwd() . "/" . $_;
            }
        }

        # diacritics in YAML names (highlighted in https://github.com/cmhughes/latexindent.pl/pull/439)
        #$_ = decode( "utf-8", $_ );
        $_ = $_;

        # check for existence and non-emptiness
        if ( exist_with_encode($_) and !( zero_with_encode($_) ) ) {
            $logger->info("Adding $_ to YAML read paths");
            push( @absPaths, "$_" );
        }
        elsif ( !( exist_with_encode($_) ) ) {
            if ((       $_ =~ m/localSettings|latexindent/s
                    and !( -e 'localSettings.yaml' )
                    and !( -e '.localSettings.yaml' )
                    and !( -e 'latexindent.yaml' )
                    and !( -e '.latexindent.yaml' )
                )
                or $_ !~ m/localSettings|latexindent/s
                )
            {
                $logger->warn("*yaml file not found: $_ not found. Proceeding without it.");
            }
        }
    }

    # heading for the log file
    $logger->info("*YAML settings, reading from the following files:") if @absPaths;

    # read in the settings from each file
    foreach my $settings (@absPaths) {

        # check that the settings file exists and that it isn't empty
        if ( exist_with_encode($settings) and !( zero_with_encode($settings) ) ) {
            $logger->info("Reading USER settings from $settings");
            $userSettings = read_yaml_with_encode("$settings");

            # update the absolute paths
            if ( $userSettings and ( ref( $userSettings->[0] ) eq 'HASH' ) and $userSettings->[0]->{paths} ) {
                $logger->info("Reading path information from $settings");

                # output the contents of indentconfig to the log file
                $logger->info( Dump \%{ $userSettings->[0] } );

                foreach ( @{ $userSettings->[0]->{paths} } ) {
                    push( @absPaths, $_ );
                }
            }

            # if we can read userSettings
            if ($userSettings) {

                # specialBeginEnd backwards compatibility
                #
                #   old: HASH
                #   new: ARRAY
                #
                if ( ${ $userSettings->[0] }{specialBeginEnd}
                    and ( ref( ${ $userSettings->[0] }{specialBeginEnd} ) eq 'HASH' ) )
                {

                    my @newSpecialBeginEnd;
                    while ( my ( $specialKey, $specialValue ) = each %{ ${ $userSettings->[0] }{specialBeginEnd} } ) {
                        my %newIndvSpecialBeginEnd;
                        if ( ref($specialValue) eq 'HASH' ) {
                            $newIndvSpecialBeginEnd{name}  = $specialKey;
                            $newIndvSpecialBeginEnd{begin} = ${$specialValue}{begin} if defined ${$specialValue}{begin};
                            $newIndvSpecialBeginEnd{end}   = ${$specialValue}{end}   if defined ${$specialValue}{end};
                            $newIndvSpecialBeginEnd{nested} = ${$specialValue}{nested}
                                if defined ${$specialValue}{nested};
                            $newIndvSpecialBeginEnd{middle} = ${$specialValue}{middle}
                                if defined ${$specialValue}{middle};
                            $newIndvSpecialBeginEnd{lookForThis} = ${$specialValue}{lookForThis}
                                if defined ${$specialValue}{lookForThis};
                            push( @newSpecialBeginEnd, \%newIndvSpecialBeginEnd );
                        }
                    }
                    ${ $userSettings->[0] }{specialBeginEnd} = \@newSpecialBeginEnd;
                    $logger->warn(
                        "*specialBeginEnd should be specified as list, but has been converted to the appropriate format, see below"
                    );
                }

                # update the MASTER settings to include updates from the userSettings
                while ( my ( $firstLevelKey, $firstLevelValue ) = each %{ $userSettings->[0] } ) {

                    # the update approach is slightly different for hashes vs scalars/arrays
                    if ( ref($firstLevelValue) eq "HASH" ) {
                        while ( my ( $secondLevelKey, $secondLevelValue )
                            = each %{ $userSettings->[0]{$firstLevelKey} } )
                        {
                            if ( ref $secondLevelValue eq "HASH" ) {

              # if mainSetting already contains a *scalar* value in secondLevelKey
              # then we need to delete it (test-cases/headings-first.tex with indentRules1.yaml first demonstrated this)
                                if ( defined $mainSetting{$firstLevelKey}{$secondLevelKey}
                                    and ref $mainSetting{$firstLevelKey}{$secondLevelKey} ne "HASH" )
                                {
                              # tabular: 0/1 needs to be translated into
                              #   lookForAlignDelims:
                              #     tabular:
                              #       delims: 0/1
                              # see, for example, latexindent.pl -t -s table1 -o=+-mod3 -l=tabular3,multiColumnGrouping2
                                    if ( $firstLevelKey eq 'lookForAlignDelims' ) {
                                        my $delims = $mainSetting{$firstLevelKey}{$secondLevelKey};
                                        delete $mainSetting{$firstLevelKey}{$secondLevelKey};
                                        ${ $mainSetting{$firstLevelKey}{$secondLevelKey} }{delims} = $delims;
                                    }
                                    else {
                                        delete $mainSetting{$firstLevelKey}{$secondLevelKey};
                                    }
                                    $logger->trace(
                                        "*mainSetting{$firstLevelKey}{$secondLevelKey} currently contains a *scalar* value, but it needs to be updated with a hash (see $settings); deleting the scalar"
                                    ) if ($is_t_switch_active);
                                }
                                while ( my ( $thirdLevelKey, $thirdLevelValue ) = each %{$secondLevelValue} ) {
                                    if ( ref $thirdLevelValue eq "HASH" ) {

                                        # similarly for third level
                                        if ( defined $mainSetting{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey}
                                            and ref $mainSetting{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey} ne
                                            "HASH" )
                                        {
                                            $logger->trace(
                                                "*mainSetting{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey} currently contains a *scalar* value, but it needs to be updated with a hash (see $settings); deleting the scalar"
                                            ) if ($is_t_switch_active);
                                            delete $mainSetting{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey};
                                        }
                                        while ( my ( $fourthLevelKey, $fourthLevelValue ) = each %{$thirdLevelValue} ) {
                                            $mainSetting{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey}
                                                {$fourthLevelKey} = $fourthLevelValue;
                                        }
                                    }
                                    else {
                                        $mainSetting{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey}
                                            = $thirdLevelValue;
                                    }
                                }
                            }
                            else {
                                # settings such as commandCodeBlocks can have arrays, which may wish
                                # to be amalgamated, rather than overwritten
                                if (    ref($secondLevelValue) eq "ARRAY"
                                    and ${ ${ $mainSetting{$firstLevelKey}{$secondLevelKey} }[0] }{amalgamate}
                                    and !(
                                            ref( ${$secondLevelValue}[0] ) eq "HASH"
                                        and defined ${$secondLevelValue}[0]{amalgamate}
                                        and !${$secondLevelValue}[0]{amalgamate}
                                    )
                                    )
                                {
                                    $logger->trace("*$firstLevelKey -> $secondLevelKey, amalgamate: 1")
                                        if ($is_t_switch_active);
                                    foreach ( @{$secondLevelValue} ) {
                                        $logger->trace("$_") if ($is_t_switch_active);
                                        push( @{ $mainSetting{$firstLevelKey}{$secondLevelKey} }, $_ )
                                            unless ( ref($_) eq "HASH" );
                                    }

# remove duplicated entries, https://stackoverflow.com/questions/7651/how-do-i-remove-duplicate-items-from-an-array-in-perl
                                    my %seen = ();
                                    my @unique
                                        = grep { !$seen{$_}++ } @{ $mainSetting{$firstLevelKey}{$secondLevelKey} };
                                    @{ $mainSetting{$firstLevelKey}{$secondLevelKey} } = @unique;

                                    $logger->trace(
                                        "*main settings for $firstLevelKey -> $secondLevelKey now look like:")
                                        if $is_t_switch_active;
                                    foreach ( @{ $mainSetting{$firstLevelKey}{$secondLevelKey} } ) {
                                        $logger->trace("$_") if ($is_t_switch_active);
                                    }
                                }
                                else {
                                    $mainSetting{$firstLevelKey}{$secondLevelKey} = $secondLevelValue;
                                }
                            }
                        }
                    }
                    elsif ( ref($firstLevelValue) eq "ARRAY" ) {

                        # update amalgamate in master settings
                        if ( ref( ${$firstLevelValue}[0] ) eq "HASH" and defined ${$firstLevelValue}[0]{amalgamate} ) {
                            ${ $mainSetting{$firstLevelKey}[0] }{amalgamate} = ${$firstLevelValue}[0]{amalgamate};
                            shift @{$firstLevelValue} if ${ $mainSetting{$firstLevelKey}[0] }{amalgamate};
                        }

                        if ( ref( ${$firstLevelValue}[0] ) eq "HASH"
                            and defined ${$firstLevelValue}[0]{specialBeforeCommand} )
                        {
                            ${ $mainSetting{$firstLevelKey}[0] }{specialBeforeCommand}
                                = ${$firstLevelValue}[0]{specialBeforeCommand};
                        }

                        # if amalgamate is set to 1, then append
                        if ( ref( $mainSetting{$firstLevelKey}[0] ) eq "HASH"
                            and ${ $mainSetting{$firstLevelKey}[0] }{amalgamate} )
                        {

                            # loop through the other settings
                            foreach ( @{$firstLevelValue} ) {
                                push( @{ $mainSetting{$firstLevelKey} }, $_ );
                            }
                        }
                        else {
                            # otherwise overwrite
                            $mainSetting{$firstLevelKey} = $firstLevelValue;
                        }
                    }
                    else {
                        $mainSetting{$firstLevelKey} = $firstLevelValue;
                    }
                }

                # output settings to $logfile
                if ( $mainSetting{logFilePreferences}{showEveryYamlRead} ) {
                    $logger->info( Dump \%{ $userSettings->[0] } );
                }
                else {
                    $logger->info(
                        "Not showing settings in the log file (see showEveryYamlRead and showAmalgamatedSettings).");
                }

                # warning to log file if modifyLineBreaks specified and m switch not active
                if ( ${ $userSettings->[0] }{modifyLineBreaks} and !$is_m_switch_active ) {
                    $logger->warn("*modifyLineBreaks specified and m switch is *not* active");
                    $logger->warn("perhaps you intended to call");
                    $logger->warn("     latexindent.pl -m -l $settings ${$self}{fileName}");
                }
            }
            else {
                # otherwise print a warning that we can not read userSettings.yaml
                $logger->warn("*$settings contains invalid yaml format- not reading from it");
            }
        }
        else {
            # otherwise keep going, but put a warning in the log file
            $logger->warn("*$homeDir/indentconfig.yaml");
            if ( zero_with_encode($settings) ) {
                $logger->info("specifies $settings but this file is EMPTY -- not reading from it");
            }
            else {
                $logger->info(
                    "specifies $settings but this file does not exist - unable to read settings from this file");
            }
        }

        &yaml_update_dumper_settings();

    }

    # read settings from -y|--yaml switch
    if ( $switch{yaml} ) {

        # report to log file
        $logger->info("*YAML settings read: -y switch");

        # remove any horizontal space before or after , OR : OR ; or at the beginning or end of the switch value
        $switch{yaml} =~ s/\h*(,|(?<!\\):|;)\h*/$1/g;
        $switch{yaml} =~ s/^\h*//g;

        # store settings, possibly multiple ones split by commas
        my @yamlSettings;
        if ( $switch{yaml} =~ m/(?<!\\),/ ) {
            foreach ( split( /(?<!\\),/, $switch{yaml} ) ) {

                # check for empty entry
                next if $_ =~ m/^\h*$/s;
                push( @yamlSettings, $_ );
            }
        }
        else {
            push( @yamlSettings, $switch{yaml} );
        }

        foreach (@yamlSettings) {
            $logger->info( "YAML setting: " . $_ );
        }

        # it is possible to specify, for example,
        #
        #   -y=indentAfterHeadings:paragraph:lookForThis:1;level:1
        #   -y=specialBeginEnd:displayMath:begin:'\\\[';end: '\\\]';lookForThis: 1
        #
        # which should be translated into
        #
        #   indentAfterHeadings:
        #       paragraph:
        #           lookForThis:1
        #           level:1
        #
        # so we need to loop through the comma separated list and search
        # for semi-colons
        my $settingsCounter      = 0;
        my @originalYamlSettings = @yamlSettings;
        foreach (@originalYamlSettings) {

            # increment the counter
            $settingsCounter++;

# need to be careful in splitting at ';'
#
# motivation as detailed in https://github.com/cmhughes/latexindent.pl/issues/243
#
#       latexindent.pl -m -y='modifyLineBreaks:oneSentencePerLine:manipulateSentences: 1,
#                             modifyLineBreaks:oneSentencePerLine:sentencesBeginWith:a-z: 1,
#                             fineTuning:modifyLineBreaks:betterFullStop: "(?:\.|;|:(?![a-z]))|(?:(?<!(?:(?:e\.g)|(?:i\.e)|(?:etc))))\.(?!(?:[a-z]|[A-Z]|\-|~|\,|[0-9]))"' myfile.tex
#
# in particular, the fineTuning part needs care in treating the argument between the quotes

            # check for a match of the ;
            if ( $_ !~ m/(?<!(?:\\))"/ and $_ =~ m/(?<!\\);/ ) {
                my (@subfield) = split( /(?<!\\);/, $_ );

                # the content up to the first ; is called the 'root'
                my $root = shift @subfield;

                # split the root at :
                my (@keysValues) = split( /:/, $root );

                # get rid of the last *two* elements, which will be
                #   key: value
                # for example, in
                #   -y=indentAfterHeadings:paragraph:lookForThis:1;level:1
                # then @keysValues holds
                #   indentAfterHeadings:paragraph:lookForThis:1
                # so we need to get rid of both
                #    1
                #    lookForThis
                # so that we are in a position to concatenate
                #   indentAfterHeadings:paragraph
                # with
                #   level:1
                # to form
                #   indentAfterHeadings:paragraph:level:1
                pop(@keysValues);
                pop(@keysValues);

                # update the appropriate piece of the -y switch, for example:
                #   -y=indentAfterHeadings:paragraph:lookForThis:1;level:1
                # needs to be changed to
                #   -y=indentAfterHeadings:paragraph:lookForThis:1
                # the
                #   indentAfterHeadings:paragraph:level:1
                # will be added in the next part
                $yamlSettings[ $settingsCounter - 1 ] = $root;

                # reform the root
                $root = join( ":", @keysValues );
                $logger->trace("*Sub-field detected (; present) and the root is: $root") if $is_t_switch_active;

                # now we need to attach the $root back together with any subfields
                foreach (@subfield) {

    # splice the new field into @yamlSettings (reference: https://perlmaven.com/splice-to-slice-and-dice-arrays-in-perl)
                    splice @yamlSettings, $settingsCounter, 0, $root . ":" . $_;

                    # increment the counter
                    $settingsCounter++;
                }
                $logger->info( "-y switch value interpreted as: " . join( ',', @yamlSettings ) );
            }
        }

        # loop through each of the settings specified in the -y switch
        foreach (@yamlSettings) {

            my @keysValues;

# as above, need to be careful in splitting at ':'
#
# motivation as detailed in https://github.com/cmhughes/latexindent.pl/issues/243
#
#       latexindent.pl -m -y='modifyLineBreaks:oneSentencePerLine:manipulateSentences: 1,
#                             modifyLineBreaks:oneSentencePerLine:sentencesBeginWith:a-z: 1,
#                             fineTuning:modifyLineBreaks:betterFullStop: "(?:\.|;|:(?![a-z]))|(?:(?<!(?:(?:e\.g)|(?:i\.e)|(?:etc))))\.(?!(?:[a-z]|[A-Z]|\-|~|\,|[0-9]))"' myfile.tex
#
# in particular, the fineTuning part needs care in treating the argument between the quotes

            if ( $_ =~ m/(?<!(?:\\))"/ ) {
                my (@splitAtQuote) = split( /(?<!(?:\\))"/, $_ );
                $logger->info("quote found in -y switch");
                $logger->info( "key: " . $splitAtQuote[0] );

                # definition check
                $splitAtQuote[1] = '' if not defined $splitAtQuote[1];

                # then log the value
                $logger->info( "value: " . $splitAtQuote[1] );

                # split at :
                (@keysValues) = split( /(?<!(?:\\|\[)):(?!\])/, $splitAtQuote[0] );

                $splitAtQuote[1] = '"' . $splitAtQuote[1] . '"';
                push( @keysValues, $splitAtQuote[1] );
            }
            else {
                # split each value at semi-colon
                (@keysValues) = split( /(?<!(?:\\|\[)):(?!\])/, $_ );
            }

            # $value will always be the last element
            my $value = $keysValues[-1];

            # it's possible that the 'value' will contain an escaped
            # semi-colon, so we replace it with just a semi-colon
            $value =~ s/\\:/:/;

            # strings need special treatment
            if ( $value =~ m/^"(.*)"$/ ) {

                # double-quoted string
                # translate: '\t', '\n', '\"', '\\'
                my $raw_value = $value;
                $value = $1;

                # only translate string starts with an odd number of escape characters '\'
                $value =~ s/(?<!\\)((\\\\)*)\\t/$1\t/g;
                $value =~ s/(?<!\\)((\\\\)*)\\n/$1\n/g;
                $value =~ s/(?<!\\)((\\\\)*)\\"/$1"/g;

                # translate '\\' in double-quoted strings, but not in single-quoted strings
                $value =~ s/\\\\/\\/g;
                $logger->info("double-quoted string found in -y switch: $raw_value, substitute to $value");
            }
            elsif ( $value =~ m/^'(.*)'$/ ) {

                # single-quoted string
                my $raw_value = $value;
                $value = $1;

                # special treatment for tabs and newlines
                # translate: '\t', '\n'
                # only translate string starts with an odd number of escape characters '\'
                $value =~ s/(?<!\\)((\\\\)*)\\t/$1\t/g;
                $value =~ s/(?<!\\)((\\\\)*)\\n/$1\n/g;
                $logger->info("single-quoted string found in -y switch: $raw_value, substitute to $value");
            }

            if ( scalar(@keysValues) == 2 ) {

                # for example, -y="defaultIndent: ' '"
                my $key = $keysValues[0];
                $logger->info("Updating mainSetting with $key: $value");
                $mainSetting{$key} = $value;
            }
            elsif ( scalar(@keysValues) == 3 ) {

                # for example, -y="indentRules: one: '\t\t\t\t'"
                my $parent = $keysValues[0];
                my $child  = $keysValues[1];
                $logger->info("Updating mainSetting with $parent: $child: $value");
                $mainSetting{$parent}{$child} = $value;
            }
            elsif ( scalar(@keysValues) == 4 ) {

                # for example, -y='modifyLineBreaks  :  environments: EndStartsOnOwnLine:3' -m
                my $parent     = $keysValues[0];
                my $child      = $keysValues[1];
                my $grandchild = $keysValues[2];

                if ( ref $mainSetting{$parent} eq 'HASH' ) {
                    delete $mainSetting{$parent}{$child}
                        if ( defined $mainSetting{$parent}{$child} and ref $mainSetting{$parent}{$child} ne "HASH" );

                    $logger->info("Updating mainSetting with $parent: $child: $grandchild: $value");
                    $mainSetting{$parent}{$child}{$grandchild} = $value;
                }
                else {
                    $logger->warn(
                        "*-y:$parent:$child:$grandchild:$value ignored, as mainSetting{$parent} should be specified as a list"
                    );
                }
            }
            elsif ( scalar(@keysValues) == 5 ) {

                # for example, -y='modifyLineBreaks  :  environments: one: EndStartsOnOwnLine:3' -m
                my $parent          = $keysValues[0];
                my $child           = $keysValues[1];
                my $grandchild      = $keysValues[2];
                my $greatgrandchild = $keysValues[3];
                $logger->info("Updating mainSetting with $parent: $child: $grandchild: $greatgrandchild: $value");
                $mainSetting{$parent}{$child}{$grandchild}{$greatgrandchild} = $value;
            }

            &yaml_update_dumper_settings();
        }

    }

    # the following are incompatible:
    #
    #   modifyLineBreaks:
    #       oneSentencePerLine:
    #         manipulateSentences: 1
    #         textWrapSentences: 1
    #         sentenceIndent: " "       <!------
    #       textWrapOptions:
    #           columns: 100
    #           when: after             <!------
    #
    if (    $is_m_switch_active
        and ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{when} eq 'after'
        and ${ $mainSetting{modifyLineBreaks}{oneSentencePerLine} }{sentenceIndent} =~ m/\h+/ )
    {
        $logger->warn("*one-sentence-per-line *ignoring* sentenceIndent, as text wrapping set to 'after'");
        ${ $mainSetting{modifyLineBreaks}{oneSentencePerLine} }{sentenceIndent} = q();
    }

    #
    # fineTuning environment checks
    #
    if ( defined ${ ${ $mainSetting{fineTuning} }{environments} }{begin}
        and not defined ${ ${ $mainSetting{fineTuning} }{environments} }{end} )
    {
        $logger->warn(
            "*fineTuning environment begin specified and *NOT* end, ignoring this and using default environment regex");
    }

    if ( not defined ${ ${ $mainSetting{fineTuning} }{environments} }{begin}
        and defined ${ ${ $mainSetting{fineTuning} }{environments} }{end} )
    {
        $logger->warn(
            "*fineTuning environment end specified and *NOT* begin, ignoring this and using default environment regex");
    }

    $argumentsBetweenCommands = qr/${${$mainSetting{fineTuning}}{arguments}}{between}/;

    # specialBeginEnd: amalgamate duplicates
    my %specialBeginEndNames;
    my @specialToBeRemoved;
    if ( ${ ${ $mainSetting{specialBeginEnd} }[0] }{amalgamate} ) {

        my $index = -1;
        foreach ( @{ $mainSetting{specialBeginEnd} } ) {
            $index++;
            next if not defined ${$_}{name};

            # if a specialBeginEnd entry exists then amalgamate
            if ( $specialBeginEndNames{ ${$_}{name} } ) {
                $logger->trace("*specialBeginEnd amalgamating ${$_}{name} settings") if $is_t_switch_active;

                my $originalIndex = ${ $specialBeginEndNames{ ${$_}{name} } }{index};
                ${ ${ $mainSetting{specialBeginEnd} }[$originalIndex] }{lookForThis} = ${$_}{lookForThis}
                    if defined ${$_}{lookForThis};
                ${ ${ $mainSetting{specialBeginEnd} }[$originalIndex] }{begin}  = ${$_}{begin} if defined ${$_}{begin};
                ${ ${ $mainSetting{specialBeginEnd} }[$originalIndex] }{end}    = ${$_}{end}   if defined ${$_}{end};
                ${ ${ $mainSetting{specialBeginEnd} }[$originalIndex] }{nested} = ${$_}{nested}
                    if defined ${$_}{nested};
                ${ ${ $mainSetting{specialBeginEnd} }[$originalIndex] }{middle} = ${$_}{middle}
                    if defined ${$_}{middle};
                push( @specialToBeRemoved, $index );
                next;
            }
            ${ $specialBeginEndNames{ ${$_}{name} } }{index} = $index;
        }
    }

    # specialBeginEnd: remove duplicates now that they have been accounted for above
    foreach ( reverse @specialToBeRemoved ) {
        splice( @{ $mainSetting{specialBeginEnd} }, $_ );
    }

    # special: set default look for this as 1 if not specified
    foreach ( @{ $mainSetting{specialBeginEnd} } ) {

        # default look for this
        ${$_}{lookForThis} = 1 if not defined ${$_}{lookForThis};
        ${$_}{lookForThis} = 0 if not defined ${$_}{begin};
        ${$_}{lookForThis} = 0 if not defined ${$_}{end};
        ${$_}{lookForThis} = 0 if not defined ${$_}{name};
        ${$_}{nested}      = 0 if not defined ${$_}{nested};

        # look up for middle, if any
        if ( defined ${$_}{middle} ) {
            if ( ref( ${$_}{middle} ) eq 'ARRAY' ) {
                ${ $mainSetting{specialLookUpMiddle} }{ ${$_}{name} } = join( "|", @{ ${$_}{middle} } );
            }
            else {
                ${ $mainSetting{specialLookUpMiddle} }{ ${$_}{name} } = ${$_}{middle};
            }
        }
    }

    # some users may wish to see showAmalgamatedSettings
    # which details the overall state of the settings modified
    # from the default in various user files
    if ( $mainSetting{logFilePreferences}{showAmalgamatedSettings} ) {
        $logger->info("Amalgamated/overall settings to be used:\t\t(see logFilePreferences: showAmalgamatedSettings)");
        $logger->info( Dumper( \%mainSetting ) );
    }

    # Comma poly-switch check
    if ($is_m_switch_active) {

        # key = value poly-switches: EqualsStartsOnOwnLine or EqualsFinishesWithLineBreak
        while ( my ( $polySwitch, $value ) = each %{ $mainSetting{modifyLineBreaks}{keyEqualsValuesBracesBrackets} } ) {
            last if $equalsPolySwitchExists;
            if ( ( $polySwitch eq 'EqualsStartsOnOwnLine' or $polySwitch eq 'EqualsFinishesWithLineBreak' )
                and $value != 0 )
            {
                $equalsPolySwitchExists = 1;
                $logger->trace("*poly-switch info: $polySwitch $value for keyEqualsValuesBracesBrackets");
            }

            # per-name key = value poly-switches: EqualsStartsOnOwnLine or EqualsFinishesWithLineBreak
            if ( ref ${ $mainSetting{modifyLineBreaks}{keyEqualsValuesBracesBrackets} }{$polySwitch} eq "HASH" ) {
                while ( my ( $perNamePolySwitch, $perNameValue )
                    = each %{ ${ $mainSetting{modifyLineBreaks}{keyEqualsValuesBracesBrackets} }{$polySwitch} } )
                {
                    last if $equalsPolySwitchExists;
                    if ((      $perNamePolySwitch eq 'EqualsStartsOnOwnLine'
                            or $perNamePolySwitch eq 'EqualsFinishesWithLineBreak'
                        )
                        and $perNameValue != 0
                        )
                    {
                        $equalsPolySwitchExists = 1;
                        $logger->trace(
                            "*poly-switch info: $perNamePolySwitch $perNameValue for keyEqualsValuesBracesBrackets ($polySwitch)"
                        );
                    }
                }
            }
        }

        # OPTIONAL arguments
        while ( my ( $polySwitch, $value ) = each %{ $mainSetting{modifyLineBreaks}{optionalArguments} } ) {
            last if $commaPolySwitchExists;
            if ( ( $polySwitch eq 'CommaStartsOnOwnLine' or $polySwitch eq 'CommaFinishesWithLineBreak' )
                and $value != 0 )
            {
                $commaPolySwitchExists = 1;
                $logger->trace("*poly-switch info: $polySwitch $value for optionalArguments");
            }

            # per-name OPTIONAL arguments
            if ( ref ${ $mainSetting{modifyLineBreaks}{optionalArguments} }{$polySwitch} eq "HASH" ) {
                while ( my ( $perNamePolySwitch, $perNameValue )
                    = each %{ ${ $mainSetting{modifyLineBreaks}{optionalArguments} }{$polySwitch} } )
                {
                    last if $commaPolySwitchExists;
                    if ((      $perNamePolySwitch eq 'CommaStartsOnOwnLine'
                            or $perNamePolySwitch eq 'CommaFinishesWithLineBreak'
                        )
                        and $perNameValue != 0
                        )
                    {
                        $commaPolySwitchExists = 1;
                        $logger->trace(
                            "*poly-switch info: $perNamePolySwitch $perNameValue for optionalArguments ($polySwitch)");
                    }
                }
            }
        }

        # MANDATORY arguments
        while ( my ( $polySwitch, $value ) = each %{ $mainSetting{modifyLineBreaks}{mandatoryArguments} } ) {
            last if $commaPolySwitchExists;
            if ( ( $polySwitch eq 'CommaStartsOnOwnLine' or $polySwitch eq 'CommaFinishesWithLineBreak' )
                and $value != 0 )
            {
                $commaPolySwitchExists = 1;
                $logger->trace("*poly-switch info: $polySwitch $value for mandatoryArguments");
            }

            # per-name MANDATORY arguments
            if ( ref ${ $mainSetting{modifyLineBreaks}{mandatoryArguments} }{$polySwitch} eq "HASH" ) {
                while ( my ( $perNamePolySwitch, $perNameValue )
                    = each %{ ${ $mainSetting{modifyLineBreaks}{mandatoryArguments} }{$polySwitch} } )
                {
                    last if $commaPolySwitchExists;
                    if ((      $perNamePolySwitch eq 'CommaStartsOnOwnLine'
                            or $perNamePolySwitch eq 'CommaFinishesWithLineBreak'
                        )
                        and $perNameValue != 0
                        )
                    {
                        $commaPolySwitchExists = 1;
                        $logger->trace(
                            "*poly-switch info: $perNamePolySwitch $perNameValue for mandatoryArguments ($polySwitch)");
                    }
                }
            }
        }
    }

    # set up poly-switch names/aliases
    %polySwitchNames = (
        environments => (
            {   BeginStartsOnOwnLine     => "BeginStartsOnOwnLine",
                BodyStartsOnOwnLine      => "BodyStartsOnOwnLine",
                EndStartsOnOwnLine       => "EndStartsOnOwnLine",
                EndFinishesWithLineBreak => "EndFinishesWithLineBreak"
            }
        ),
        ifElseFi => (
            {   BeginStartsOnOwnLine     => "IfStartsOnOwnLine",
                BodyStartsOnOwnLine      => "BodyStartsOnOwnLine",
                EndStartsOnOwnLine       => "FiStartsOnOwnLine",
                EndFinishesWithLineBreak => "FiFinishesWithLineBreak"
            }
        ),
        commands          => ( { BeginStartsOnOwnLine => "CommandStartsOnOwnLine", } ),
        optionalArguments => (
            {   BeginStartsOnOwnLine     => "LSqBStartsOnOwnLine",
                BodyStartsOnOwnLine      => "OptArgBodyStartsOnOwnLine",
                EndStartsOnOwnLine       => "RSqBStartsOnOwnLine",
                EndFinishesWithLineBreak => "RSqBFinishesWithLineBreak"
            }
        ),
        mandatoryArguments => (
            {   BeginStartsOnOwnLine     => "LCuBStartsOnOwnLine",
                BodyStartsOnOwnLine      => "MandArgBodyStartsOnOwnLine",
                EndStartsOnOwnLine       => "RCuBStartsOnOwnLine",
                EndFinishesWithLineBreak => "RCuBFinishesWithLineBreak"
            }
        ),
        keyEqualsValuesBracesBrackets => ( { BeginStartsOnOwnLine => "KeyStartsOnOwnLine", } ),
        namedGroupingBracesBrackets   => (
            {   BeginStartsOnOwnLine => "NameStartsOnOwnLine",
                BodyStartsOnOwnLine  => "NameFinishesWithLineBreak",
            }
        ),
        items => (
            { BeginStartsOnOwnLine => "ItemStartsOnOwnLine", BodyStartsOnOwnLine => "ItemFinishesWithLineBreak" }
        ),
        verbatim => (
            {   BeginStartsOnOwnLine     => "VerbatimBeginStartsOnOwnLine",
                EndFinishesWithLineBreak => "VerbatimEndFinishesWithLineBreak"
            }
        ),
        DBS => ( { BeginStartsOnOwnLine => "DBSStartsOnOwnLine", BodyStartsOnOwnLine => "DBSFinishesWithLineBreak" } ),
        UnNamedGroupingBracesBrackets => ( { BeginStartsOnOwnLineAlias => undef, } ),
        specialBeginEnd               => (
            {   BeginStartsOnOwnLine     => "SpecialBeginStartsOnOwnLine",
                BodyStartsOnOwnLine      => "SpecialBodyStartsOnOwnLine",
                EndStartsOnOwnLine       => "SpecialEndStartsOnOwnLine",
                EndFinishesWithLineBreak => "SpecialEndFinishesWithLineBreak"
            }
        )
    );

    # configure lookForAlignDelimsDefaults
    @alignAtAmpersandInformation = (
        {   name     => "lookForAlignDelims",
            yamlname => "delims",
            default  => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{delims}
        },
        {   name    => "alignDoubleBackSlash",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{alignDoubleBackSlash}
        },
        {   name    => "spacesBeforeDoubleBackSlash",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{spacesBeforeDoubleBackSlash}
        },
        {   name    => "multiColumnGrouping",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{multiColumnGrouping}
        },
        {   name    => "alignRowsWithoutMaxDelims",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{alignRowsWithoutMaxDelims}
        },
        {   name    => "spacesBeforeAmpersand",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{spacesBeforeAmpersand}
        },
        {   name    => "spacesAfterAmpersand",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{spacesAfterAmpersand}
        },
        {   name    => "justification",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{justification}
        },
        {   name    => "alignFinalDoubleBackSlash",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{alignFinalDoubleBackSlash}
        },
        { name => "dontMeasure", default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{dontMeasure} },
        {   name    => "delimiterRegEx",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{delimiterRegEx}
        },
        {   name    => "delimiterJustification",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{delimiterJustification}
        },
        { name => "leadingBlankColumn", default => -1 },
        {   name    => "lookForChildCodeBlocks",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{lookForChildCodeBlocks}
        },
        {   name    => "alignContentAfterDoubleBackSlash",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{alignContentAfterDoubleBackSlash}
        },
        {   name    => "spacesAfterDoubleBackSlash",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{spacesAfterDoubleBackSlash}
        },
        {   name    => "doubleBackSlash",
            default => ${ $mainSetting{fineTuning}{lookForAlignDelimsDefaults} }{doubleBackSlash}
        },
    );

    $self->yaml_obsolete_checks;
    return;
}

sub yaml_obsolete_checks {

    return
        unless ( defined $mainSetting{preambleCommandsBeforeEnvironments}
        or defined $mainSetting{itemNames}
        or defined ${ $mainSetting{noAdditionalIndentGlobal} }{filecontents}
        or defined ${ $mainSetting{indentRulesGlobal} }{filecontents}
        or defined $mainSetting{commandCodeBlocks}
        or defined ${ ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{blocksFollow} }{filecontents}
        or defined ${ ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{blocksEndBefore} }{filecontents}
        or defined ${ $mainSetting{fineTuning}{items} }{canBeFollowedBy}
        or defined ${ $mainSetting{fineTuning}{keyEqualsValuesBracesBrackets} }{follow}
        or defined ${ $mainSetting{fineTuning}{namedGroupingBracesBrackets} }{follow}
        or defined ${ $mainSetting{fineTuning}{UnNamedGroupingBracesBrackets} }{follow}
        or defined ${ $mainSetting{fineTuning}{arguments} }{before} );
    $logger->warn("*Obsolete YAML");

    my $obsoleteString = " obsolete, no need for it from V4.0";
    if ( defined $mainSetting{preambleCommandsBeforeEnvironments} ) {
        $logger->warn("preambleCommandsBeforeEnvironments$obsoleteString");
        delete $mainSetting{preambleCommandsBeforeEnvironments};
    }
    if ( defined $mainSetting{itemNames} ) {
        $logger->warn("itemNames obsolete, use fineTuning: items: itemRegex instead");
        delete $mainSetting{itemNames};
    }

    if ( defined ${ $mainSetting{noAdditionalIndentGlobal} }{filecontents} ) {
        $logger->warn("noAdditionalIndentGlobal: filecontents$obsoleteString");
        delete ${ $mainSetting{noAdditionalIndentGlobal} }{filecontents};
    }

    if ( defined ${ $mainSetting{indentRulesGlobal} }{filecontents} ) {
        $logger->warn("indentRulesGlobal: filecontents$obsoleteString");
        delete ${ $mainSetting{indentRulesGlobal} }{filecontents};
    }

    if ( defined $mainSetting{commandCodeBlocks} ) {
        $logger->warn("commandCodeBlocks$obsoleteString");
        delete $mainSetting{commandCodeBlocks};
    }

    if ( defined ${ ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{blocksFollow} }{filecontents} ) {
        $logger->warn("modifyLineBreaks: textWrapOptions: blocksFollow: filecontents$obsoleteString");
        delete ${ ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{blocksFollow} }{filecontents};
    }

    if ( defined ${ ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{blocksEndBefore} }{filecontents} ) {
        $logger->warn("modifyLineBreaks: textWrapOptions: blocksEndBefore: filecontents$obsoleteString");
        delete ${ ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{blocksEndBefore} }{filecontents};
    }

    if ( defined ${ $mainSetting{fineTuning}{items} }{canBeFollowedBy} ) {
        $logger->warn("fineTuning: items: canBeFollowedBy$obsoleteString");
        delete ${ $mainSetting{fineTuning}{items} }{canBeFollowedBy};
    }

    if ( defined ${ $mainSetting{fineTuning}{keyEqualsValuesBracesBrackets} }{follow} ) {
        $logger->warn("fineTuning: keyEqualsValuesBracesBrackets: follow$obsoleteString");
        delete ${ $mainSetting{fineTuning}{keyEqualsValuesBracesBrackets} }{follow};
    }

    if ( defined ${ $mainSetting{fineTuning}{namedGroupingBracesBrackets} }{follow} ) {
        $logger->warn("fineTuning: namedGroupingBracesBrackets: follow$obsoleteString");
        delete ${ $mainSetting{fineTuning}{namedGroupingBracesBrackets} }{follow};
    }

    if ( defined ${ $mainSetting{fineTuning}{UnNamedGroupingBracesBrackets} }{follow} ) {
        $logger->warn("fineTuning: UnNamedGroupingBracesBrackets: follow$obsoleteString");
        delete ${ $mainSetting{fineTuning}{UnNamedGroupingBracesBrackets} }{follow};
    }

    if ( defined ${ $mainSetting{fineTuning}{arguments} }{before} ) {
        $logger->warn("fineTuning: arguments: before$obsoleteString");
        delete ${ $mainSetting{fineTuning}{arguments} }{before};
    }

    return;
}

sub yaml_get_indentation_settings_for_this_object {
    my $self = shift;

    # create a name for previously found settings
    my $storageName
        = ${$self}{name}
        . ${$self}{modifyLineBreaksYamlName}
        . ( defined ${$self}{storageNameAppend} ? ${$self}{storageNameAppend} : q() );

    # check for storage of repeated objects
    if ( $previouslyFoundSetting{$storageName} ) {
        $logger->trace("*Using stored settings for $storageName") if ($is_t_switch_active);
    }
    else {
        my $name = ${$self}{name};

        # check for noAdditionalIndent OR indentRules OR defaultIndent
        my $indentationAttribute = ( ${$self}{modifyLineBreaksYamlName} eq "afterHeading" ? "afterHeading" : "body" );
        my $indentation          = $self->yaml_get_indentation_information( thing => $indentationAttribute );

        # check for alignment at ampersand settings
        $self->yaml_alignment_at_ampersand_settings;

        # minimal previouslyFoundSetting, possibly added to depending on switches
        %{ ${previouslyFoundSetting}{$storageName} } = ( indentation => $indentation, );

        # t switch gives more information to the log file
        ${ ${previouslyFoundSetting}{$storageName} }{AMETA}
            = { name => ${$self}{name}, type => ${$self}{modifyLineBreaksYamlName} }
            if $is_t_switch_active;

        # check for line break settings
        if ($is_m_switch_active) {
            $self->yaml_modify_line_breaks_settings;

            # poly-switches
            foreach (
                # basics
                "BeginStartsOnOwnLine", "BodyStartsOnOwnLine", "EndStartsOnOwnLine", "EndFinishesWithLineBreak",

                # key = value specific
                "EqualsStartsOnOwnLine", "EqualsFinishesWithLineBreak",

                # specialBeginEnd specific
                "SpecialMiddleStartsOnOwnLine", "SpecialMiddleFinishesWithLineBreak",

                # ifElseFi specific
                "ElseStartsOnOwnLine", "ElseFinishesWithLineBreak", "OrStartsOnOwnLine", "OrFinishesWithLineBreak",

                # DBS specific
                "DBSStartsOnOwnLine", "DBSFinishesWithLineBreak",
                )
            {
                ${ ${previouslyFoundSetting}{$storageName} }{$_} = ${$self}{$_} if defined ${$self}{$_};
                delete ${$self}{$_};
            }
        }

        # store argument information, if arguments present
        if ( ${$self}{arguments} ) {

            #
            # mandatory arguments
            #
            my $actualModifyLineBreaksYamlName = ${$self}{modifyLineBreaksYamlName};
            ${$self}{modifyLineBreaksYamlName} = "mandatoryArguments";
            $logger->trace("${$self}{modifyLineBreaksYamlName} info:") if ($is_t_switch_active);
            ${ ${previouslyFoundSetting}{$storageName} }{mandatoryArgumentsIndentation}
                = $self->yaml_get_indentation_information( thing => "mandatoryArguments" );

            # mandatory arguments, poly-switches
            if ($is_m_switch_active) {

                # get poly switch values
                $self->yaml_modify_line_breaks_settings;

                # store poly switch values
                ${ ${ ${previouslyFoundSetting}{$storageName} }{mand} }{LCuBStartsOnOwnLine}
                    = ${$self}{BeginStartsOnOwnLine};
                ${ ${ ${previouslyFoundSetting}{$storageName} }{mand} }{MandArgBodyStartsOnOwnLine}
                    = ${$self}{BodyStartsOnOwnLine};
                ${ ${ ${previouslyFoundSetting}{$storageName} }{mand} }{RCuBStartsOnOwnLine}
                    = ${$self}{EndStartsOnOwnLine};
                ${ ${ ${previouslyFoundSetting}{$storageName} }{mand} }{RCuBFinishesWithLineBreak}
                    = ${$self}{EndFinishesWithLineBreak};

                foreach (
                    "CommaStartsOnOwnLine", "CommaFinishesWithLineBreak",
                    "DBSStartsOnOwnLine",   "DBSFinishesWithLineBreak"
                    )
                {
                    next unless defined ${$self}{$_};
                    ${ ${ ${previouslyFoundSetting}{$storageName} }{mand} }{$_} = ${$self}{$_};
                    delete ${$self}{$_};
                }
            }

            #
            # optional arguments
            #
            ${$self}{modifyLineBreaksYamlName} = "optionalArguments";
            $logger->trace("${$self}{modifyLineBreaksYamlName} info:") if ($is_t_switch_active);
            ${ ${previouslyFoundSetting}{$storageName} }{optionalArgumentsIndentation}
                = $self->yaml_get_indentation_information( thing => "optionalArguments" );

            # optional arguments, poly-switches
            if ($is_m_switch_active) {

                # get poly switch values
                $self->yaml_modify_line_breaks_settings;

                # store poly switch values
                ${ ${ ${previouslyFoundSetting}{$storageName} }{opt} }{LSqBStartsOnOwnLine}
                    = ${$self}{BeginStartsOnOwnLine};
                ${ ${ ${previouslyFoundSetting}{$storageName} }{opt} }{OptArgBodyStartsOnOwnLine}
                    = ${$self}{BodyStartsOnOwnLine};
                ${ ${ ${previouslyFoundSetting}{$storageName} }{opt} }{RSqBStartsOnOwnLine}
                    = ${$self}{EndStartsOnOwnLine};
                ${ ${ ${previouslyFoundSetting}{$storageName} }{opt} }{RSqBFinishesWithLineBreak}
                    = ${$self}{EndFinishesWithLineBreak};
                foreach (
                    "CommaStartsOnOwnLine", "CommaFinishesWithLineBreak",
                    "DBSStartsOnOwnLine",   "DBSFinishesWithLineBreak"
                    )
                {
                    next unless defined ${$self}{$_};
                    ${ ${ ${previouslyFoundSetting}{$storageName} }{opt} }{$_} = ${$self}{$_};
                    delete ${$self}{$_};
                }
            }

            # change modifyLineBreaksYamlName back to its actual value (it's not an argument)
            ${$self}{modifyLineBreaksYamlName} = $actualModifyLineBreaksYamlName;
        }

        # text wrap 'after' information
        if (    $is_m_switch_active
            and ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{when} eq 'after'
            and defined ${$self}{indentRule} )
        {
            ${ ${previouslyFoundSetting}{textWrapAfter} }{$name} = $indentation;
        }

        # don't forget alignment settings!
        foreach (@alignAtAmpersandInformation) {
            ${ ${previouslyFoundSetting}{$storageName} }{ ${$_}{name} } = ${$self}{ ${$_}{name} }
                if ( defined ${$self}{ ${$_}{name} } );
        }

        # headings
        if ( ${$self}{modifyLineBreaksYamlName} eq 'afterHeading' and defined ${$self}{blocksEndBefore} ) {
            @{ ${$self}{additionalAssignments} } = ("blocksEndBefore");
        }

        # some objects, e.g ifElseFi, can have extra assignments, e.g ElseStartsOnOwnLine
        # these need to be stored as well!
        foreach ( @{ ${$self}{additionalAssignments} } ) {
            ${ ${previouslyFoundSetting}{$storageName} }{$_} = ${$self}{$_};
        }

        # log file information
        $logger->trace("*$name settings (stored for future use):")             if $is_t_switch_active;
        $logger->trace( Dumper \%{ ${previouslyFoundSetting}{$storageName} } ) if $is_t_switch_active;

    }

    # append indentation settings to the current object
    while ( my ( $key, $value ) = each %{ ${previouslyFoundSetting}{$storageName} } ) {
        ${$self}{$key} = $value;
    }

    return;
}

sub yaml_get_alignment_at_ampersand_from_parent {

    # arguments get alignment settings from their parent information
    # see, for example, test-cases/alignment/matrix1.tex
    my $self       = shift;
    my $parentName = shift;
    foreach (@alignAtAmpersandInformation) {
        ${$self}{ ${$_}{name} } = ${ ${previouslyFoundSetting}{$parentName} }{ ${$_}{name} }
            if ( defined ${ ${previouslyFoundSetting}{$parentName} }{ ${$_}{name} } );
    }
    return;
}

sub yaml_alignment_at_ampersand_settings {
    my $self = shift;

# if the YamlName is, for example, optionalArguments, mandatoryArguments, heading, then we'll be looking for information about the *parent*
    my $name = ( defined ${$self}{nameForIndentationSettings} ) ? ${$self}{nameForIndentationSettings} : ${$self}{name};

    # check, for example,
    #   lookForAlignDelims:
    #      tabular: 1
    # or
    #
    #   lookForAlignDelims:
    #      tabular:
    #         delims: 1
    #         alignDoubleBackSlash: 1
    #         spacesBeforeDoubleBackSlash: 2
    return unless ${ $mainSetting{lookForAlignDelims} }{$name};

    $logger->trace("alignAtAmpersand settings for $name (see lookForAlignDelims)") if ($is_t_switch_active);

    if ( ref ${ $mainSetting{lookForAlignDelims} }{$name} eq "HASH" ) {

        # specified as a hash, e.g
        #
        #   lookForAlignDelims:
        #      tabular:
        #         delims: 1
        #         alignDoubleBackSlash: 1
        #         spacesBeforeDoubleBackSlash: 2
        foreach (@alignAtAmpersandInformation) {
            my $yamlname = ( defined ${$_}{yamlname} ? ${$_}{yamlname} : ${$_}{name} );

            # each of the following cases need to be allowed:
            #
            #   lookForAlignDelims:
            #      aligned:
            #         spacesBeforeAmpersand:
            #           default: 1
            #           leadingBlankColumn: 0
            #
            #   lookForAlignDelims:
            #      aligned:
            #         spacesBeforeAmpersand:
            #           leadingBlankColumn: 0
            #
            #   lookForAlignDelims:
            #      aligned:
            #         spacesBeforeAmpersand:
            #           default: 0
            #
            # approach:
            #     - update mainSetting to have the relevant information: leadingBlankColumn and/or default
            #     - delete the spacesBeforeAmpersand hash
            #
            if ( $yamlname eq "spacesBeforeAmpersand"
                and ref( ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{spacesBeforeAmpersand} ) eq "HASH" )
            {
                $logger->trace("spacesBeforeAmpersand settings for $name") if $is_t_switch_active;

                #   lookForAlignDelims:
                #      aligned:
                #         spacesBeforeAmpersand:
                #           leadingBlankColumn: 0
                if (defined ${ ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{spacesBeforeAmpersand} }
                    {leadingBlankColumn} )
                {
                    $logger->trace("spacesBeforeAmpersand: leadingBlankColumn specified for $name")
                        if $is_t_switch_active;
                    ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{leadingBlankColumn}
                        = ${ ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{spacesBeforeAmpersand} }
                        {leadingBlankColumn};
                }

                #   lookForAlignDelims:
                #      aligned:
                #         spacesBeforeAmpersand:
                #           default: 0
                if ( defined ${ ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{spacesBeforeAmpersand} }{default} ) {
                    ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{spacesBeforeAmpersand}
                        = ${ ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{spacesBeforeAmpersand} }{default};
                }
                else {
                    # deleting spacesBeforeAmpersand hash allows spacesBeforeAmpersand
                    # to pull from the default values @alignAtAmpersandInformation
                    delete ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{spacesBeforeAmpersand};
                }
            }
            ${$self}{ ${$_}{name} }
                = ( defined ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{$yamlname} )
                ? ${ ${ $mainSetting{lookForAlignDelims} }{$name} }{$yamlname}
                : ${$_}{default};
        }
    }
    else {
        # specified as a scalar, e.g
        #
        #   lookForAlignDelims:
        #      tabular: 1
        foreach (@alignAtAmpersandInformation) {
            ${$self}{ ${$_}{name} } = ${$_}{default};
        }
    }
    return;
}

sub yaml_modify_line_breaks_settings {
    my $self = shift;

    my $modifyLineBreaksYamlName = ${$self}{modifyLineBreaksYamlName};

    # details to the log file
    $logger->trace("*-m modifylinebreaks poly-switch lookup for ${$self}{name}") if $is_t_switch_active;

    # some objects, e.g ifElseFi, can have extra assignments, e.g ElseStartsOnOwnLine
    my @toBeAssignedTo = ${$self}{additionalAssignments} ? @{ ${$self}{additionalAssignments} } : ();

    # the following will *definitley* be in the array, so let's add them
    push(
        @toBeAssignedTo,
        (   "BeginStartsOnOwnLine", "BodyStartsOnOwnLine", "EndStartsOnOwnLine", "EndFinishesWithLineBreak",
            "DBSStartsOnOwnLine",   "DBSFinishesWithLineBreak"
        )
    );

    # arguments can have Comma poly switches
    if ( $modifyLineBreaksYamlName =~ m/Arguments/s ) {
        push( @toBeAssignedTo, ( "CommaStartsOnOwnLine", "CommaFinishesWithLineBreak" ) );
    }

    # key = value can have Equals poly switches
    if ( $modifyLineBreaksYamlName eq 'keyEqualsValuesBracesBrackets' ) {
        push( @toBeAssignedTo, ( "EqualsStartsOnOwnLine", "EqualsFinishesWithLineBreak" ) );
    }

    # specialBeginEnd can have middle poly-switches
    if ( $modifyLineBreaksYamlName eq 'specialBeginEnd' ) {
        push( @toBeAssignedTo, ( "SpecialMiddleStartsOnOwnLine", "SpecialMiddleFinishesWithLineBreak" ) );
    }

    # ifElseFi can have ELSE/OR poly-switches
    if ( $modifyLineBreaksYamlName eq 'ifElseFi' ) {
        push( @toBeAssignedTo,
            ( "ElseStartsOnOwnLine", "ElseFinishesWithLineBreak", "OrStartsOnOwnLine", "OrFinishesWithLineBreak" ) );
    }

    # we can efficiently loop through the following
    foreach (@toBeAssignedTo) {
        $self->yaml_poly_switch_get_every_or_custom_value(
            toBeAssignedTo      => $_,
            toBeAssignedToAlias => ${ $polySwitchNames{$modifyLineBreaksYamlName} }{$_}
            ? ${ $polySwitchNames{$modifyLineBreaksYamlName} }{$_}
            : $_,
        );
    }

    return;
}

sub yaml_poly_switch_get_every_or_custom_value {
    my $self  = shift;
    my %input = @_;

    my $toBeAssignedTo      = $input{toBeAssignedTo};
    my $toBeAssignedToAlias = $input{toBeAssignedToAlias};

    # name of the object in the modifyLineBreaks yaml (e.g environments, ifElseFi, etc)
    my $YamlName = ${$self}{modifyLineBreaksYamlName};

    # name of the object
    my $name = ${$self}{name};

    # these variables just ease the notation what follows
    my $everyValue  = ${ ${ $mainSetting{modifyLineBreaks} }{$YamlName} }{$toBeAssignedToAlias};
    my $customValue = ${ ${ ${ $mainSetting{modifyLineBreaks} }{$YamlName} }{$name} }{$toBeAssignedToAlias};

    # check for the *custom* value
    if ( defined $customValue ) {
        $logger->trace("$name: $toBeAssignedToAlias=$customValue\t\t\t(*per-name* value)")
            if ($is_t_switch_active);
        ${$self}{$toBeAssignedTo} = $customValue;
    }
    else {
        # check for the *every* value
        if ( defined $everyValue ) {
            $logger->trace("$name: $toBeAssignedToAlias=$everyValue\t\t\t(*global* value)")
                if ($is_t_switch_active);
            ${$self}{$toBeAssignedTo} = $everyValue;
        }
    }
    return;
}

sub yaml_get_indentation_information {
    my $self  = shift;
    my %input = @_;

    #**************************************
    # SEARCHING ORDER:
    #   noAdditionalIndent *per-name* basis
    #   indentRules *per-name* basis
    #   noAdditionalIndentGlobal
    #   indentRulesGlobal
    #**************************************

    # noAdditionalIndent can be a scalar or a hash, e.g
    #
    #   noAdditionalIndent:
    #       myexample: 1
    #
    # OR
    #
    #   noAdditionalIndent:
    #       myexample:
    #           body: 1
    #           optionalArguments: 1
    #           mandatoryArguments: 1
    #
    # specifying as a scalar with no field (e.g myexample: 1)
    # will be interpreted as noAdditionalIndent for *every*
    # field, so the body, optional arguments and mandatory arguments
    # will *all* receive noAdditionalIndent
    #
    # indentRules can also be a scalar or a hash, e.g
    #   indentRules:
    #       myexample: "\t"
    #
    # OR
    #
    #   indentRules:
    #       myexample:
    #           body: "  "
    #           optionalArguments: "\t \t"
    #           mandatoryArguments: ""
    #
    # specifying as a scalar with no field will
    # mean that *every* field will receive the same treatment

    my $name = ${$self}{name};

    # unnamed arguments use 'always-un-named'
    $name = "always-un-named" if $name eq "";

    # body, optionalArguments, or mandatoryArguments
    my $YamlName = $input{thing};

    my $indentationInformation;
    foreach my $indentationAbout ( "noAdditionalIndent", "indentRules" ) {

        # check that the 'thing' is defined
        if ( defined ${ $mainSetting{$indentationAbout} }{$name} ) {
            if ( ref ${ $mainSetting{$indentationAbout} }{$name} eq "HASH" ) {
                $logger->trace(
                    "$indentationAbout indentation specified with multiple fields for $name (see $indentationAbout)")
                    if $is_t_switch_active;
                $logger->trace("searching for $indentationAbout: $name: $YamlName")           if $is_t_switch_active;
                $logger->trace( Dumper( \%{ ${ $mainSetting{$indentationAbout} }{$name} } ) ) if $is_t_switch_active;
                $indentationInformation = ${ ${ $mainSetting{$indentationAbout} }{$name} }{$YamlName};
            }
            else {
                $indentationInformation = ${ $mainSetting{$indentationAbout} }{$name};
                $logger->trace(
                    "$indentationAbout indentation specified for $name (for *all* fields, body, optionalArguments, mandatoryArguments, afterHeading), using '$indentationInformation' (see $indentationAbout)"
                ) if $is_t_switch_active;
            }

            # return, after performing an integrity check
            if ( defined $indentationInformation ) {
                if ( $indentationAbout eq "noAdditionalIndent" and $indentationInformation == 1 ) {
                    $logger->trace("Found! Using '' (see $indentationAbout)") if $is_t_switch_active;

                    # text wrapping 'after' requires knowledge of indent rules
                    #
                    if ( $is_m_switch_active
                        and ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{when} eq 'after' )
                    {
                        ${$self}{indentRule} = $indentationInformation;
                    }
                    return q();
                }
                elsif ( $indentationAbout eq "indentRules" and $indentationInformation =~ m/^\h*$/ ) {
                    $logger->trace("Found! Using '$indentationInformation' (see $indentationAbout)")
                        if $is_t_switch_active;

                    # text wrapping 'after' requires knowledge of indent rules
                    #
                    if ( $is_m_switch_active
                        and ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{when} eq 'after' )
                    {
                        ${$self}{indentRule} = $indentationInformation;
                    }
                    return $indentationInformation;
                }
            }
        }
    }

    # gather information
    $YamlName = ${$self}{modifyLineBreaksYamlName};

    foreach my $indentationAbout ( "noAdditionalIndent", "indentRules" ) {

        # global assignments in noAdditionalIndentGlobal and/or indentRulesGlobal
        my $globalInformation = $indentationAbout . "Global";
        next if ( !( defined ${ $mainSetting{$globalInformation} }{$YamlName} ) );
        if ( ( $globalInformation eq "noAdditionalIndentGlobal" )
            and ${ $mainSetting{$globalInformation} }{$YamlName} == 1 )
        {
            $logger->trace("$globalInformation specified for $YamlName (see $globalInformation)")
                if $is_t_switch_active;

            # text wrapping 'after' requires knowledge of indent rules
            #
            if ( $is_m_switch_active
                and ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{when} eq 'after' )
            {
                ${$self}{indentRule} = $indentationInformation;
            }
            return q();
        }
        elsif ( $globalInformation eq "indentRulesGlobal" ) {
            if ( ${ $mainSetting{$globalInformation} }{$YamlName} =~ m/^\h*$/ ) {
                $logger->trace("$globalInformation specified for $YamlName (see $globalInformation)")
                    if $is_t_switch_active;

                # text wrapping 'after' requires knowledge of indent rules
                #
                if ( $is_m_switch_active
                    and ${ $mainSetting{modifyLineBreaks}{textWrapOptions} }{when} eq 'after' )
                {
                    ${$self}{indentRule} = $indentationInformation;
                }
                return ${ $mainSetting{$globalInformation} }{$YamlName};
            }
            elsif ( ${ $mainSetting{$globalInformation} }{$YamlName} ne '0' ) {
                $logger->warn(
                    "$globalInformation specified (${$mainSetting{$globalInformation}}{$YamlName}) for $YamlName, but it needs to only contain horizontal space -- I'm ignoring this one"
                );
            }
        }
    }

    # return defaultIndent, by default
    $logger->trace("Using defaultIndent for $name") if $is_t_switch_active;
    return $mainSetting{defaultIndent};
}

sub yaml_get_object_attribute_for_indentation_settings {

    # when looking for noAdditionalIndent or indentRules, we may need to determine
    # which thing we're looking for, e.g
    #
    #   chapter:
    #       body: 0
    #       optionalArguments: 1
    #       mandatoryArguments: 1
    #       afterHeading: 0
    #
    # this method returns 'body' by default, but the other objects (optionalArgument, mandatoryArgument, afterHeading)
    # return their appropriate identifier.
    return "body";
}

sub yaml_update_dumper_settings {

    # log file preferences
    $Data::Dumper::Terse     = ${ $mainSetting{logFilePreferences}{Dumper} }{Terse};
    $Data::Dumper::Indent    = ${ $mainSetting{logFilePreferences}{Dumper} }{Indent};
    $Data::Dumper::Useqq     = ${ $mainSetting{logFilePreferences}{Dumper} }{Useqq};
    $Data::Dumper::Deparse   = ${ $mainSetting{logFilePreferences}{Dumper} }{Deparse};
    $Data::Dumper::Quotekeys = ${ $mainSetting{logFilePreferences}{Dumper} }{Quotekeys};
    $Data::Dumper::Sortkeys  = ${ $mainSetting{logFilePreferences}{Dumper} }{Sortkeys};
    $Data::Dumper::Pair      = ${ $mainSetting{logFilePreferences}{Dumper} }{Pair};

}
1;
