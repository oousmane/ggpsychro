# R CMD Check
## OS specific build and check arguments
## get as cran from environment
args <- if (Sys.getenv("NOT_CRAN", FALSE)) c("--as-cran") else c()
build_args <- c("--force")

# do not build manual for appveyor
# also fix LaTeX Error: File `inconsolata.sty' not found on osx
# https://github.com/travis-ci/travis-ci/issues/7875
if (.Platform$OS.type == "windows" || Sys.getenv("TRAVIS_OS_NAME") == "osx") args <- c("--no-manual", args)

do_package_checks(args = args, build_args = build_args, codecov = FALSE)

# pkgdown
# make sure to clean site to rebuild everything
if (ci_get_branch() == "master" && Sys.getenv("TRAVIS_OS_NAME") == "linux" && Sys.getenv("TRAVIS_R_VERSION_STRING") == "release") {
    get_stage("before_deploy") %>%
        add_step(step_setup_ssh())

    get_stage("deploy") %>%
        add_step(step_build_pkgdown(document = FALSE, run_dont_run = TRUE))

    get_stage("deploy") %>%
        add_step(step_push_deploy(path = "docs", branch = "gh-pages"))
}

# codecov
if (Sys.getenv("TRAVIS_OS_NAME") == "linux" && Sys.getenv("TRAVIS_R_VERSION_STRING") == "devel") {
    get_stage("deploy") %>% add_code_step(covr::codecov())
}

