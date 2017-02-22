\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{outn}[2016/09/16 v0.61 (Robert Brignall, all rights reserved)]

\newif\if@studenttex
\@studenttexfalse
\DeclareOption{studenttex}{%
  \@studenttextrue
}
\newif\if@specsolns
\@specsolnsfalse
\DeclareOption{specsolns}{%
  \@specsolnstrue
}

\ProcessOptions\relax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load packages/class file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\LoadClass[fleqn,10pt,onecolumn,twoside,a4paper]{article}
\RequirePackage[a4paper,left=2cm,right=6cm,top=1cm,bottom=3cm,marginparwidth=5cm,marginparsep=0ex,nohead,asymmetric]{geometry}%
\RequirePackage{fancyhdr}
\RequirePackage{graphicx}
\RequirePackage{changepage}
\RequirePackage{array}
\RequirePackage[fleqn]{amsmath}
\RequirePackage{amsthm}
\RequirePackage{amssymb}
\RequirePackage{lastpage}
\RequirePackage{ifthen}
\RequirePackage[inline,shortlabels]{enumitem}
\RequirePackage{marginnote}
\RequirePackage{xcolor}
%\RequirePackage[xcolor]{mdframed}
\RequirePackage{framed}
\RequirePackage{pgfkeys}
\RequirePackage{environ}
\if@studenttex
  \RequirePackage{l3regex,l3tl-analysis,l3str}
  \RequirePackage{answers}
  \RequirePackage{xparse}
\fi
\if@specsolns
  \RequirePackage{verbatim}
\fi


%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters to set up module codes, etc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\@faculty{Mathematics, Computing and Technology}
\newcommand\faculty[1]{\DeclareRobustCommand\@faculty{#1}}
%
\newcommand\modulecode[1]{\renewcommand\@modulecode{#1}}
\newcommand\@modulecode{\@latex@error{No \noexpand\modulecode specified}\@ehc}

\newcommand\moduletitle[1]{\renewcommand\@moduletitle{#1}}
\newcommand\@moduletitle{\@latex@error{No \noexpand\moduletitle specified}\@ehc}
%
\newcommand\tnyear[1]{\renewcommand\@tnyear{#1}}
\newcommand\@tnyear{\@latex@error{No \noexpand\tnyear specified}\@ehc}
%
% Optional copyrightyear:
\def\@copyrightyear{\@tnyear}
\newcommand\copyrightyear[1]{\def\@copyrightyear{#1}}
%
\newcommand\tntitle[1]{\renewcommand\@tntitle{#1}}
\newcommand\@tntitle{\@latex@error{No \noexpand\tntitle specified}\@ehc}

\definecolor{ougreen}{RGB}{0,128,0}
\def\@specsolnscolor{ougreen}
\newcommand\specsolnscolor[1]{\def\@specsolnscolor{#1}}
\if@specsolns
  \AtBeginDocument{\color{\@specsolnscolor}}
\fi


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title page
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Footers for title page (copyright, etc)
\fancypagestyle{frontpage}{%
  \fancyhf{} % clear all header and footer fields
  \renewcommand{\headrulewidth}{0pt}
  %\renewcommand{\footrulewidth}{2pt}%
    \fancyfoot[L]{%
    	\if@specsolns\color{\@specsolnscolor}\fi
    	\textbf{Copyright \copyright\ \@copyrightyear\ The Open University}%
	}%
}
