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
#	Chris Hughes, 2017
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use LatexIndent::Switches qw/%switches $is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use YAML::Tiny;                # interpret defaultSettings.yaml and other potential settings files
use File::Basename;            # to get the filename and directory path
use File::HomeDir;
use Log::Log4perl qw(get_logger :levels);
use Exporter qw/import/;
our @EXPORT_OK = qw/readSettings modify_line_breaks_settings get_indentation_settings_for_this_object get_every_or_custom_value get_indentation_information get_object_attribute_for_indentation_settings alignment_at_ampersand_settings %masterSettings/;

# Read in defaultSettings.YAML file
our $defaultSettings;

# master yaml settings is a hash, global to this module
our %masterSettings;

# previously found settings is a hash, global to this module
our %previouslyFoundSettings;

# default values for align at ampersand routine
our @alignAtAmpersandInformation = (   {name=>"lookForAlignDelims",yamlname=>"delims",default=>1},
                                       {name=>"alignDoubleBackSlash",default=>1},
                                       {name=>"spacesBeforeDoubleBackSlash",default=>1},
                                       {name=>"multiColumnGrouping",default=>0},
                                       {name=>"alignRowsWithoutMaxDelims",default=>1},
                                       {name=>"spacesBeforeAmpersand",default=>1},
                                       {name=>"spacesAfterAmpersand",default=>1},
                                        );
    
