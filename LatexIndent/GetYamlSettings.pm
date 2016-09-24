# GetYamlSettings.pm
#   reads defaultSettings.yaml
#   and combines user settings
package LatexIndent::GetYamlSettings;
use strict;
use warnings;
use YAML::Tiny;                # interpret defaultSettings.yaml and other potential settings files
use File::Basename;            # to get the filename and directory path
use Exporter qw/import/;
our @EXPORT_OK = qw/readSettings modify_line_breaks_settings get_indentation_settings_for_this_object get_every_or_custom_value get_master_settings get_indentation_information/;

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
  
  # local settings can be separated by ,
  # e.g  
  #     -l = myyaml1.yaml,myyaml2.yaml
  # and in which case, we need to read them all
  my @localSettings;
  if(${%{$self}{switches}}{readLocalSettings} =~ m/,/){
        $self->logger("Multiple localSettings found, separated by commas:",'heading');
        @localSettings = split(/,/,${%{$self}{switches}}{readLocalSettings});
  } else {
    push(@localSettings,${%{$self}{switches}}{readLocalSettings}) if(${%{$self}{switches}}{readLocalSettings});
  }

  # add local settings to the paths, if appropriate
  foreach (@localSettings) {
    if ( (-e "$directoryName/$_") and !(-z "$directoryName/$_")) {
        $self->logger("Adding $directoryName/$_ to YAML read paths");
        push(@absPaths,"$directoryName/$_");
    } elsif ( !(-e "$directoryName/$_") ) {
          $self->logger("WARNING yaml file not found: $directoryName/$_ not found");
          $self->logger("Proceeding without it.");
    }
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

sub get_master_settings{
    return \%masterSettings;
}

sub get_indentation_settings_for_this_object{
    my $self = shift;

    # create a name for previously found settings
    my $storageName = ${$self}{name};

    # check for storage of repeated objects
    if ($previouslyFoundSettings{$storageName}){
        $self->logger("Using stored settings for $storageName",'trace');
    } else {
        my $name = ${$self}{name};
        $self->logger("Storing settings for $storageName",'trace');

        # check for noAdditionalIndent and indentRules
        # otherwise use defaultIndent
        my $indentation = ($self->get_indentation_information(about=>"noAdditionalIndent"))
                                     ?
                                     q()
                                     :
                          ($self->get_indentation_information(about=>"indentRules")
                                     ||
                          $masterSettings{defaultIndent});

        # check for line break settings
        $self->modify_line_breaks_settings;

        # store the settings
        %{${previouslyFoundSettings}{$storageName}} = (
                        indentation=>$indentation,
                        modLineBreaksSwitch=>${${$self}{switches}}{modifyLineBreaks},
                        BeginStartsOnOwnLine=>${$self}{BeginStartsOnOwnLine},
                        BodyStartsOnOwnLine=>${$self}{BodyStartsOnOwnLine},
                        EndStartsOnOwnLine=>${$self}{EndStartsOnOwnLine},
                        EndFinishesWithLineBreak=>${$self}{EndFinishesWithLineBreak},
                      );

        # some objects, e.g ifElseFi, can have extra assignments, e.g ElseStartsOnOwnLine
        # these need to be stored as well!
        foreach (@{${$self}{additionalAssignments}}){
            ${${previouslyFoundSettings}{$storageName}}{$_} = ${$self}{$_};
        }

    }

    # append indentation settings to the current object
    while( my ($key,$value)= each %{${previouslyFoundSettings}{$storageName}}){
            ${$self}{$key} = $value;
    }

    return;
}

sub modify_line_breaks_settings{
    my $self = shift;

    # return with undefined values unless the -m switch is active
    return unless $self->is_m_switch_active;

    # details to the log file
    $self->logger("-m modifylinebreaks switch active, looking for settings for ${$self}{name} ",'heading.trace');

    # some objects, e.g ifElseFi, can have extra assignments, e.g ElseStartsOnOwnLine
    my @toBeAssignedTo = ${$self}{additionalAssignments} ? @{${$self}{additionalAssignments}} : ();

    # the following will *definitley* be in the array, so let's add them
    push(@toBeAssignedTo,("BeginStartsOnOwnLine","BodyStartsOnOwnLine","EndStartsOnOwnLine","EndFinishesWithLineBreak"));

    # we can effeciently loop through the following
    foreach (@toBeAssignedTo){
                    $self->get_every_or_custom_value(
                                    toBeAssignedTo=>$_,
                                    toBeAssignedToAlias=> ${$self}{aliases}{$_} ?  ${$self}{aliases}{$_} : $_,
                                  );
      }
    return;
}

sub get_every_or_custom_value{
  my $self = shift;
  my %input = @_;

  my $toBeAssignedTo = $input{toBeAssignedTo};
  my $toBeAssignedToAlias = $input{toBeAssignedToAlias};

  # alias
  if(${$self}{aliases}{$toBeAssignedTo}){
        $self->logger("aliased $toBeAssignedTo using ${$self}{aliases}{$toBeAssignedTo}",'trace');
  }

  # name of the object in the modifyLineBreaks yaml (e.g environments, ifElseFi, etc)
  my $modifyLineBreaksYamlName = ${$self}{modifyLineBreaksYamlName};

  # name of the object
  my $name = ${$self}{name};

  # these variables just ease the notation what follows
  my $everyValue = ${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$toBeAssignedToAlias};
  my $customValue = ${${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{$toBeAssignedToAlias};

  # check for the *custom* value
  if (defined $customValue){
      $self->logger("$name: $toBeAssignedToAlias=$customValue, (*custom* value) adjusting $toBeAssignedTo",'trace');
      ${$self}{$toBeAssignedTo} = $customValue >=0 ? $customValue : undef;
   } else {
      # check for the *every* value
      if (defined $everyValue and $everyValue >= 0){
          $self->logger("$name: $toBeAssignedToAlias=$everyValue, (*every* value) adjusting $toBeAssignedTo",'trace');
          ${$self}{$toBeAssignedTo} = $everyValue;
      }
   }
  return;
}

sub get_indentation_information{
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
    my $self = shift;
    my %input = @_;
    my $indentationAbout = ${input}{about};

    # gather information
    my $YamlName = ${$self}{modifyLineBreaksYamlName};

    # if the YamlName is either optionalArguments or mandatoryArguments, then we'll be looking for information about the *parent*
    my $name = ($YamlName =~ m/Arguments/) ? ${$self}{parent} : ${$self}{name};

    # if the YamlName is not optionalArguments or mandatoryArguments, then assume we're looking for 'body'
    $YamlName = ($YamlName =~ m/Arguments/) ? $YamlName : "body";

    return unless ${$masterSettings{$indentationAbout}}{$name}; 

    my $indentationInformation;
    if(ref ${$masterSettings{$indentationAbout}}{$name} eq "HASH"){
        $self->logger("$indentationAbout indentation specified with multiple fields for $name, searching for $name: $YamlName (see $indentationAbout)");
        $indentationInformation = ${${$masterSettings{$indentationAbout}}{$name}}{$YamlName};
        if(defined $indentationInformation and $indentationInformation ne ''){
            $self->logger("Using '$indentationInformation' (see $indentationAbout)") ;
         }
    } else {
        $self->logger("$indentationAbout indentation specified for $name (see $indentationAbout)");
        $indentationInformation = ${$masterSettings{$indentationAbout}}{$name};
    }

    return $indentationInformation;
}

1;
