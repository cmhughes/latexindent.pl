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
              while(my($userKey, $userValue) = each %{$userSettings->[0]}) {
                      # the update approach is slightly different for hashes vs scalars/arrays
                      if (ref($userValue) eq "HASH") {
                          while(my ($userKeyFromHash,$userValueFromHash) = each %{$userSettings->[0]{$userKey}}) {
                            $masterSettings{$userKey}{$userKeyFromHash} = $userValueFromHash;
                          }
                      } else {
                            $masterSettings{$userKey} = $userValue;
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

  # some users may wish to see showAlmagamatedSettings
  # which details the overall state of the settings modified
  # from the default in various user files
  if($masterSettings{logFilePreferences}{showAlmagamatedSettings}){
      $self->logger("Almagamated/overall settings to be used:");
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

    # check for storage of repeated environments
    if ($previouslyFoundSettings{${$self}{name}}){
        $self->logger("Using stored settings for ${$self}{name}",'trace');
    } else {
        my $name = ${$self}{name};
        $self->logger("Storing settings for $name",'trace');

        # get master settings
        $self->masterYamlSettings;

        # we'll use %settings a lot in what follows
        my %settings = %{%{$self}{settings}};

        # check for noAdditionalIndent and indentRules
        # otherwise use defaultIndent
        my $indentation = (${$settings{noAdditionalIndent}}{$name})
                                     ?
                                     q()
                                     :
                          (${$settings{indentRules}}{$name}
                                     ||
                          $settings{defaultIndent});

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

    # append indentation settings to the ENVIRONMENT object
    while( my ($key,$value)= each %{${previouslyFoundSettings}{${$self}{name}}}){
            ${$self}{$key} = $value;
    }

    return;
}

sub modify_line_breaks_settings{
    my $self = shift;

    # settings for modifying line breaks, off by default
    my $BeginStartsOnOwnLine = undef;
    my $BodyStartsOnOwnLine = undef;
    my $EndStartsOnOwnLine = undef;
    my $EndFinishesWithLineBreak = undef;
    
    # return with undefined values unless the -m switch is active
    return  unless(${${$self}{switches}}{modifyLineBreaks});

    # name of the object
    my $name = ${$self}{name};

    # name of the object in the modifyLineBreaks yaml (e.g environments, ifElseFi, etc)
    my $modifyLineBreaksYamlName = ${$self}{modifyLineBreaksYamlName};

    # we'll use %settings a lot in what follows
    my %settings = %{%{$self}{settings}};

    # since each of the four values are undef by default, 
    # the 'every' value check (for each of the four values)
    # only needs to be non-negative
    
    # the 'every' value may well switch each of the four
    # values on, and the 'custom' value may switch it off, 
    # hence the ternary check (using (test)?true:false)
    $self->logger("-m modifylinebreaks switch active, looking for settings for $name ",'heading.trace');
    
    # BeginStartsOnOwnLine 
    # BeginStartsOnOwnLine 
    # BeginStartsOnOwnLine 
    my $everyBeginStartsOnOwnLine = ${${$settings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{everyBeginStartsOnOwnLine};
    my $customBeginStartsOnOwnLine = ${${${$settings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{BeginStartsOnOwnLine};
    
    # check for the *every* value
    if (defined $everyBeginStartsOnOwnLine and $everyBeginStartsOnOwnLine >= 0){
        $self->logger("everyBeginStartOnOwnLine=$everyBeginStartsOnOwnLine, adjusting BeginStartsOnOwnLine",'trace');
        $BeginStartsOnOwnLine = $everyBeginStartsOnOwnLine;
    }
    
    # check for the *custom* value
    if (defined $customBeginStartsOnOwnLine){
        $self->logger("$name: BeginStartOnOwnLine=$customBeginStartsOnOwnLine, adjusting BeginStartsOnOwnLine",'trace');
        $BeginStartsOnOwnLine = $customBeginStartsOnOwnLine>=0 ? $customBeginStartsOnOwnLine : undef;
     }
    
    # BodyStartsOnOwnLine 
    # BodyStartsOnOwnLine 
    # BodyStartsOnOwnLine 
    my $everyBodyStartsOnOwnLine = ${${$settings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{everyBodyStartsOnOwnLine};
    my $customBodyStartsOnOwnLine = ${${${$settings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{BodyStartsOnOwnLine};
    
    # check for the *every* value
    if (defined $everyBodyStartsOnOwnLine and $everyBodyStartsOnOwnLine >= 0){
        $self->logger("everyBodyStartOnOwnLine=$everyBodyStartsOnOwnLine, adjusting BodyStartsOnOwnLine",'trace');
        $BodyStartsOnOwnLine = $everyBodyStartsOnOwnLine;
    }
    
    # check for the *custom* value
    if (defined $customBodyStartsOnOwnLine){
        $self->logger("$name: BodyStartOnOwnLine=$customBodyStartsOnOwnLine, adjusting BodyStartsOnOwnLine",'trace');
        $BodyStartsOnOwnLine = $customBodyStartsOnOwnLine>=0 ? $customBodyStartsOnOwnLine : undef;
     }
    
    # EndStartsOnOwnLine 
    # EndStartsOnOwnLine 
    # EndStartsOnOwnLine 
    my $everyEndStartsOnOwnLine = ${${$settings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{everyEndStartsOnOwnLine};
    my $customEndStartsOnOwnLine = ${${${$settings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{EndStartsOnOwnLine};
    
    # check for the *every* value
    if (defined $everyEndStartsOnOwnLine and $everyEndStartsOnOwnLine >= 0){
        $self->logger("everyEndStartOnOwnLine=$everyEndStartsOnOwnLine, adjusting EndStartsOnOwnLine",'trace');
        $EndStartsOnOwnLine = $everyEndStartsOnOwnLine;
    }
    
    # check for the *custom* value
    if (defined $customEndStartsOnOwnLine){
        $self->logger("$name: EndStartOnOwnLine=$customEndStartsOnOwnLine, adjusting EndStartsOnOwnLine",'trace');
        $EndStartsOnOwnLine = $customEndStartsOnOwnLine>=0 ? $customEndStartsOnOwnLine : undef;
     }
    
    # EndFinishesWithLineBreak 
    # EndFinishesWithLineBreak 
    # EndFinishesWithLineBreak 
    my $everyEndFinishesWithLineBreak = ${${$settings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{everyEndFinishesWithLineBreak};
    my $customEndFinishesWithLineBreak = ${${${$settings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{EndFinishesWithLineBreak};
    
    # check for the *every* value
    if (defined $everyEndFinishesWithLineBreak and $everyEndFinishesWithLineBreak>=0){
        $self->logger("everyEndFinishesWithLineBreak=$everyEndFinishesWithLineBreak, adjusting EndFinishesWithLineBreak",'trace');
        $EndFinishesWithLineBreak = $everyEndFinishesWithLineBreak;
    }
    
    # check for the *custom* value
    if (defined $customEndFinishesWithLineBreak){
        $self->logger("$name: EndFinishesWithLineBreak=$customEndFinishesWithLineBreak, adjusting EndFinishesWithLineBreak",'trace');
        $EndFinishesWithLineBreak  = $customEndFinishesWithLineBreak>=0 ? $customEndFinishesWithLineBreak : undef;
    }

    # update keys
    ${$self}{BeginStartsOnOwnLine}=$BeginStartsOnOwnLine;
    ${$self}{BodyStartsOnOwnLine}=$BodyStartsOnOwnLine;
    ${$self}{EndStartsOnOwnLine}=$EndStartsOnOwnLine;
    ${$self}{EndFinishesWithLineBreak}=$EndFinishesWithLineBreak;

    return;
}

1;
