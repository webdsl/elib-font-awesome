module elib/elib-fontawesome/lib
imports elib/elib-fontawesome/icons

  template fontawesomeIncludes() {
    includeCSS("fontawesome/css/all.min.css")
  }

  template faBool(x: Bool) {
    if(x != null && x) { fasCheck } else { fasXmark }
  }

  template faOk(x: Bool) {
    if(x != null && x) { fasCheck }
  }
