MathJax = {
    tex: {
      inlineMath: [['$', '$'], ['\(', '\)']]
    },
    options: {
      enableMenu: true,          // set to false to disable the menu
      menuOptions: {
        settings: {
          texHints: true,        // put TeX-related attributes on MathML
          semantics: false,      // put original format in semantic tag in MathML
          zoom: 'Click',         // or 'Click' or 'DoubleClick' as zoom trigger
          zscale: '200%',        // zoom scaling factor
          renderer: 'CHTML',     // or 'SVG'
          alt: false,            // true if ALT required for zooming
          cmd: false,            // true if CMD required for zooming
          ctrl: false,           // true if CTRL required for zooming
          shift: false,          // true if SHIFT required for zooming
          scale: 1,              // scaling factor for all math
          inTabOrder: true,      // true if tabbing includes math
          assistiveMml: true,    // true if hidden assistive MathML should be generated for screen readers
          collapsible: false,    // true if complex math should be collapsible
          explorer: true,       // true if the expression explorer should be active
        },
        annotationTypes: {
          TeX: ['TeX', 'LaTeX', 'application/x-tex'],
          StarMath: ['StarMath 5.0'],
          Maple: ['Maple'],
          ContentMathML: ['MathML-Content', 'application/mathml-content+xml'],
          OpenMath: ['OpenMath']
        }
      }
    }
  };
