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
%
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
%
%
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
\renewcommand{\maketitle}{
	\thispagestyle{frontpage}
	\if@specsolns
		%
		%
		\begin{adjustwidth}{0cm}{-4cm}
			\begin{tabular}{@{}p{17cm}@{}}
				\parbox{12cm}{
					\textbf{\@faculty\newline
						\@modulecode\ \@moduletitle}
				}
				\hfill{\fboxsep=5mm\fboxrule=1.5mm\fbox{\large\sf Specimen Solutions}}\par
				\medskip
				\textbf{\Large \@tntitle\ \@tnyear}
			\end{tabular}
		\end{adjustwidth}
		%
		%
	\else % not specimen solutions
		%
		%
		%\vspace{2cm}
		\begin{adjustwidth}{0cm}{-4cm}
			\begin{tabular}{@{}p{4.5cm}@{}p{12.5cm}@{}}
				\vspace{0.2cm}
				\includegraphics[width=3.5cm]{ou_greyscale_masterlogo_29mm}%{ou_compact_grey_24mm}
				&
				\vspace{0.2cm}\relax
				\parbox{8cm}{
					\textbf{\@faculty\newline
						\@modulecode\ \@moduletitle}
				}
				\hfill{\fboxsep=5mm\fboxrule=1.5mm\fbox{\large\sf Tutor Notes}}\par
				\medskip
				\textbf{\Large \@tntitle\ \@tnyear}
			\end{tabular}
		\end{adjustwidth}
		%
		%
	\fi
}

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up footer info
\fancypagestyle{internalpages}{%
	\fancyhf{} % clear all header and footer fields
	\renewcommand{\headrulewidth}{0pt}
	\renewcommand{\footrulewidth}{0pt}%
	\fancyfootoffset[RE,RO]{4cm} % lines up number with marks column
	\fancyfoot[C]{%
		\if@specsolns\color{\@specsolnscolor}\fi
		page~\thepage~of~\pageref{LastPage}%
	} % centre bottom of every page except first
}
\pagestyle{internalpages}


\setcounter{secnumdepth}{3}