sub readSettings{
  my $self = shift;
  
  # read the default settings
  $defaultSettings = YAML::Tiny->read( "$FindBin::RealBin/defaultSettings.yaml" );

  # grab the logger object
  my $logger = get_logger("Document");
  $logger->info("*YAML settings read: defaultSettings.yaml\nReading defaultSettings.yaml from $FindBin::RealBin/defaultSettings.yaml");
  
  # if latexindent.exe is invoked from TeXLive, then defaultSettings.yaml won't be in 
  # the same directory as it; we need to navigate to it
  if(!$defaultSettings) {
    $defaultSettings = YAML::Tiny->read( "$FindBin::RealBin/../../texmf-dist/scripts/latexindent/defaultSettings.yaml");
    $logger->info("Reading defaultSettings.yaml (2nd attempt, TeXLive, Windows) from $FindBin::RealBin/../../texmf-dist/scripts/latexindent/defaultSettings.yaml");
  }

  # need to exit if we can't get defaultSettings.yaml
  die "Could not open defaultSettings.yaml" if(!$defaultSettings);
   
  # master yaml settings is a hash, global to this module
  our %masterSettings = %{$defaultSettings->[0]};

  # scalar to read user settings
  my $userSettings;

  # array to store the paths to user settings
  my @absPaths;
  
  # we'll need the home directory a lot in what follows
  my $homeDir = File::HomeDir->my_home; 
  $logger->info("*YAML settings read: indentconfig.yaml or .indentconfig.yaml") unless $switches{onlyDefault};
  
  # get information about user settings- first check if indentconfig.yaml exists
  my $indentconfig = "$homeDir/indentconfig.yaml";

  # if indentconfig.yaml doesn't exist, check for the hidden file, .indentconfig.yaml
  $indentconfig = "$homeDir/.indentconfig.yaml" if(! -e $indentconfig);

  # messages for indentconfig.yaml and/or .indentconfig.yaml
  if ( -e $indentconfig and !$switches{onlyDefault}) {
        $logger->info("Reading path information from $indentconfig");
        # if both indentconfig.yaml and .indentconfig.yaml exist
        if ( -e File::HomeDir->my_home . "/indentconfig.yaml" and  -e File::HomeDir->my_home . "/.indentconfig.yaml") {
              $logger->info("$homeDir/.indentconfig.yaml has been found, but $indentconfig takes priority");
        } elsif ( -e File::HomeDir->my_home . "/indentconfig.yaml" ) {
              $logger->info("(Alternatively $homeDir/.indentconfig.yaml can be used)");
        } elsif ( -e File::HomeDir->my_home . "/.indentconfig.yaml" ) {
              $logger->info("(Alternatively $homeDir/indentconfig.yaml can be used)");
        }
        
        # read the absolute paths from indentconfig.yaml
        $userSettings = YAML::Tiny->read( "$indentconfig" );

        # output the contents of indentconfig to the log file
        $logger->info(Dump \%{$userSettings->[0]});
        
        # update the absolute paths
        @absPaths = @{$userSettings->[0]->{paths}};
  } else {
     if($switches{onlyDefault}) {
        $logger->info("*-d switch active: only default settings requested");
        $logger->info("not reading USER settings from $indentconfig") if (-e $indentconfig);
        $logger->info("Ignoring the -l switch: $switches{readLocalSettings} (you used the -d switch)") if($switches{readLocalSettings});
        $logger->info("Ignoring the -y switch: $switches{yaml} (you used the -d switch)") if($switches{yaml});
        $switches{readLocalSettings}=0;
        $switches{yaml}=0;
     } else {
       # give the user instructions on where to put indentconfig.yaml or .indentconfig.yaml
       $logger->info("Home directory is $homeDir (didn't find either indentconfig.yaml or .indentconfig.yaml)\nTo specify user settings you would put indentconfig.yaml here: $homeDir/indentconfig.yaml\nAlternatively, you can use the hidden file .indentconfig.yaml as: $homeDir/.indentconfig.yaml");
     }
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

  $logger->info("*YAML settings read: -l switch") if $switches{readLocalSettings};

  # remove leading, trailing, and intermediate space
  $switches{readLocalSettings} =~ s/^\h*//g;
  $switches{readLocalSettings} =~ s/\h*$//g;
  $switches{readLocalSettings} =~ s/\h*,\h*/,/g;
  if($switches{readLocalSettings} =~ m/\+/){
        $logger->info("+ found in call for -l switch: will add localSettings.yaml");

        # + can be either at the beginning or the end, which determines if where the comma should go
        my $commaAtBeginning = ($switches{readLocalSettings} =~ m/^\h*\+/ ? q() : ",");
        my $commaAtEnd = ($switches{readLocalSettings} =~ m/^\h*\+/ ? "," : q());
        $switches{readLocalSettings} =~ s/\h*\+\h*/$commaAtBeginning."localSettings.yaml".$commaAtEnd/e; 
        $logger->info("New value of -l switch: $switches{readLocalSettings}");
  }

  # local settings can be separated by ,
  # e.g  
  #     -l = myyaml1.yaml,myyaml2.yaml
  # and in which case, we need to read them all
  if($switches{readLocalSettings} =~ m/,/){
        $logger->info("Multiple localSettings found, separated by commas:");
        @localSettings = split(/,/,$switches{readLocalSettings});
        $logger->info(join(', ',@localSettings));
  } else {
    push(@localSettings,$switches{readLocalSettings}) if($switches{readLocalSettings});
  }

  # add local settings to the paths, if appropriate
  foreach (@localSettings) {
    # check for an extension (.yaml)
    my ($name, $dir , $ext) = fileparse($_, "yaml");

    # if no extension is found, append the current localSetting with .yaml
    $_ = $_.($_=~m/\.\z/ ? q() : ".")."yaml" if(!$ext);

    # if the -l switch is called on its own, or else with +
    # and latexindent.pl is called from a different directory, then
    # we need to account for this
    if($_ eq "localSettings.yaml"){
        $_ = dirname (${$self}{fileName})."/".$_;
    }

    # check for existence and non-emptiness
    if ( (-e $_) and !(-z $_)) {
        $logger->info("Adding $_ to YAML read paths");
        push(@absPaths,"$_");
    } elsif ( !(-e $_) ) {
        $logger->warn("*yaml file not found: $_ not found. Proceeding without it.");
    }
  }

  # heading for the log file
  $logger->info("*YAML settings, reading from the following files:") if @absPaths;

  # read in the settings from each file
  foreach my $settings (@absPaths) {
    # check that the settings file exists and that it isn't empty
    if (-e $settings and !(-z $settings)) {
        $logger->info("Reading USER settings from $settings");
        $userSettings = YAML::Tiny->read( "$settings" );
  
        # if we can read userSettings
        if($userSettings) {
              # update the MASTER setttings to include updates from the userSettings
              while(my($firstLevelKey, $firstLevelValue) = each %{$userSettings->[0]}) {
                      # the update approach is slightly different for hashes vs scalars/arrays
                      if (ref($firstLevelValue) eq "HASH") {
                          while(my ($secondLevelKey,$secondLevelValue) = each %{$userSettings->[0]{$firstLevelKey}}) {
                            if (ref $secondLevelValue eq "HASH"){
                                # if masterSettings already contains a *scalar* value in secondLevelKey
                                # then we need to delete it (test-cases/headings-first.tex with indentRules1.yaml first demonstrated this)
                                if(ref $masterSettings{$firstLevelKey}{$secondLevelKey} ne "HASH"){
                                    $logger->trace("*masterSettings{$firstLevelKey}{$secondLevelKey} currently contains a *scalar* value, but it needs to be updated with a hash (see $settings); deleting the scalar") if($is_t_switch_active);
                                    delete $masterSettings{$firstLevelKey}{$secondLevelKey} ;
                                }
                                while(my ($thirdLevelKey,$thirdLevelValue) = each %{$secondLevelValue}) {
                                    if (ref $thirdLevelValue eq "HASH"){
                                        # similarly for third level
                                        if (ref $masterSettings{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey} ne "HASH"){
                                            $logger->trace("*masterSettings{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey} currently contains a *scalar* value, but it needs to be updated with a hash (see $settings); deleting the scalar") if($is_t_switch_active);
                                            delete $masterSettings{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey} ;
                                        }
                                        while(my ($fourthLevelKey,$fourthLevelValue) = each %{$thirdLevelValue}) {
                                            $masterSettings{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey}{$fourthLevelKey} = $fourthLevelValue;
                                        }
                                    } else {
                                        $masterSettings{$firstLevelKey}{$secondLevelKey}{$thirdLevelKey} = $thirdLevelValue;
                                    }
                                }
                            } else {
                                $masterSettings{$firstLevelKey}{$secondLevelKey} = $secondLevelValue;
                            }
                          }
                      } else {
                            $masterSettings{$firstLevelKey} = $firstLevelValue;
                      }
              }

              # output settings to $logfile
              if($masterSettings{logFilePreferences}{showEveryYamlRead}){
                  $logger->info(Dump \%{$userSettings->[0]});
              } else {
                  $logger->info("Not showing settings in the log file (see showEveryYamlRead and showAmalgamatedSettings).");
              }
         } else {
               # otherwise print a warning that we can not read userSettings.yaml
               $logger->warn("*$settings contains invalid yaml format- not reading from it");
         }
    } else {
        # otherwise keep going, but put a warning in the log file
        $logger->info("*WARNING: $homeDir/indentconfig.yaml");
        if (-z $settings) {
            $logger->info("specifies $settings but this file is EMPTY -- not reading from it");
        } else {
            $logger->info("specifies $settings but this file does not exist - unable to read settings from this file");
        }
    }
  }

  # read settings from -y|--yaml switch
  if($switches{yaml}){
        # report to log file
        $logger->info("*YAML settings read: -y switch");

        # remove any horizontal space before or after , OR : OR ; or at the beginning or end of the switch value
        $switches{yaml} =~ s/\h*(,|(?<!\\):|;)\h*/$1/g;
        $switches{yaml} =~ s/^\h*//g;

        # store settings, possibly multiple ones split by commas
        my @yamlSettings;
        if($switches{yaml} =~ m/(?<!\\),/){
            @yamlSettings = split(/(?<!\\),/,$switches{yaml});
        } else {
            push(@yamlSettings,$switches{yaml});
        }

        # it is possible to specify, for example,
        #
        #   -y=indentAfterHeadings:paragraph:indentAfterThisHeading:1;level:1
        #   -y=specialBeginEnd:displayMath:begin:'\\\[';end: '\\\]';lookForThis: 1
        #
        # which should be translated into
        #
        #   indentAfterHeadings:
        #       paragraph:
        #           indentAfterThisHeading:1
        #           level:1
        #
        # so we need to loop through the comma separated list and search 
        # for semi-colons
        my $settingsCounter=0;
        my @originalYamlSettings = @yamlSettings;
        foreach(@originalYamlSettings){
            # increment the counter
            $settingsCounter++;

            # check for a match of the ;
            if($_ =~ m/(?<!\\);/){
                my (@subfield) = split(/(?<!\\);/,$_);

                # the content up to the first ; is called the 'root'
                my $root = shift @subfield;

                # split the root at :
                my (@keysValues) = split(/:/,$root);

                # get rid of the last *two* elements, which will be 
                #   key: value
                # for example, in
                #   -y=indentAfterHeadings:paragraph:indentAfterThisHeading:1;level:1
                # then @keysValues holds
                #   indentAfterHeadings:paragraph:indentAfterThisHeading:1
                # so we need to get rid of both
                #    1
                #    indentAfterThisHeading
                # so that we are in a position to concatenate
                #   indentAfterHeadings:paragraph
                # with 
                #   level:1
                # to form
                #   indentAfterHeadings:paragraph:level:1
                pop(@keysValues);
                pop(@keysValues);

                # update the appropriate piece of the -y switch, for example:
                #   -y=indentAfterHeadings:paragraph:indentAfterThisHeading:1;level:1
                # needs to be changed to
                #   -y=indentAfterHeadings:paragraph:indentAfterThisHeading:1
                # the 
                #   indentAfterHeadings:paragraph:level:1
                # will be added in the next part
                $yamlSettings[$settingsCounter-1] = $root;

                # reform the root
                $root = join(":",@keysValues);
                $logger->trace("*Sub-field detected (; present) and the root is: $root") if $is_t_switch_active;

                # now we need to attach the $root back together with any subfields
                foreach(@subfield){
                   # splice the new field into @yamlSettings (reference: https://perlmaven.com/splice-to-slice-and-dice-arrays-in-perl)
                   splice @yamlSettings,$settingsCounter,0,$root.":".$_; 
                   
                   # increment the counter
                   $settingsCounter++;
                }
                $logger->info("-y switch value interpreted as: ".join(',',@yamlSettings));
            }
        }

        # loop through each of the settings specified in the -y switch
        foreach(@yamlSettings){
            # split each value at semi-colon
            my (@keysValues) = split(/(?<!\\):/,$_);

            # $value will always be the last element
            my $value = $keysValues[-1];

            # it's possible that the 'value' will contain an escaped
            # semi-colon, so we replace it with just a semi-colon
            $value =~ s/\\:/:/;

            # horizontal space needs special treatment
            if($value =~ m/^(?:"|')(\h*)(?:"|')$/){
                # pure horizontal space
                $value = $1;
            } elsif($value =~ m/^(?:"|')((?:\\t)*)(?:"|')$/){
                # tabs
                $value =~ s/^(?:"|')//;
                $value =~ s/(?:"|')$//;
                $value =~ s/\\t/\t/g;
            }

            if(scalar(@keysValues) == 2){
                # for example, -y="defaultIndent: ' '"
                my $key = $keysValues[0];
                $logger->info("Updating masterSettings with $key: $value");
                $masterSettings{$key} = $value;
            } elsif(scalar(@keysValues) == 3){
                # for example, -y="indentRules: one: '\t\t\t\t'"
                my $parent = $keysValues[0];
                my $child = $keysValues[1];
                $logger->info("Updating masterSettings with $parent: $child: $value");
                $masterSettings{$parent}{$child} = $value;
            } elsif(scalar(@keysValues) == 4){
                # for example, -y='modifyLineBreaks  :  environments: EndStartsOnOwnLine:3' -m
                my $parent = $keysValues[0];
                my $child = $keysValues[1];
                my $grandchild = $keysValues[2];
                $logger->info("Updating masterSettings with $parent: $child: $grandchild: $value");
                $masterSettings{$parent}{$child}{$grandchild} = $value;
            } elsif(scalar(@keysValues) == 5){
                # for example, -y='modifyLineBreaks  :  environments: one: EndStartsOnOwnLine:3' -m
                my $parent = $keysValues[0];
                my $child = $keysValues[1];
                my $grandchild = $keysValues[2];
                my $greatgrandchild = $keysValues[3];
                $logger->info("Updating masterSettings with $parent: $child: $grandchild: $greatgrandchild: $value");
                $masterSettings{$parent}{$child}{$grandchild}{$greatgrandchild} = $value;
            }
          }
  }

  # some users may wish to see showAmalgamatedSettings
  # which details the overall state of the settings modified
  # from the default in various user files
  if($masterSettings{logFilePreferences}{showAmalgamatedSettings}){
      $logger->info("Amalgamated/overall settings to be used:");
      $logger->info(Dump \%masterSettings);
  }

  return;
}

sub get_indentation_settings_for_this_object{
    my $self = shift;

    # create a name for previously found settings
    my $storageName = ${$self}{name}.${$self}{modifyLineBreaksYamlName}.(defined ${$self}{storageNameAppend}?${$self}{storageNameAppend}:q());

    # grab the logging object
    my $logger = get_logger("Document");

    # check for storage of repeated objects
    if ($previouslyFoundSettings{$storageName}){
        $logger->trace("*Using stored settings for $storageName") if($is_t_switch_active);
    } else {
        my $name = ${$self}{name};
        $logger->trace("Storing settings for $storageName") if($is_t_switch_active);

        # check for noAdditionalIndent and indentRules
        # otherwise use defaultIndent
        my $indentation = $self->get_indentation_information;

        # check for alignment at ampersand settings
        $self->alignment_at_ampersand_settings;

        # check for line break settings
        $self->modify_line_breaks_settings;

        # store the settings
        %{${previouslyFoundSettings}{$storageName}} = (
                        indentation=>$indentation,
                        BeginStartsOnOwnLine=>${$self}{BeginStartsOnOwnLine},
                        BodyStartsOnOwnLine=>${$self}{BodyStartsOnOwnLine},
                        EndStartsOnOwnLine=>${$self}{EndStartsOnOwnLine},
                        EndFinishesWithLineBreak=>${$self}{EndFinishesWithLineBreak},
                        removeParagraphLineBreaks=>${$self}{removeParagraphLineBreaks},
                      );

        # don't forget alignment settings!
        foreach (@alignAtAmpersandInformation){
            ${${previouslyFoundSettings}{$storageName}}{${$_}{name}} = ${$self}{${$_}{name}} if(defined ${$self}{${$_}{name}});
        } 

        # some objects, e.g ifElseFi, can have extra assignments, e.g ElseStartsOnOwnLine
        # these need to be stored as well!
        foreach (@{${$self}{additionalAssignments}}){
            ${${previouslyFoundSettings}{$storageName}}{$_} = ${$self}{$_};
        }

        # log file information
        $logger->trace("Settings for $name (stored for future use):") if $is_tt_switch_active;
        $logger->trace(Dump \%{${previouslyFoundSettings}{$storageName}}) if $is_tt_switch_active;

    }

    # append indentation settings to the current object
    while( my ($key,$value)= each %{${previouslyFoundSettings}{$storageName}}){
            ${$self}{$key} = $value;
    }

    return;
}

sub alignment_at_ampersand_settings{
    my $self = shift;

    # if the YamlName is, for example, optionalArguments, mandatoryArguments, heading, then we'll be looking for information about the *parent*
    my $name = (defined ${$self}{nameForIndentationSettings}) ? ${$self}{nameForIndentationSettings} : ${$self}{name};

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
    return unless ${$masterSettings{lookForAlignDelims}}{$name}; 

    if(ref ${$masterSettings{lookForAlignDelims}}{$name} eq "HASH"){
      # specified as a hash, e.g
      #
      #   lookForAlignDelims:
      #      tabular: 
      #         delims: 1
      #         alignDoubleBackSlash: 1
      #         spacesBeforeDoubleBackSlash: 2
      foreach (@alignAtAmpersandInformation){
          my $yamlname = (defined ${$_}{yamlname} ? ${$_}{yamlname}: ${$_}{name});
          ${$self}{${$_}{name}} = (defined ${${$masterSettings{lookForAlignDelims}}{$name}}{$yamlname} ) ? ${${$masterSettings{lookForAlignDelims}}{$name}}{$yamlname} : ${$_}{default};
      } 
    } else {
      # specified as a scalar, e.g
      #
      #   lookForAlignDelims:
      #      tabular: 1
      foreach (@alignAtAmpersandInformation){
          ${$self}{${$_}{name}} = ${$_}{default};
      } 
    }
    return;
}

sub modify_line_breaks_settings{
    # return with undefined values unless the -m switch is active
    return unless $is_m_switch_active;

    my $self = shift;

    # grab the logging object
    my $logger = get_logger("Document");

    # details to the log file
    $logger->trace("*-m modifylinebreaks switch active, looking for settings for ${$self}{name} ") if $is_t_switch_active;

    # some objects, e.g ifElseFi, can have extra assignments, e.g ElseStartsOnOwnLine
    my @toBeAssignedTo = ${$self}{additionalAssignments} ? @{${$self}{additionalAssignments}} : ();

    # the following will *definitley* be in the array, so let's add them
    push(@toBeAssignedTo,("BeginStartsOnOwnLine","BodyStartsOnOwnLine","EndStartsOnOwnLine","EndFinishesWithLineBreak"));

    # we can efficiently loop through the following
    foreach (@toBeAssignedTo){
                    $self->get_every_or_custom_value(
                                    toBeAssignedTo=>$_,
                                    toBeAssignedToAlias=> ${$self}{aliases}{$_} ?  ${$self}{aliases}{$_} : $_,
                                  );
      }

    # paragraph line break settings
    ${$self}{removeParagraphLineBreaks} = ${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{all};

    return if(${$self}{removeParagraphLineBreaks});

    # the removeParagraphLineBreaks can contain fields that are hashes or scalar, for example:
    # 
    # removeParagraphLineBreaks:
    #     all: 0
    #     environments: 0
    # or
    # removeParagraphLineBreaks:
    #     all: 0
    #     environments: 
    #         quotation: 0

    # name of the object in the modifyLineBreaks yaml (e.g environments, ifElseFi, etc)
    my $YamlName = ${$self}{modifyLineBreaksYamlName};

    # if the YamlName is either optionalArguments or mandatoryArguments, then we'll be looking for information about the *parent*
    my $name = ($YamlName =~ m/Arguments/) ? ${$self}{parent} : ${$self}{name};

    if(ref ${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{$YamlName} eq "HASH"){
        $logger->trace("*$YamlName specified with fields in removeParagraphLineBreaks, looking for $name") if $is_t_switch_active;
        ${$self}{removeParagraphLineBreaks} = ${${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{$YamlName}}{$name}||0;
    } else {
        if(defined ${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{$YamlName}){
            $logger->trace("*$YamlName specified with just a number in removeParagraphLineBreaks ${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{$YamlName}") if $is_t_switch_active;
            ${$self}{removeParagraphLineBreaks} = ${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{$YamlName};
        }
    }
    return;
}

sub get_every_or_custom_value{
  my $self = shift;
  my %input = @_;

  my $toBeAssignedTo = $input{toBeAssignedTo};
  my $toBeAssignedToAlias = $input{toBeAssignedToAlias};

  # grab the logging object
  my $logger = get_logger("Document");

  # alias
  if(${$self}{aliases}{$toBeAssignedTo}){
        $logger->trace("aliased $toBeAssignedTo using ${$self}{aliases}{$toBeAssignedTo}") if($is_t_switch_active);
  }

  # name of the object in the modifyLineBreaks yaml (e.g environments, ifElseFi, etc)
  my $YamlName = ${$self}{modifyLineBreaksYamlName};

  # if the YamlName is either optionalArguments or mandatoryArguments, then we'll be looking for information about the *parent*
  my $name = ($YamlName =~ m/Arguments/) ? ${$self}{parent} : ${$self}{name};

  # these variables just ease the notation what follows
  my $everyValue = ${${$masterSettings{modifyLineBreaks}}{$YamlName}}{$toBeAssignedToAlias};
  my $customValue = ${${${$masterSettings{modifyLineBreaks}}{$YamlName}}{$name}}{$toBeAssignedToAlias};

  # check for the *custom* value
  if (defined $customValue){
      $logger->trace("$name: $toBeAssignedToAlias=$customValue, (*custom* value) adjusting $toBeAssignedTo") if($is_t_switch_active);
      ${$self}{$toBeAssignedTo} = $customValue !=0 ? $customValue : undef;
   } else {
      # check for the *every* value
      if (defined $everyValue and $everyValue != 0){
          $logger->trace("$name: $toBeAssignedToAlias=$everyValue, (*every* value) adjusting $toBeAssignedTo") if($is_t_switch_active);
          ${$self}{$toBeAssignedTo} = $everyValue;
      }
   }
  return;
}

sub get_indentation_information{
    my $self = shift;

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

    # if the YamlName is, for example, optionalArguments, mandatoryArguments, heading, then we'll be looking for information about the *parent*
    my $name = (defined ${$self}{nameForIndentationSettings}) ? ${$self}{nameForIndentationSettings} : ${$self}{name};

    # if the YamlName is not optionalArguments, mandatoryArguments, heading (possibly others) then assume we're looking for 'body'
    my $YamlName = $self->get_object_attribute_for_indentation_settings;

    # grab the logging object
    my $logger = get_logger("Document");

    my $indentationInformation;
    foreach my $indentationAbout ("noAdditionalIndent","indentRules"){
        # check that the 'thing' is defined
        if(defined ${$masterSettings{$indentationAbout}}{$name}){
            if(ref ${$masterSettings{$indentationAbout}}{$name} eq "HASH"){
                $logger->trace("$indentationAbout indentation specified with multiple fields for $name, searching for $name: $YamlName (see $indentationAbout)") if $is_t_switch_active ;
                $indentationInformation = ${${$masterSettings{$indentationAbout}}{$name}}{$YamlName};
            } else {
                $indentationInformation = ${$masterSettings{$indentationAbout}}{$name};
                $logger->trace("$indentationAbout indentation specified for $name (for *all* fields, body, optionalArguments, mandatoryArguments, afterHeading), using '$indentationInformation' (see $indentationAbout)") if $is_t_switch_active ;
            }
            # return, after performing an integrity check
            if(defined $indentationInformation){
                if($indentationAbout eq "noAdditionalIndent" and $indentationInformation == 1){
                        $logger->trace("Found! Using '' (see $indentationAbout)") if $is_t_switch_active;
                        return q();
                } elsif($indentationAbout eq "indentRules" and $indentationInformation=~m/^\h*$/){
                        $logger->trace("Found! Using '$indentationInformation' (see $indentationAbout)") if $is_t_switch_active;
                        return $indentationInformation ;
                }
            }
        }
    }

    # gather information
    $YamlName = ${$self}{modifyLineBreaksYamlName};

    foreach my $indentationAbout ("noAdditionalIndent","indentRules"){
        # global assignments in noAdditionalIndentGlobal and/or indentRulesGlobal
        my $globalInformation = $indentationAbout."Global";
        next if(!(defined ${$masterSettings{$globalInformation}}{$YamlName})); 
        if( ($globalInformation eq "noAdditionalIndentGlobal") and ${$masterSettings{$globalInformation}}{$YamlName}==1){
            $logger->trace("$globalInformation specified for $YamlName (see $globalInformation)") if $is_t_switch_active;
            return q();
        } elsif($globalInformation eq "indentRulesGlobal") {
            if(${$masterSettings{$globalInformation}}{$YamlName}=~m/^\h*$/){
                $logger->trace("$globalInformation specified for $YamlName (see $globalInformation)") if $is_t_switch_active;
                return ${$masterSettings{$globalInformation}}{$YamlName};
            } else {
                $logger->trace("$globalInformation specified (${$masterSettings{$globalInformation}}{$YamlName}) for $YamlName, but it needs to only contain horizontal space -- I'm ignoring this one") if $is_t_switch_active;
          }
        }
    }

    # return defaultIndent, by default
    $logger->trace("Using defaultIndent for $name") if $is_t_switch_active;
    return $masterSettings{defaultIndent};
}

sub get_object_attribute_for_indentation_settings{
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

1;
