# GetYamlSettings.pm
#   reads defaultSettings.yaml
#   and combines user settings
package LatexIndent::GetYamlSettings;
use strict;
use warnings;
use YAML::Tiny;                # interpret defaultSettings.yaml and other potential settings files
use Exporter qw/import/;
our @EXPORT_OK = qw/masterYamlSettings readSettings/;

# Read in defaultSettings.YAML file
our $defaultSettings = YAML::Tiny->new;
$defaultSettings = YAML::Tiny->read( "$FindBin::RealBin/defaultSettings.yaml" );

# master yaml settings is a hash, global to this module
our %masterSettings = %{$defaultSettings->[0]};

sub readSettings{
  # eventually this method needs to read in user settings
  my $self = shift;
  $self->logger("YAML settings read",'heading');
  $self->logger("Reading defaultSettings.yaml from $FindBin::RealBin/defaultSettings.yaml");
  return;
  }

sub masterYamlSettings{
    my $self = shift;
    ${$self}{settings} = \%masterSettings;
    return;
}
1;