%\newcommand{\marginnote}[1]{{\renewcommand{\baselinestretch}{1.0}\marginpar{\footnotesize \raggedright #1}}}
\raggedright
\raggedbottom
\parindent 0pt
\parskip 6pt
\setlength{\mathindent}{20pt}\relax
\g@addto@macro{\normalsize}{%
	\setlength\abovedisplayskip{8pt plus 1 pt minus 1pt}%
	\setlength\belowdisplayskip{8pt plus 1pt minus 1pt}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TMA/CMA initiators
% Usage syntax: \assignment{name}[cut off]{number}[subtitle]
%
\newif\iffirstassignment
\firstassignmenttrue

\def\assignment#1{%
\def\@assignmentname{#1} %store name of assignment (tma/cma, etc)
\setcounter{question}{0}
% Draw a rule under end of previous assignment (if not first assignment)
\iffirstassignment\firstassignmentfalse\else\par\addvspace{\smallskipamount}\makebox[\textwidth][l]{\rule{\dimexpr\textwidth+\marginparwidth+\marginparsep}{2pt}}\newpage\fi
\@ifnextchar[{\@assignmentwithcutoff}{\@assignmentnocutoff}
}

% Version that doesn't add a new page
\def\samepageassignment#1{%
\def\@assignmentname{#1} %store name of assignment (tma/cma, etc)
\setcounter{question}{0}
% Draw a rule under end of previous assignment (if not first assignment)
\iffirstassignment\firstassignmentfalse\else\par\addvspace{\smallskipamount}\makebox[\textwidth][l]{\rule{\dimexpr\textwidth+\marginparwidth+\marginparsep}{2pt}}\par\bigskip\fi
\@ifnextchar[{\@assignmentwithcutoff}{\@assignmentnocutoff}
}

\def\@assignmentwithcutoff[#1]#2{%
\def\@cutoff{\@cutofftext\ #1}
{\large \textbf{\@assignmentname\ #2} \hfill\textbf{\@cutofftext}#1}
\@ifnextchar[{\@assignmentsubtitle}{
		\par\addvspace{\bigskipamount}
	}
}

\def\@assignmentnocutoff#1{%
\def\@cutoff{\relax}
{\large \textbf{\@assignmentname\ #1}}%
\@ifnextchar[{\@assignmentsubtitle}{\par\addvspace{\bigskipamount}}
}

% This does nothing except add some space, 
% but means structure is identical to ouab.cls.
\def\@assignmentsubtitle[#1]{%
	\par\addvspace{\bigskipamount}
}

% Allows cut-off text to be suppressed
\def\@cutofftext{Cut-off date\ \ }
\def\nocutoffdate{\def\@cutofftext{See module website for the cut-off date.}}

% Set up the two most common types of assignment, and starred versions (which add no new page)
% usage e.g. \tma[cut off]{number}[subtitle]
\def\tma{\@ifstar\@tma\@@tma}
\def\@tma{\samepageassignment{TMA}}
\def\@@tma{\assignment{TMA}}
% And for CMAs
\def\cma{\@ifstar\@cma\@@cma}
\def\@cma{\samepageassignment{CMA}}
\def\@@cma{\assignment{CMA}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Horizontal lines after subtotals and totals
\newif\ifdraw@total@line
\newif\ifdraw@subtotal@line

% reference: http://tex.stackexchange.com/questions/34312/how-to-create-a-command-with-key-values
\pgfkeys{
	/totalhline/.is family, /totalhline,
	default/.style =
		{moveleft=.1\textwidth,
			width=1.5\textwidth,
			height=2pt,
			color=black},
	moveleft/.estore in=\@outn@total@hline@move@left,
	width/.estore in=\@outn@total@hline@width,
	height/.estore in=\@outn@total@hline@height,
	color/.estore in=\@outn@total@hline@color,
	draw line/.is if=draw@total@line,
	/subtotalhline/.is family, /subtotalhline,
	default/.style =
		{moveleft=.1\textwidth,
			width=1.5\textwidth,
			height=1pt,
			color=black},
	moveleft/.estore in=\@outn@subtotal@hline@move@left,
	width/.estore in=\@outn@subtotal@hline@width,
	height/.estore in=\@outn@subtotal@hline@height,
	color/.estore in=\@outn@subtotal@hline@color,
	draw line/.is if=draw@subtotal@line,
}

% command to customise the line after totals
\newcommand{\setTotalHline}[1][]{%
	\pgfkeys{/totalhline,default,#1}%
}
% by default, turn subtotal lines on
\setTotalHline[draw line]

% command to customise the line after subtotals
\newcommand{\setSubtotalHline}[1][]{%
	\pgfkeys{/subtotalhline,default,#1}%
}
% by default, turn subtotal lines on
\setSubtotalHline[draw line]

% reference: http://tex.stackexchange.com/questions/29574/shift-horizontal-line-to-the-left
\newcommand{\outn@draw@rule}[4]{%
	% #1: moveleft
	% #2: width
	% #3: color
	% #4: height
	\par\bigskip\nobreak % don't break a page here
	\moveleft#1\vbox{% we want the rule to protrude on the left
		\hsize=#2% correct the length
		\kern\the\prevdepth % don't take into account the depth of the preceding line
		\kern\baselineskip % space before the rule
		\color{#3}\hrule height #4 width\hsize % the rule
		\kern3pt % space after the rule
	}\nointerlineskip % no additional space after the rule
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Question headers
\newcounter{question}

\def\question{\@ifstar\@question\@@question}
% \@question is the version with star: it displays no marks
\newcommand{\@question}[1][\unskip]{%
	\refstepcounter{question}
	\par\bigskip{\textbf{Solution to Question~\thequestion} #1}\nopagebreak\par}
% \@@question is the version with no star: 2nd (compulsory) argument takes number of marks to display. 
\newcommand{\@@question}[2][\unskip]{%
	\refstepcounter{question}
	\par\bigskip{\textbf{Solution to Question~\thequestion} #1} -- #2 marks\nopagebreak\par}

%% Subquestion settings -- all controlled by enumerate with enumitem
\setlist{itemsep=2pt,topsep=0pt,partopsep=0pt}
\setlist[enumerate]{align=left,leftmargin=8mm,labelsep*=0pt}
\setlist[enumerate,1]{label=(\alph*), ref=(\alph*)}
\setlist[enumerate,2]{label=(\roman*), ref=(\roman*)}
%%%%%%
%% Marks and remarks

\if@specsolns
	% suppress everything
	\newcommand{\bracketedmarks}[2][]{\relax}
	\newcommand{\solnmarks}[2][]{\relax}
	\newcommand{\solnmarksplus}[2]{\relax}
	\newcommand{\remark}[1]{\relax}
	\newcommand{\total}[2][\unskip]{\relax}
	\newcommand{\subtotal}[2][\unskip]{\relax}
	\newenvironment{longremark}{\comment}{\endcomment}
\else
	\newcounter{total}[question]
	\newcounter{subtotal}[question]
	\def\@update@totals#1{%
		\afterassignment\get@args\count@=0#1\hfuzz#1\hfuzz}
	\def\get@args#1\hfuzz#2\hfuzz{%
		\if\relax\detokenize{#1}\relax
			\addtocounter{subtotal}{#2}%
			\addtocounter{total}{#2}%
		\else
			\relax
		\fi
	}
	\newcommand{\bracketedmarks}[2][\unskip]{\marginnote{\hfill \makebox[1cm][r]{[\textsl{#2}]}\makebox[4cm][r]{\parbox[t]{3.75cm}{\small\raggedright #1}}}\@update@totals{#2}}
	\newcommand{\solnmarks}[2][\unskip]{\marginnote{\hfill\small \makebox[1cm][r]{#2}\makebox[4cm][r]{\parbox[t]{3.75cm}{\raggedright #1}}}\@update@totals{#2}}
	\newcommand{\solnmarksplus}[2]{\solnmarks[#2]{#1}}
	\def\total{\@ifstar\@total\@@total}
	\def\subtotal{\@ifstar\@subtotal\@@subtotal}
	\newcommand{\remark}[1]{\emph{Remark:} #1}
	\newenvironment{longremark}{\emph{Remarks:}\par}{}
\fi

% \total*
\newcommand{\@total}[1][\unskip]{\marginnote{\bfseries \makebox[1cm][r]{\thetotal}\ Total\ #1}\outn@draw@total@rule}
% \total[]{}
\newcommand{\@@total}[2][\unskip]{\marginnote{\bfseries \makebox[1cm][r]{#2}\ Total\ #1}\outn@draw@total@rule}

% \subtotal*
\newcommand{\@subtotal}[1][\unskip]{\marginnote{\small\bfseries \makebox[1cm][r]{\thesubtotal}\ Subtotal\ #1 }\setcounter{subtotal}{0}\outn@draw@subtotal@rule}

% \subtotal[]{}
\newcommand{\@@subtotal}[2][\unskip]{\marginnote{\small\bfseries \makebox[1cm][r]{#2}\ Subtotal\ #1}\setcounter{subtotal}{0}\outn@draw@subtotal@rule}

% total horizontal rule
\newcommand{\outn@draw@total@rule}{%
	\ifdraw@total@line
		\outn@draw@rule{\@outn@total@hline@move@left}%
		{\@outn@total@hline@width}%
		{\@outn@total@hline@color}%
		{\@outn@total@hline@height}%
	\fi%
}

% subtotal horizontal rule
\newcommand{\outn@draw@subtotal@rule}{%
	\ifdraw@subtotal@line
		\outn@draw@rule{\@outn@subtotal@hline@move@left}%
		{\@outn@subtotal@hline@width}%
		{\@outn@subtotal@hline@color}%
		{\@outn@subtotal@hline@height}%
	\fi%
}


%
\def\marks{\solnmarks}
\def\mk{\solnmarks}
\def\mkplus{\solnmarksplus}
\newcommand{\textref}[1]{\hfill\fbox{\emph{\textbf{#1}}}}
\newcommand{\longtextref}[1]{\hfill\fbox{\parbox{\dimexpr\textwidth-2\fboxsep-0.8pt\relax}{\emph{\textbf{#1}}}}}
%\newcommand{\textref}[1]{\hfill\begin{framed}\emph{\textbf{#1}}\end{framed}}
%\newcommand{\textref}[1]{%
% \setlength{\@tempdima}{\dimexpr\textwidth-2\fboxsep-0.8pt\relax}%
% \sbox{\@tempboxa}{#1}%
% \ifdim\wd\@tempboxa>\@tempdima
%   \hfill\fbox{\parbox{\@tempdima}{\raggedleft{\em\bfseries#1}}}%
% \else
%   \hfill\fbox{\em\bfseries#1}%
%\fi
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Options for CMAs

% Options text
\def\@optiontext{\emph{Options}\par}
\newcommand\optiontext[1]{%
	\def\@optiontext{
		\ifthenelse{\equal{#1}{}}{}{\emph{#1}\par}
	}
}

% Inline ones (chops page into columns by using boxes of appropriate widths)
\newenvironment{inlineoptions}[2][1]{%
	% #1 is the optional line spacing stretch. Default is 1
	% #2 is the number of columns
	\par\medskip\@optiontext
	\setcounter{enumi}{0}%
	\dimen0 \linewidth%
	\divide\dimen0 by #2\relax%
	\def\item{\hfil\egroup\penalty50 \hfill%
		\refstepcounter{enumi}%
		\def\baselinestretch{#1}%
		\@currsize
		\leavevmode\hbox to \dimen0 \bgroup\protect\makebox[0.7cm][l]{\textbf{\Alph{enumi}}}\space }%
	% Hack to allow "blank" slots at end of final line (or wherever)
	\def\noitem{\hfil\egroup\penalty50 \hfill%
		\leavevmode\hbox to \dimen0 \bgroup}%
	\leavevmode\bgroup\hskip 0pt plus -1fill %
}{\hfil\egroup\par}

% Normal options: this is just using enumitem features with enumerate.
\newenvironment{options}%
{\par\medskip\@optiontext\begin{enumerate}[label=\textbf{\Alph*}]}%
		{\end{enumerate}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make marks always appear on RHS:
%% Needed for marginnote package
\long\def\@mn@@@marginnote[#1]#2[#3]{%
	\begingroup
	\ifmmode\mn@strut\let\@tempa\mn@vadjust\else
		\if@inlabel\leavevmode\fi
		\ifhmode\mn@strut\let\@tempa\mn@vadjust\else\let\@tempa\mn@vlap\fi
	\fi
	\@tempa{%
		\vbox to\z@{%
			\vss
			\@mn@margintest
			\if@reversemargin\if@tempswa
					\@tempswafalse
				\else
					\@tempswatrue
				\fi\fi
			\rlap{%
				\ifx\@mn@currxpos\relax
					\kern\marginnoterightadjust
					\if@mn@verbose
						\PackageInfo{marginnote}{%
							xpos not known,\MessageBreak
							using \string\marginnoterightadjust}%
					\fi
				\else\ifx\@mn@currxpos\@empty
						\kern\marginnoterightadjust
						\if@mn@verbose
							\PackageInfo{marginnote}{%
								xpos not known,\MessageBreak
								using \string\marginnoterightadjust}%
						\fi
					\else
						\if@mn@verbose
							\PackageInfo{marginnote}{%
								xpos seems to be \@mn@currxpos,\MessageBreak
								\string\marginnoterightadjust
								\space ignored}%
						\fi
						\begingroup
						\setlength{\@tempdima}{\@mn@currxpos}%
						\kern-\@tempdima
						\if@twoside\ifodd\@mn@currpage\relax
								\kern\oddsidemargin
							\else
								\kern\evensidemargin
							\fi
						\else
							\kern\oddsidemargin
						\fi
						\kern 1in
						\endgroup
					\fi
				\fi
				\kern\marginnotetextwidth\kern\marginparsep
				\vbox to\z@{\kern\marginnotevadjust\kern #3
					\vbox to\z@{%
						\hsize\marginparwidth
						\linewidth\hsize
						\kern-\parskip
						\marginfont\raggedrightmarginnote\strut\hspace{\z@}%
						\ignorespaces#2\endgraf
						\vss}%
					\vss}%
			}%
		}%
	}%
	\endgroup
}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solutions

%\newmdenv[linewidth=0pt,topline=false,bottomline=false,rightline=false,innerrightmargin=5.5cm,innerleftmargin=10pt,linecolor=black,frametitle=Solution to \thequestion]{solutionbox}
%
%\newenvironment{solution}
% {\def\marks{\solnmarks}\begin{adjustwidth}{-13pt}{-5.5cm}\begin{solutionbox}\small}
% {\end{solutionbox}\end{adjustwidth}\def\marks{\bracketedmarks}}
\if@studenttex
	\ExplSyntaxOn
	\NewEnviron{solution}
	{
		\def\marks{\solnmarks}
		\textbf{Solution}
		\par
		\strip_marks:V \BODY
	}[\def\marks{\bracketedmarks}]

	\tl_new:N \l_solution_text_tl
	\iow_new:N \g_solution_stream

	\cs_generate_variant:Nn \tl_replace_all:Nnn {NV}
	\cs_generate_variant:Nn \iow_now:Nn { NV }
	\str_const:Nx \c_other_eol_str { \cs_to_str:N \^^M }

	\cs_new_protected:Npn \strip_marks:n #1
	{
		\tl_set:Nn \l_solution_text_tl { #1 }
		\l_solution_text_tl % Send token list to normal output unmodified 
		%\tl_show_analysis:n { \l_solution_text_tl } % for debugging
		% Remove all instances of \marks{} commands
		\regex_replace_all:nnN { \c{marks}\cB\{ [^\}]* \cE\} } {  } \l_solution_text_tl
		\regex_replace_all:nnN { \c{marks} \w } {  } \l_solution_text_tl
		\regex_replace_all:nnN { \c{solnmarksplus}\cB\{ [^\}]* \cE\} \cB\{ [^\}]* \cE\} } {  } \l_solution_text_tl
		\regex_replace_all:nnN { \c{solnmarksplus} ^[\}|\{] } {  } \l_solution_text_tl
		\regex_replace_all:nnN { \c{mk}\cB\{ [^\}]* \cE\} } {  } \l_solution_text_tl
		\regex_replace_all:nnN { \c{mk} \w } {  } \l_solution_text_tl
		\regex_replace_all:nnN { \c{remark}\cB\{ [^\}]* \cE\} } {  } \l_solution_text_tl
		\iow_now:Nx \g_solution_stream {Solution~to~Question~\thequestion}
		\iow_now:NV \g_solution_stream \l_solution_text_tl % Send modified token list to stream.
	}
	\cs_generate_variant:Nn \strip_marks:n { V }

	\AtBeginDocument{
		\iow_open:Nn \g_solution_stream { \jobname-student.tex }
		\def\solnpreamble{\documentclass{article}\usepackage{amsmath}\begin{document}}
		\iow_now:Nn \g_solution_stream {\documentclass{article}\usepackage{amsmath}\begin{document}}
			}
			\AtEndDocument{
			\iow_now:Nn \g_solution_stream{\end{document}}
		\iow_close:N \g_solution_stream
	}
	\ExplSyntaxOff
\else %matches \if@studenttex
	\newenvironment{solution}{}{}
	%\NewEnviron{solution}
	%{
	% \BODY % This doesn't work if verbatim is contained inside too.
	%}
\fi

%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Line at end of AB
\let\@oldenddochook\@enddocumenthook
\def\@enddocumenthook{%
	\par\bigskip \makebox[\textwidth][l]{\rule{\dimexpr\textwidth+\marginparwidth+\marginparsep}{2pt}}
	\@oldenddochook}

%%
%% EOF
