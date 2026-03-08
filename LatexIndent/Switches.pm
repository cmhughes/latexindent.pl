package LatexIndent::Switches;

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
use Exporter qw/import/;
our @EXPORT_OK
    = qw/%switch store_switches $is_m_switch_active $is_t_switch_active $is_tt_switch_active $is_r_switch_active $is_rr_switch_active $is_rv_switch_active $is_check_switch_active $is_check_verbose_switch_active/;
our %switch;
our $is_m_switch_active;
our $is_t_switch_active;
our $is_tt_switch_active;
our $is_r_switch_active;
our $is_rr_switch_active;
our $is_rv_switch_active;
our $is_check_switch_active;
our $is_check_verbose_switch_active;

sub store_switches {
    my $self = shift;

    # copy document switches into hash local to this module
    %switch              = %{ ${$self}{switches} };
    $switch{version}     = defined $switch{vversion}               ? 1                         : $switch{version};
    $is_m_switch_active  = defined $switch{modifyLineBreaks}       ? $switch{modifyLineBreaks} : 0;
    $is_t_switch_active  = defined $switch{trace}                  ? $switch{trace}            : 0;
    $is_tt_switch_active = defined $switch{ttrace}                 ? $switch{ttrace}           : 0;
    $is_t_switch_active  = $is_tt_switch_active                    ? $is_tt_switch_active      : $is_t_switch_active;
    $is_r_switch_active  = defined $switch{replacement}            ? $switch{replacement}      : 0;
    $is_rr_switch_active = defined $switch{onlyreplacement}        ? $switch{onlyreplacement}  : 0;
    $is_rv_switch_active = defined $switch{replacementRespectVerb} ? $switch{replacementRespectVerb} : 0;
    $is_r_switch_active
        = ( $is_rr_switch_active | $is_rv_switch_active )
        ? ( $is_rr_switch_active | $is_rv_switch_active )
        : $is_r_switch_active;
    $is_check_switch_active         = defined $switch{check}        ? $switch{check}        : 0;
    $is_check_verbose_switch_active = defined $switch{checkverbose} ? $switch{checkverbose} : 0;
    $is_check_switch_active
        = $is_check_verbose_switch_active ? $is_check_verbose_switch_active : $is_check_switch_active;
    delete ${$self}{switches};
}
1;
