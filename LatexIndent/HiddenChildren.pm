package LatexIndent::HiddenChildren;
use strict;
use warnings;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/find_surrounding_indentation_for_children update_family_tree get_family_tree find_hidden_children operate_on_hidden_children/;

# hiddenChildren can be stored in a global array, it doesn't matter what level they're at
our @hiddenChildren;
our %nonHiddenChildren;
our %familyTree;

#----------------------------------------------------------
#   Discussion surrounding hidden children
#
#   Consider the following latex code
#
#   \begin{one}
#       body of one 
#       body of one 
#       body of one 
#       \begin{two}
#          body of two
#          body of two
#          body of two
#          body of two
#       \end{two}
#   \end{one}
#
#   From the visual perspective, we might say that <one> and <two> are *nested* children;
#   from the persepective of latexindent.pl, however, they actually have *the same level*.
#
#   Graphically, you might represent it as follows
#
#                     *
#                   /  \
#                  /    \
#                 /      \ 
#                O        O
#
#   where * represents the 'root' document object, and each 'O' is an environment object; the
#   first one, on the left, represents <two> and the second one, on the right, represents <one>. 
#   (Remember that the environment regexp does not allow \begin within its body.)
#
#   When processing the document, <one> will be processed *before* <two>. Furthermore, because
#   <one> and <two> are at the same level, they are not *natural* ancestors of each other; as such, 
#   we say that <two> is a *hidden* child, and that its 'adopted' ancestor is <one>. 
#
#   We need to go to a lot of effort to make sure that <two> knows about its ancestors and its 
#   surrounding indentation (<one> in this case). The subroutines in this file do that effort.
#----------------------------------------------------------

sub find_surrounding_indentation_for_children{
    my $self = shift;

    # find all hidden children
    $self->find_hidden_children;

    # operate on hidden children
    foreach (@hiddenChildren){
        $self->operate_on_hidden_children($_);
    }

    # output to logfile
    $self->logger("FamilyTree before update:",'heading.trace');
    $self->logger(Dumper(\%familyTree),'trace') if($is_t_switch_active);

    # update the family tree with ancestors
    $self->update_family_tree;

    # output information to the logfile
    $self->logger("FamilyTree after update:",'heading.trace');
    $self->logger(Dumper(\%familyTree),'trace') if($is_t_switch_active);

    while( my ($idToSearch,$ancestorToSearch) = each %familyTree){
          $self->logger("Hidden child ID: ,$idToSearch, here are its ancestors:",'heading.trace');
          foreach(@{${$ancestorToSearch}{ancestors}}){
              $self->logger("ID: ${$_}{ancestorID}",'trace') if($is_t_switch_active);
              my $tmpIndentation = ref(${$_}{ancestorIndentation}) eq 'SCALAR'?${${$_}{ancestorIndentation}}:${$_}{ancestorIndentation};
              $tmpIndentation = $tmpIndentation ? $tmpIndentation : q(); 
              $self->logger("indentation: '$tmpIndentation'",'trace') if($is_t_switch_active);
              }
          }

    return;
}

sub update_family_tree{
    my $self = shift;

    # loop through the hash
    $self->logger("Updating FamilyTree...",'heading.trace');
    while( my ($idToSearch,$ancestorToSearch)= each %familyTree){
          foreach(@{${$ancestorToSearch}{ancestors}}){
              my $ancestorID = ${$_}{ancestorID};
              $self->logger("current ID: $idToSearch, ancestor: $ancestorID",'trace') if($is_t_switch_active);
              if($familyTree{$ancestorID}){
                  $self->logger("$ancestorID is a key within familyTree, grabbing its ancestors",'trace') if($is_t_switch_active);
                  my $naturalAncestors = q();
                  foreach(@{${$familyTree{$idToSearch}}{ancestors}}){
                      $naturalAncestors .= "---".${$_}{ancestorID} if(${$_}{type} eq "natural");
                  }
                  foreach(@{${$familyTree{$ancestorID}}{ancestors}}){
                      $self->logger("ancestor of *hidden* child: ${$_}{ancestorID}",'trace') if($is_t_switch_active);
                      my $newAncestorId = ${$_}{ancestorID};
                      my $type;
                      if($naturalAncestors =~ m/$ancestorID/){
                            $type = "natural";
                      } else {
                            $type = "adopted";
                      }
                      my $matched = grep { $_->{ancestorID} eq $newAncestorId } @{${$familyTree{$idToSearch}}{ancestors}};
                      push(@{${$familyTree{$idToSearch}}{ancestors}},{ancestorID=>${$_}{ancestorID},ancestorIndentation=>${$_}{ancestorIndentation},type=>$type}) unless($matched);
                  }
              } elsif ($nonHiddenChildren{$ancestorID}){
                    my $naturalAncestors = q();
                    foreach(@{${$familyTree{$idToSearch}}{ancestors}}){
                        $naturalAncestors .= "---".${$_}{ancestorID} if(${$_}{type} eq "natural");
                    }
                    $self->logger("natural ancestors of $ancestorID: $naturalAncestors",'trace') if($is_t_switch_active);
                    foreach(@{${$nonHiddenChildren{$ancestorID}}{ancestors}}){
                        my $newAncestorId = ${$_}{ancestorID};
                        my $type;
                        if($naturalAncestors =~ m/$newAncestorId/){
                            $type = "natural";
                        } else {
                            $type = "adopted";
                        }
                        my $matched = grep { $_->{ancestorID} eq $newAncestorId } @{${$familyTree{$idToSearch}}{ancestors}};
                        unless($matched){
                            $self->logger("ancestor of UNHIDDEN child: ${$_}{ancestorID}",'trace') if($is_t_switch_active);
                            push(@{${$familyTree{$idToSearch}}{ancestors}},{ancestorID=>${$_}{ancestorID},ancestorIndentation=>${$_}{ancestorIndentation},type=>$type});
                        }
                    }
              } else {
                  $self->logger("$ancestorID is *not* a key within familyTree, *no* ancestors to grab",'trace') if($is_t_switch_active);
              }
          }
    }

    # Indent.pm needs a copy of the familyTree hash
    $self->push_family_tree_to_indent;
}

