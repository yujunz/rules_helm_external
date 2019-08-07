load(
    "@com_github_yujunz_rules_helm//helm/private:context.bzl",
    "helm_context",
)
load(
    "@com_github_yujunz_rules_helm//helm/private:helm_toolchain.bzl",
    _declare_toolchains = "declare_toolchains",
    _helm_toolchain = "helm_toolchain",
)
load(
    "@com_github_yujunz_rules_helm//helm/private:rules/cli.bzl",
    _helm_cli = "helm_cli",
)

def _helm_chart_impl(ctx):
    """Implementes the helm_chart() rule."""
    helm = helm_context(ctx)
    chart = helm.new_chart(helm)
    source = helm.chart_to_source(helm, ctx.attr, chart)
    package = helm.package(helm, source)

    return [
        chart,
        source,
        package,
        DefaultInfo(
            files = depset([package.data.file]),
        ),
        OutputGroupInfo(
            packaged_outputs = [package.data.file],
        ),
    ]

helm_chart = rule(
    implementation = _helm_chart_impl,
    attrs = {
        "data": attr.label_list(allow_files = True),
        "srcs": attr.label_list(allow_files = True),
    },
    toolchains = ["@com_github_yujunz_rules_helm//helm:toolchain"],
)

declare_toolchains = _declare_toolchains
helm_cli = _helm_cli
helm_toolchain = _helm_toolchain
