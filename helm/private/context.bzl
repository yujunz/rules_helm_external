load(
    "@com_github_yujunz_rules_helm//helm/private:providers.bzl",
    "HelmChart",
    "HelmSource",
    "get_source",
)

HelmContext = provider()
_HelmContextData = provider()

def helm_context(ctx, attr = None):
    toolchain = ctx.toolchains["@com_github_yujunz_rules_helm//helm:toolchain"]

    if not attr:
        attr = ctx.attr

    return HelmContext(
        # Fields
        toolchain = toolchain,
        tools = toolchain.cli,
        helm = toolchain.cli.helm,

        # Action generators
        package = toolchain.actions.package,

        # Helpers
        new_chart = _new_chart,
        chart_to_source = _chart_to_source,

        # Private
        _ctx = ctx,  # TODO: All uses of this should be removed
    )

def _new_chart(helm, name = None, resolver = None, **kwargs):
    return HelmChart(
        name = helm._ctx.label.name if not name else name,
        label = helm._ctx.label,
        resolve = resolver,
        **kwargs
    )

def _chart_to_source(helm, attr, chart):
    attr_srcs = [f for t in getattr(attr, "srcs", []) for f in as_iterable(t.files)]
    generated_srcs = getattr(chart, "srcs", [])
    srcs = attr_srcs + generated_srcs
    source = {
        "chart": chart,
        "srcs": srcs,
        "orig_srcs": srcs,
        "orig_src_map": {},
        "deps": getattr(attr, "deps", []),
        "runfiles": _collect_runfiles(helm, getattr(attr, "data", []), getattr(attr, "deps", [])),
    }
    if chart.resolve:
        chart.resolve(helm, attr, source)
    return HelmSource(**source)

def _collect_runfiles(helm, data, deps):
    """Builds a set of runfiles from the deps and data attributes. srcs and
    their runfiles are not included."""
    files = depset(transitive = [t[DefaultInfo].files for t in data])
    runfiles = helm._ctx.runfiles(transitive_files = files)
    for t in data:
        runfiles = runfiles.merge(t[DefaultInfo].data_runfiles)
    for t in deps:
        runfiles = runfiles.merge(get_source(t).runfiles)
    return runfiles

def as_iterable(v):
    if type(v) == "list":
        return v
    if type(v) == "tuple":
        return v
    if type(v) == "depset":
        return v.to_list()
    fail("as_iterator failed on {}".format(v))