sub get_family_tree{
    return \%familyTree;
}

sub find_hidden_children{
    my $self = shift;

    # finding hidden children
    foreach my $child (@{${$self}{children}}){
        if(${$self}{body} !~ m/${$child}{id}/){
            $self->logger("child not found, ${$child}{id}, adding it to hidden children",'ttrace') if($is_tt_switch_active);
            ${$child}{hiddenChildYesNo} = 1;
            push(@hiddenChildren,\%{$child});
        } else {
            $self->logger("child found, ${$child}{id} within ${$self}{name}",'ttrace') if($is_tt_switch_active);
            $nonHiddenChildren{${$child}{id}} = \%{$child};
        }

        # recursively find other hidden children
        $child->find_hidden_children;
    }

}

sub operate_on_hidden_children{
    my $self = shift;

    # the hidden child is the argument
    my $hiddenChild = $_[0];

    return if($familyTree{${$hiddenChild}{id}});

    # if the hidden child is found in the current body, take action
    if(${$self}{body} =~ m/${$hiddenChild}{id}/){
        $self->logger("hiddenChild found, ${$hiddenChild}{id} within ${$self}{name} (${$self}{id})",'ttrace') if($is_tt_switch_active);

        my $naturalAncestors = q();
        foreach(@{${$hiddenChild}{ancestors}}){
            $naturalAncestors .= "---".${$_}{ancestorID};# if(${$_}{type} eq "natural");
        }

        # update the family tree
        if(${$self}{ancestors}){
            foreach(@{${$self}{ancestors}}){
                if($naturalAncestors =~ m/${$_}{ancestorID}/ ){
                    push(@{$familyTree{${$hiddenChild}{id}}{ancestors}},{ancestorID=>${$_}{ancestorID},ancestorIndentation=>${$_}{ancestorIndentation},type=>"natural"});
                } else {
                    $self->logger("Adding ${$_}{ancestorID} to the adopted family tree of hiddenChild found, ${$hiddenChild}{id}",'trace') if($is_t_switch_active);
                    push(@{$familyTree{${$hiddenChild}{id}}{ancestors}},{ancestorID=>${$_}{ancestorID},ancestorIndentation=>${$_}{ancestorIndentation},type=>"adopted"});
                }
            }
        }
        if($naturalAncestors =~ m/${$self}{id}/ ){
            push(@{$familyTree{${$hiddenChild}{id}}{ancestors}},{ancestorID=>${$self}{id},ancestorIndentation=>${$self}{indentation},type=>"natural"});
        } else {
            push(@{$familyTree{${$hiddenChild}{id}}{ancestors}},{ancestorID=>${$self}{id},ancestorIndentation=>${$self}{indentation},type=>"adopted"});
        }
    } else {
        # call this subroutine recursively for the children
        unless(defined ${$self}{id} and (${$self}{id} eq ${$hiddenChild}{id})){
            foreach my $child (@{${$self}{children}}){
                unless($familyTree{${$hiddenChild}{id}}){
                    $self->logger("Searching children of ${$child}{name} for ${$hiddenChild}{id}",'ttrace') if($is_tt_switch_active);
                    $child->operate_on_hidden_children(\%{$hiddenChild});
                }
            }
        }
    }
}

1;
