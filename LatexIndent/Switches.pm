package LatexIndent::Switches;
use strict;
use warnings;
use Exporter qw/import/;
our @EXPORT_OK = qw/%switches storeSwitches $is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
our %switches;
our $is_m_switch_active;
our $is_t_switch_active;
our $is_tt_switch_active;

sub storeSwitches{
    my $self = shift;

    # copy document switches into hash local to this module
    %switches = %{%{$self}{switches}};
    $is_m_switch_active = defined $switches{modifyLineBreaks}?$switches{modifyLineBreaks}: 0;
    $is_t_switch_active = defined $switches{trace}?$switches{trace}: 0;
    $is_tt_switch_active = defined $switches{ttrace}?$switches{ttrace}: 0;
    $is_t_switch_active = $is_tt_switch_active ? $is_tt_switch_active : $is_t_switch_active;
    delete ${$self}{switches};
  }
1;
