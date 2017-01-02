package LatexIndent::HiddenChildren;
use strict;
use warnings;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use LatexIndent::Tokens qw/%tokens/;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/find_surrounding_indentation_for_children update_family_tree get_family_tree update_child_id_reg_exp check_for_hidden_children %familyTree/;

# hiddenChildren can be stored in a global array, it doesn't matter what level they're at
our %familyTree;
our %allChildren;
our $allChildrenIDRegExp = q();


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
              } else {
                    my $naturalAncestors = q();
                    foreach(@{${$familyTree{$idToSearch}}{ancestors}}){
                        $naturalAncestors .= "---".${$_}{ancestorID} if(${$_}{type} eq "natural");
                    }
                    $self->logger("natural ancestors of $ancestorID: $naturalAncestors",'trace') if($is_t_switch_active);
                    foreach(@{${$allChildren{$ancestorID}}{ancestors}}){
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
              } 
          }
    }

}

sub check_for_hidden_children{
    my $self = shift;

    if(${$self}{body} =~ m/$tokens{beginOfToken}/ and ($allChildrenIDRegExp ne q())){
        my $allChildrenIDRegExp_TMP = $allChildrenIDRegExp;
        while(${$self}{body} =~ m/($allChildrenIDRegExp)/ and ($allChildrenIDRegExp ne q())){
            # grab the match
            my $match = $1;

            # remove the match from the regexp
            $allChildrenIDRegExp =~ s/\|?$match//;

            my $naturalAncestors = ${$self}{naturalAncestors}; 
            # update the family tree with ancestors of self
            if(${$self}{ancestors}){
                foreach(@{${$self}{ancestors}}){
                    my $newAncestorId = ${$_}{ancestorID};
                    my $matched = grep { $_->{ancestorID} eq $newAncestorId } @{${$familyTree{$match}}{ancestors}};
                    if($naturalAncestors =~ m/${$_}{ancestorID}/ ){
                        $self->logger("Adding ${$_}{ancestorID} to the natural family tree of $match",'trace') if($is_t_switch_active);
                        push(@{$familyTree{$match}{ancestors}},{ancestorID=>${$_}{ancestorID},ancestorIndentation=>${$_}{ancestorIndentation},type=>"natural"}) unless $matched;
                    } else {
                        $self->logger("Adding ${$_}{ancestorID} to the adopted family tree of $match",'trace') if($is_t_switch_active);
                        push(@{$familyTree{$match}{ancestors}},{ancestorID=>${$_}{ancestorID},ancestorIndentation=>${$_}{ancestorIndentation},type=>"adopted"})  unless $matched;
                    }
                }
            }

            # update the family tree with self
            my $newAncestorId = ${$self}{id};
            my $matched = grep { $_->{ancestorID} eq $newAncestorId } @{${$familyTree{$match}}{ancestors}};
            if($naturalAncestors =~ m/${$self}{id}/ ){
                $self->logger("Adding ${$self}{id} to the natural family tree of hiddenChild $match",'trace') if($is_t_switch_active);
                push(@{$familyTree{$match}{ancestors}},{ancestorID=>${$self}{id},ancestorIndentation=>${$self}{indentation},type=>"natural"}) unless $matched;
            } else {
                $self->logger("Adding ${$self}{id} to the adopted family tree of hiddenChild $match",'trace') if($is_t_switch_active);
                push(@{$familyTree{$match}{ancestors}},{ancestorID=>${$self}{id},ancestorIndentation=>${$self}{indentation},type=>"adopted"}) unless $matched;
            }
        }
        $allChildrenIDRegExp = $allChildrenIDRegExp_TMP; 
    }

}

sub update_child_id_reg_exp{
    my $self = shift;

    $allChildrenIDRegExp .= ($allChildrenIDRegExp eq '' ?q():"|").${$self}{id};
    $allChildren{${$self}{id}} = \%{$self};
    return;
}

1;
