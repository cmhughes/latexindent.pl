# GetYamlSettings.pm
#   reads defaultSettings.yaml
#   and combines user settings
package LatexIndent::GetYamlSettings;
use strict;
use warnings;
use YAML::Tiny;                # interpret defaultSettings.yaml and other potential settings files
use File::Basename;            # to get the filename and directory path
use Exporter qw/import/;
our @EXPORT_OK = qw/masterYamlSettings readSettings modify_line_breaks_settings get_indentation_settings_for_this_object/;

# Read in defaultSettings.YAML file
our $defaultSettings = YAML::Tiny->new;
$defaultSettings = YAML::Tiny->read( "$FindBin::RealBin/defaultSettings.yaml" ) or die "Could not open defaultSettings.yaml";

# master yaml settings is a hash, global to this module
our %masterSettings = %{$defaultSettings->[0]};

# previously found settings is a hash, global to this module
our %previouslyFoundSettings;

sub readSettings{
  my $self = shift;
  $self->logger("YAML settings read",'heading');
  $self->logger("Reading defaultSettings.yaml from $FindBin::RealBin/defaultSettings.yaml");

  # scalar to read user settings
  my $userSettings;

  # array to store the paths to user settings
  my @absPaths;
  
  # we'll need the home directory a lot in what follows
  my $homeDir = File::HomeDir->my_home; 
  
  # get information about user settings- first check if indentconfig.yaml exists
  my $indentconfig = "$homeDir/indentconfig.yaml";

  # if indentconfig.yaml doesn't exist, check for the hidden file, .indentconfig.yaml
  $indentconfig = "$homeDir/.indentconfig.yaml" if(! -e $indentconfig);

  # messages for indentconfig.yaml and/or .indentconfig.yaml
  if ( -e $indentconfig and !${%{$self}{switches}}{onlyDefault}) {
        $self->logger("Reading path information from $indentconfig");
        # if both indentconfig.yaml and .indentconfig.yaml exist
        if ( -e File::HomeDir->my_home . "/indentconfig.yaml" and  -e File::HomeDir->my_home . "/.indentconfig.yaml") {
              $self->logger("$homeDir/.indentconfig.yaml has been found, but $indentconfig takes priority");
        } elsif ( -e File::HomeDir->my_home . "/indentconfig.yaml" ) {
              $self->logger("(Alternatively $homeDir/.indentconfig.yaml can be used)");
        } elsif ( -e File::HomeDir->my_home . "/.indentconfig.yaml" ) {
              $self->logger("(Alternatively $homeDir/indentconfig.yaml can be used)");
        }

        # read the absolute paths from indentconfig.yaml
        $userSettings = YAML::Tiny->read( "$indentconfig" );

        # output the contents of indentconfig to the log file
        $self->logger(Dump \%{$userSettings->[0]});

        # update the absolute paths
        @absPaths = @{$userSettings->[0]->{paths}};
  } else {
     if(${%{$self}{switches}}{onlyDefault}) {
        $self->logger("Only default settings requested, not reading USER settings from $indentconfig");
        $self->logger("Ignoring ${%{$self}{switches}}{readLocalSettings} (you used the -d switch)") if(${%{$self}{switches}}{readLocalSettings});
        ${%{$self}{switches}}{readLocalSettings}=0;
     } else {
       # give the user instructions on where to put indentconfig.yaml or .indentconfig.yaml
       $self->logger("Home directory is $homeDir (didn't find either indentconfig.yaml or .indentconfig.yaml)");
       $self->logger("To specify user settings you would put indentconfig.yaml here: $homeDir/indentconfig.yaml");
       $self->logger("Alternatively, you can use the hidden file .indentconfig.yaml as: $homeDir/.indentconfig.yaml");
     }
  }

  # get information about LOCAL settings, assuming that $readLocalSettings exists
  my $directoryName = dirname (${$self}{fileName});
  
  # add local settings to the paths, if appropriate
  if ( (-e "$directoryName/${%{$self}{switches}}{readLocalSettings}") and ${%{$self}{switches}}{readLocalSettings} and !(-z "$directoryName/${%{$self}{switches}}{readLocalSettings}")) {
      $self->logger("Adding $directoryName/${%{$self}{switches}}{readLocalSettings} to YAML read paths");
      push(@absPaths,"$directoryName/${%{$self}{switches}}{readLocalSettings}");
  } elsif ( !(-e "$directoryName/${%{$self}{switches}}{readLocalSettings}") and ${%{$self}{switches}}{readLocalSettings}) {
        $self->logger("WARNING yaml file not found: $directoryName/${%{$self}{switches}}{readLocalSettings} not found");
        $self->logger("Proceeding without it.");
  }

  # read in the settings from each file
  foreach my $settings (@absPaths) {
    # check that the settings file exists and that it isn't empty
    if (-e $settings and !(-z $settings)) {
        $self->logger("Reading USER settings from $settings");
        $userSettings = YAML::Tiny->read( "$settings" );
  
        # if we can read userSettings
        if($userSettings) {
              # update the MASTER setttings to include updates from the userSettings
              while(my($firstLevelKey, $firstLevelValue) = each %{$userSettings->[0]}) {
                      # the update approach is slightly different for hashes vs scalars/arrays
                      if (ref($firstLevelValue) eq "HASH") {
                          while(my ($secondLevelKey,$secondLevelValue) = each %{$userSettings->[0]{$firstLevelKey}}) {
                            if (ref $secondLevelValue eq "HASH"){
                                while(my ($thirdLevelKey,$thirdLevelValue) = each %{$secondLevelValue}) {
                                    if (ref $thirdLevelValue eq "HASH"){
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
                  $self->logger(Dump \%{$userSettings->[0]});
              } else {
                  $self->logger("Not showing settings in the log file (see showEveryYamlRead).");
              }
         } else {
               # otherwise print a warning that we can not read userSettings.yaml
               $self->logger("WARNING $settings contains invalid yaml format- not reading from it");
         }
    } else {
        # otherwise keep going, but put a warning in the log file
        $self->logger("WARNING: $homeDir/indentconfig.yaml");
        if (-z $settings) {
            $self->logger("specifies $settings but this file is EMPTY -- not reading from it");
        } else {
            $self->logger("specifies $settings but this file does not exist - unable to read settings from this file");
        }
    }
  }

  # some users may wish to see showAmalgamatedSettings
  # which details the overall state of the settings modified
  # from the default in various user files
  if($masterSettings{logFilePreferences}{showAmalgamatedSettings}){
      $self->logger("Amalgamated/overall settings to be used:",'heading');
      $self->logger(Dump \%masterSettings);
  }

  return;
}

sub masterYamlSettings{
    my $self = shift;
    ${$self}{settings} = \%masterSettings;
    return;
}

sub get_indentation_settings_for_this_object{
    my $self = shift;

    # check for storage of repeated objects
    if ($previouslyFoundSettings{${$self}{name}}){
        $self->logger("Using stored settings for ${$self}{name}",'trace');
    } else {
        my $name = ${$self}{name};
        $self->logger("Storing settings for $name",'trace');

        # check for noAdditionalIndent and indentRules
        # otherwise use defaultIndent
        my $indentation = (${$masterSettings{noAdditionalIndent}}{$name})
                                     ?
                                     q()
                                     :
                          (${$masterSettings{indentRules}}{$name}
                                     ||
                          $masterSettings{defaultIndent});

        # check if the -m switch is active
        $self->get_switches;

        # check for line break settings
        $self->modify_line_breaks_settings;

        # store the settings
        %{${previouslyFoundSettings}{$name}} = (
                        indentation=>$indentation,
                        modLineBreaksSwitch=>${${$self}{switches}}{modifyLineBreaks},
                        BeginStartsOnOwnLine=>${$self}{BeginStartsOnOwnLine},
                        BodyStartsOnOwnLine=>${$self}{BodyStartsOnOwnLine},
                        EndStartsOnOwnLine=>${$self}{EndStartsOnOwnLine},
                        EndFinishesWithLineBreak=>${$self}{EndFinishesWithLineBreak},
                      );

        # there's no need for the current object to keep all of the settings
        delete ${$self}{settings};
        delete ${$self}{switches};
    }

    # append indentation settings to the current object
    while( my ($key,$value)= each %{${previouslyFoundSettings}{${$self}{name}}}){
            ${$self}{$key} = $value;
    }

    return;
}

sub modify_line_breaks_settings{
    my $self = shift;

    # return with undefined values unless the -m switch is active
    return  unless(${${$self}{switches}}{modifyLineBreaks});

    # settings for modifying line breaks, off by default
    my %BeginStartsOnOwnLine = (
                                finalvalue=>undef,
                                every=>{name=>"everyBeginStartsOnOwnLine"},
                                custom=>{name=>"BeginStartsOnOwnLine"}
                              );
    my %BodyStartsOnOwnLine = (
                                finalvalue=>undef,
                                every=>{name=>"everyBodyStartsOnOwnLine"},
                                custom=>{name=>"BodyStartsOnOwnLine"}
                              );
    my %EndStartsOnOwnLine = (
                                finalvalue=>undef,
                                every=>{name=>"everyEndStartsOnOwnLine"},
                                custom=>{name=>"EndStartsOnOwnLine"}
                              );
    my %EndFinishesWithLineBreak = (
                                finalvalue=>undef,
                                every=>{name=>"everyEndFinishesWithLineBreak"},
                                custom=>{name=>"EndFinishesWithLineBreak"}
                              );

    # name of the object
    my $name = ${$self}{name};

    # name of the object in the modifyLineBreaks yaml (e.g environments, ifElseFi, etc)
    my $modifyLineBreaksYamlName = ${$self}{modifyLineBreaksYamlName};

    # since each of the four values are undef by default, 
    # the 'every' value check (for each of the four values)
    # only needs to be non-negative
    
    # the 'every' value may well switch each of the four
    # values on, and the 'custom' value may switch it off, 
    # hence the ternary check (using (test)?true:false)
    $self->logger("-m modifylinebreaks switch active, looking for settings for $name ",'heading.trace');

    # aliases: for example, ifElseFi uses everyIfStartsOnOwnLine, but it really just means everyBeginStartsOnOwnLine
    if(defined ${$self}{aliases}){
        my %aliases = %{${$self}{aliases}};
        $self->logger("aliases found for $name (type: $modifyLineBreaksYamlName)",'trace');

        # begin statements
        $self->logger("aliases for BEGIN statements",'trace');
        if(defined $aliases{everyBeginStartsOnOwnLine}){
            $BeginStartsOnOwnLine{every}{name} = $aliases{everyBeginStartsOnOwnLine};
            $self->logger("aliased everyBeginStartsOnOwnLine using $aliases{everyBeginStartsOnOwnLine}",'trace');
        }
        if(defined $aliases{BeginStartsOnOwnLine}){
            $BeginStartsOnOwnLine{custom}{name} = $aliases{BeginStartsOnOwnLine};
            $self->logger("aliased BeginStartsOnOwnLine using $aliases{BeginStartsOnOwnLine}",'trace');
        }

        # body statements
        $self->logger("aliases for BODY statements",'trace');
        if(defined $aliases{everyBodyStartsOnOwnLine}){
            $BodyStartsOnOwnLine{every}{name} = $aliases{everyBodyStartsOnOwnLine};
            $self->logger("aliased everyBodyStartsOnOwnLine using $aliases{everyBodyStartsOnOwnLine}",'trace');
        }
        if(defined $aliases{BodyStartsOnOwnLine}){
            $BodyStartsOnOwnLine{custom}{name} = $aliases{BodyStartsOnOwnLine};
            $self->logger("aliased BodyStartsOnOwnLine using $aliases{BodyStartsOnOwnLine}",'trace');
        }

        # end statements
        $self->logger("aliases for END statements",'trace');
        if(defined $aliases{everyEndStartsOnOwnLine}){
            $EndStartsOnOwnLine{every}{name} = $aliases{everyEndStartsOnOwnLine};
            $self->logger("aliased everyEndStartsOnOwnLine using $aliases{everyEndStartsOnOwnLine}",'trace');
        }
        if(defined $aliases{EndStartsOnOwnLine}){
            $EndStartsOnOwnLine{custom}{name} = $aliases{EndStartsOnOwnLine};
            $self->logger("aliased EndStartsOnOwnLine using $aliases{EndStartsOnOwnLine}",'trace');
        }

        # *after* end statements
        $self->logger("aliases for line breaks *after* END statements",'trace');
        if(defined $aliases{everyEndFinishesWithLineBreak}){
            $EndFinishesWithLineBreak{every}{name} = $aliases{everyEndFinishesWithLineBreak};
            $self->logger("aliased everyEndFinishesWithLineBreak using $aliases{everyEndFinishesWithLineBreak}",'trace');
        }
        if(defined $aliases{EndFinishesWithLineBreak}){
            $EndFinishesWithLineBreak{custom}{name} = $aliases{EndFinishesWithLineBreak};
            $self->logger("aliased EndFinishesWithLineBreak using $aliases{EndFinishesWithLineBreak}",'trace');
        }
    }
    
    # BeginStartsOnOwnLine 
    # BeginStartsOnOwnLine 
    # BeginStartsOnOwnLine 
    $BeginStartsOnOwnLine{every}{value}  = ${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$BeginStartsOnOwnLine{every}{name}};
    $BeginStartsOnOwnLine{custom}{value} = ${${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{$BeginStartsOnOwnLine{custom}{name}};
    
    # check for the *every* value
    if (defined $BeginStartsOnOwnLine{every}{value} and $BeginStartsOnOwnLine{every}{value} >= 0){
        $self->logger("$BeginStartsOnOwnLine{every}{name}=$BeginStartsOnOwnLine{every}{value}, (*every* value) adjusting BeginStartsOnOwnLine",'trace');
        $BeginStartsOnOwnLine{finalvalue} = $BeginStartsOnOwnLine{every}{value};
    }
    
    # check for the *custom* value
    if (defined $BeginStartsOnOwnLine{custom}{value}){
        $self->logger("$name: $BeginStartsOnOwnLine{custom}{name}=$BeginStartsOnOwnLine{custom}{value}, (*custom* value) adjusting BeginStartsOnOwnLine",'trace');
        $BeginStartsOnOwnLine{finalvalue} = $BeginStartsOnOwnLine{custom}{value} >=0 ? $BeginStartsOnOwnLine{custom}{value} : undef;
     }
    
    # BodyStartsOnOwnLine 
    # BodyStartsOnOwnLine 
    # BodyStartsOnOwnLine 
    $BodyStartsOnOwnLine{every}{value} = ${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$BodyStartsOnOwnLine{every}{name}};
    $BodyStartsOnOwnLine{custom}{value} = ${${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{$BodyStartsOnOwnLine{custom}{name}};
    
    # check for the *every* value
    if (defined $BodyStartsOnOwnLine{every}{value} and $BodyStartsOnOwnLine{every}{value} >= 0){
        $self->logger("$BodyStartsOnOwnLine{every}{name}=$BodyStartsOnOwnLine{every}{value}, adjusting (*every* value) BodyStartsOnOwnLine",'trace');
        $BodyStartsOnOwnLine{finalvalue} = $BodyStartsOnOwnLine{every}{value};
    }
    
    # check for the *custom* value
    if (defined $BodyStartsOnOwnLine{custom}{value}){
        $self->logger("$name: $BodyStartsOnOwnLine{custom}{name}=$BodyStartsOnOwnLine{custom}{value}, (*custom* value) adjusting BodyStartsOnOwnLine",'trace');
        $BodyStartsOnOwnLine{finalvalue} = $BodyStartsOnOwnLine{custom}{value}>=0 ? $BodyStartsOnOwnLine{custom}{value} : undef;
     }
    
    # EndStartsOnOwnLine 
    # EndStartsOnOwnLine 
    # EndStartsOnOwnLine 
    $EndStartsOnOwnLine{every}{value} = ${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$EndStartsOnOwnLine{every}{name}};
    $EndStartsOnOwnLine{custom}{value} = ${${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{$EndStartsOnOwnLine{custom}{name}};
    
    # check for the *every* value
    if (defined $EndStartsOnOwnLine{every}{value} and $EndStartsOnOwnLine{every}{value} >= 0){
        $self->logger("$EndStartsOnOwnLine{every}{name}=$EndStartsOnOwnLine{every}{value}, (*every* value) adjusting EndStartsOnOwnLine",'trace');
        $EndStartsOnOwnLine{finalvalue} = $EndStartsOnOwnLine{every}{value};
    }
    
    # check for the *custom* value
    if (defined $EndStartsOnOwnLine{custom}{value}){
        $self->logger("$name: $EndStartsOnOwnLine{custom}{name}=$EndStartsOnOwnLine{custom}{value}, (*custom* value) adjusting EndStartsOnOwnLine",'trace');
        $EndStartsOnOwnLine{finalvalue} = $EndStartsOnOwnLine{custom}{value}>=0 ? $EndStartsOnOwnLine{custom}{value} : undef;
     }
    
    # EndFinishesWithLineBreak 
    # EndFinishesWithLineBreak 
    # EndFinishesWithLineBreak 
    $EndFinishesWithLineBreak{every}{value} = ${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$EndFinishesWithLineBreak{every}{name}};
    $EndFinishesWithLineBreak{custom}{value} = ${${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{$EndFinishesWithLineBreak{custom}{name}};
    
    # check for the *every* value
    if (defined $EndFinishesWithLineBreak{every}{value} and $EndFinishesWithLineBreak{every}{value}>=0){
        $self->logger("$EndFinishesWithLineBreak{every}{name}=$EndFinishesWithLineBreak{every}{value}, (*every* value) adjusting EndFinishesWithLineBreak",'trace');
        $EndFinishesWithLineBreak{finalvalue} = $EndFinishesWithLineBreak{every}{value};
    }
    
    # check for the *custom* value
    if (defined $EndFinishesWithLineBreak{custom}{value}){
        $self->logger("$name: $EndFinishesWithLineBreak{custom}{name}=$EndFinishesWithLineBreak{custom}{value}, (*custom* value) adjusting EndFinishesWithLineBreak",'trace');
        $EndFinishesWithLineBreak{finalvalue}  = $EndFinishesWithLineBreak{custom}{value}>=0 ? $EndFinishesWithLineBreak{custom}{value} : undef;
    }

    # update keys
    ${$self}{BeginStartsOnOwnLine}=$BeginStartsOnOwnLine{finalvalue};
    ${$self}{BodyStartsOnOwnLine}=$BodyStartsOnOwnLine{finalvalue};
    ${$self}{EndStartsOnOwnLine}=$EndStartsOnOwnLine{finalvalue};
    ${$self}{EndFinishesWithLineBreak}=$EndFinishesWithLineBreak{finalvalue};

    return;
}

1;
