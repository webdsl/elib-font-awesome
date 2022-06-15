module elib/elib-fontawesome/lib

  template fontawesomeIncludes() {
    includeCSS("fontawesome/css/fontawesome.min.css")

    includeCSS("fontawesome/css/solid.min.css")   // (default) solid font awesome icons
    includeCSS("fontawesome/css/regular.min.css") // regular font awesome icons
    includeCSS("fontawesome/css/brands.min.css")  // brand icons such as youtube, twitter, programming languages, etc.
  }
